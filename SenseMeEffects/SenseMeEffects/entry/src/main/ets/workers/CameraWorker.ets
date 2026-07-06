import { collections, ErrorEvent, MessageEvents, ThreadWorkerGlobalScope,
  worker } from '@kit.ArkTS';
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {  ProcessData } from './ProcessData';
import { CameraData, PageData, PageMode } from './CameraData';
import CameraService from '../camera/Camera';
import { Singleton } from './Singleton';

import libentry,{  st_image_t,
  PixelFormat, RotateType } from '@softsugar/mars_effects';
import { fileIo } from '@kit.CoreFileKit';
import { ViewData } from './ViewData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { EventBus, EventType } from '../utils/EventBus';
import fs from '@ohos.file.fs';
import { ICallBack, IFrameCallBack, PlayerState, STPlayer, STRecorder } from 'stplayer';
import { sensor } from '@kit.SensorServiceKit';
import { media } from '@kit.MediaKit';


const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
let cameraPosition: camera.CameraPosition

let processData:ProcessData = new ProcessData()
let lastFrameTime = 0

let isReleased: boolean = false  // 标记是否已释放资源


sensor.on(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
  let degree: number = -1;
  degree = CalDegree(data.x, data.y, data.z); // 计算角度的函数
  if (degree >= 0 && (degree <= 30 || degree >= 330)) {
    globalThis.deviceRotate =  RotateType.ROTATE_270;
  } else if (degree >= 60 && degree <= 120) {
    globalThis.deviceRotate =  RotateType.ROTATE_180;
  } else if (degree >= 150 && degree <= 210) {
    globalThis.deviceRotate =  RotateType.ROTATE_90;
  } else if (degree >= 240 && degree <= 300) {
    globalThis.deviceRotate = RotateType.ROTATE_0;
  }
});

function CalDegree(x: number, y: number, z: number): number {
  let degree: number = -1;
  // 3 为有效增量角度阈值系数
  if ((x * x + y * y) * 3 < z * z) {
    return degree;
  }
  degree = 90 - (Math.atan2(y, -x) * 180 / Math.PI);
  return degree >= 0 ? degree % 360 : degree % 360 + 360;
}

workerPort.onmessage = async (event: MessageEvents) => {
  const messageInfo: CameraData = event.data;
  if ('initCamera' === messageInfo.type) {
    // 重新初始化时重置标记
    if (!messageInfo.pageData.context) {
      console.error('[Camera Worker] : init camera error, context is null.');
      return
    }
    initMediaPlayer()
    context = messageInfo.pageData.context

    // 在worker线程中初始化相机。
    await CameraService.initCamera(messageInfo.pageData.context, messageInfo.cameraPosition, {width:messageInfo.cameraWidth,height:messageInfo.cameraHeight})
    isReleased = false

    cameraPosition = messageInfo.cameraPosition
    processData.pageData = messageInfo.pageData

    CameraService.captureOutputDidOutputImage = (nextImage: image.Image) => {
      nextImage.getComponent(4,async (err: BusinessError, imgComponent: image.Component) => {
        if (err || imgComponent === undefined ||isReleased ) {
          nextImage.release();
          return;
        }
        if (imgComponent.byteBuffer as ArrayBuffer) {
          const buffer = imgComponent.byteBuffer.slice(0);
          let width = nextImage.size.width; // width为应用创建预览流分辨率对应的宽
          let height = nextImage.size.height; // height为应用创建预览流分辨率对应的高
          let rot : RotateType = globalThis.deviceRotate;
          if (cameraPosition != camera.CameraPosition.CAMERA_POSITION_FRONT){
            rot = ((4 - rot)%4) as RotateType
          }
          let orientation :RotateType=
            (cameraPosition == camera.CameraPosition.CAMERA_POSITION_FRONT) ? RotateType.ROTATE_270 :
            RotateType.ROTATE_90
          let mirror = cameraPosition == camera.CameraPosition.CAMERA_POSITION_FRONT;
          //let cameraPos : CameraPos = cameraPosition == camera.CameraPosition.CAMERA_POSITION_FRONT?CameraPos.Front:CameraPos.Back

          processData.buffer = buffer
          processData.width = width
          processData.height = height
          processData.stride = width
          processData.rotation = rot
          processData.mirror = mirror
          processData.orientation = orientation

          //console.log('[Camera Worker] process frame: ' + width + 'x' + height + ', rotation: ' + rot + ', mirror: ' + mirror + ', orientation: ' + orientation);

          processData.format = PixelFormat.ST_PIX_FMT_NV21
  /*
          processData.immediately = (Date.now() - lastImmediatelyTimes)> 100
          if (processData.immediately) {
            lastImmediatelyTimes = Date.now()
          }
  */
          processData.lastFrameTime = lastFrameTime
          lastFrameTime = Date.now()
          process(processData)
          nextImage.release();
        } else {
          nextImage.release();
          return;
        }
      });
    }
  }
  else if ('releaseCamera' === messageInfo.type) {
    isReleased = true
    libentry.destroy()
    CameraService.stop()
    await CameraService.releaseCamera();
    // 清空回调,防止残留引用
    CameraService.captureOutputDidOutputImage = undefined
    workerPort.close()

  }
  else if ('changeCamera' === messageInfo.type) {
    if (!messageInfo.pageData.context) {
      console.error('[Camera Worker] : change camera error, context is null.');
      return
    }
    isReleased = true
    cameraPosition = messageInfo.cameraPosition
    await CameraService.beforeChange()
    await CameraService.initCamera(messageInfo.pageData.context, messageInfo.cameraPosition, {width:messageInfo.cameraWidth,height:messageInfo.cameraHeight})
    isReleased = false
  }
  else if ('destroy' === messageInfo.type) {
    libentry.destroy()
  }
  else if('updatePageData' === messageInfo.type){
    processData.pageData = messageInfo.pageData
  }
  else if('initPhoto' === messageInfo.type){
    initMediaPlayer()
    context = messageInfo.pageData.context
    let uri = messageInfo.uri
    let file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    let stat = fileIo.statSync(file.fd)
    let originalImageBuffer = new ArrayBuffer(stat.size)
    fileIo.readSync(file.fd, originalImageBuffer)
    fileIo.closeSync(file)
    let imageSource = image.createImageSource(originalImageBuffer)
    imageSource.getImageInfo().then((imageInfo) => {
      let width = imageInfo.size.width
      let height = imageInfo.size.height
      // 如果图片分辨率大于1080，压缩图片尺寸以降低内存占用
      const MAX_SIZE = 1080
      let scale = 1.0
      if (Math.max(width, height) > MAX_SIZE) {
        scale = MAX_SIZE / Math.max(width, height)
      }
      let compressedWidth = Math.floor(width * scale)
      let compressedHeight = Math.floor(height * scale)
      imageSource.createPixelMap({
        editable: true,
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
        desiredSize: { width: compressedWidth, height: compressedHeight },
      }).then((pixelMap) => {
        originalDecodedPixelBuffer = new ArrayBuffer(compressedWidth * compressedHeight * 4);
        pixelMap.readPixelsToBuffer(originalDecodedPixelBuffer).then(() => {
          if (originalDecodedPixelBuffer) {
            processData = new ProcessData()
            processData.buffer = originalDecodedPixelBuffer
            processData.width = compressedWidth
            processData.height = compressedHeight
            processData.stride = compressedWidth * 4
            processData.format = PixelFormat.ST_PIX_FMT_RGBA8888
            processData.pageData = messageInfo.pageData
            console.info(`[CameraWorker] initPhoto process: ${compressedWidth}x${compressedHeight}, stride=${compressedWidth * 4}, buffer=${originalDecodedPixelBuffer.byteLength}`)
            process(processData)
          }
        })
      })
    })
  }
  else if('updateProcess' === messageInfo.type){
    processData.pageData = messageInfo.pageData
    process(processData)
  }
  else if('initVideo' === messageInfo.type){
    initMediaPlayer()
    processData.pageData = messageInfo.pageData
    context = messageInfo.pageData.context
    preparePlayerSource(messageInfo.uri,messageInfo.pageData)
  }
  else if('changeVideoState' === messageInfo.type){
    if (messageInfo.pageData.changeVideoState == PlayerState.PLAYER_STOP) {
      STPlayer.stopPlay()
    }else if (messageInfo.pageData.changeVideoState == PlayerState.PLAYER_PAUSE) {
      STPlayer.pausePlay()
    }
    else if (messageInfo.pageData.changeVideoState == PlayerState.PLAYER_PLAYING){
      STPlayer.resumePlay()
    }
  }
  else if('startRecordVideo' === messageInfo.type){

    startRecordVideo(processData.height, processData.width)
  }
  else if('stopRecordVideo' === messageInfo.type){

    stopRecordVideo()
  }
  else if('saveRecordVideo' === messageInfo.type){

    saveRecordVideo()
  }
};

let originalDecodedPixelBuffer: ArrayBuffer | undefined

let outputArrayBuffer: ArrayBuffer|null = null
let viewData = new ViewData()
let context :Context|undefined = undefined

// Debug: 保存 outputArrayBuffer 的计数器
let debugSaveCount: number = 0

function process(processData:ProcessData){
  // 使用统一生命周期检查
  if (!globalThis.isWorkerActive()) {
    libentry.destroy();
    return;
  }

  if (processData.lastFrameTime != 0) {
    let deltaTime = Date.now() - processData.lastFrameTime;
    let instantFPS = 1000.0 / deltaTime; // 瞬时帧率
    // 平滑处理
    viewData.fps = (1 - 0.1) * viewData.fps + 0.1 * instantFPS;
  }
  
  context = processData.pageData.context;
  // 创建 buffer 的副本以避免并发访问冲突
  let data = processData.buffer.slice(0);
  let pixel_format = processData?.format;
  let width = processData?.width;
  let height = processData?.height;
  let stride = processData?.stride;
  let rotation = processData?.rotation;
  let mirror = processData?.mirror;
  let orientation = processData.orientation;

  let immediately = processData.pageData.immediately;
  let ori = processData.pageData.isOrigin;
  let mCustomEvent = processData.pageData.mCustomEvent;

  let isSavePicture = processData.pageData.isSavePicture;

  let outFormat: PixelFormat = isSavePicture ? PixelFormat.ST_PIX_FMT_RGBA8888 : PixelFormat.ST_PIX_FMT_NV21;

  let isDst = isRecord || isSavePicture;
  if (isSavePicture) {
    outputArrayBuffer = new ArrayBuffer(width * height * 4);
  }
  if (isRecord) {
    if (!outputArrayBuffer || outputArrayBuffer.byteLength != width * height * 3/2) {
      outputArrayBuffer = new ArrayBuffer(width * height * 3/2);
    }
  }

  libentry.process(data, pixel_format, width, height, stride, rotation, mirror, 0,
    isDst ? outputArrayBuffer : null, outFormat, orientation, ori, immediately, mCustomEvent);

  processData.pageData.mCustomEvent = 0;

  // Debug: 每帧将 outputArrayBuffer 保存为独立文件
/*
  if (outputArrayBuffer &&isSavePicture) {
    try {
      let debugDir = context?.cacheDir + '/debug_output';
      if (!fs.accessSync(debugDir)) {
        fs.mkdirSync(debugDir);
      }
      let debugPath = debugDir + `/frame_${debugSaveCount++}.bin`;
      let debugFile = fs.openSync(debugPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(debugFile.fd, outputArrayBuffer);
      fs.closeSync(debugFile);
      console.info(`[CameraWorker] Debug saved: ${debugPath}, size=${outputArrayBuffer.byteLength}`);
    } catch (e) {
      console.error(`[CameraWorker] Debug save failed: ${e}`);
    }
  }
*/

  if (outputArrayBuffer) {
    if (isSavePicture) {
      let pixelBuffer = new Uint8Array(outputArrayBuffer);
      if (processData.pageData.mode == PageMode.Preview) {
        saveScreenPicture(pixelBuffer, height, width);
      } else {
        saveScreenPicture(pixelBuffer, width, height);
      }
      processData.pageData.isSavePicture = false;
    } else if (isRecord) {
      // 检查录制状态后再推送帧
      if (globalThis.isWorkerActive()) {
        let ret = STRecorder.pushVideoFrame(outputArrayBuffer, recordWidth, recordHeight,Singleton.videoTimer);
        console.log(`[CameraWorker] push video frame ret ${ret}   timeer: ${Singleton.videoTimer}`);
        if (ret != 0) {
          console.log(`[CameraWorker] push video frame error ${ret}`);
        }
      }
    }
  }
  
  workerPort.postMessage(viewData);

}

/*EventBus.listenSingleEvent(EventType.StartRecord,(msg)=>{startRecordVideo(msg.data?.['width'],msg.data?.['height'])})
EventBus.listenSingleEvent(EventType.StopRecord,stopRecordVideo)
EventBus.listenSingleEvent(EventType.SaveRecord,saveRecordVideo)*/

// 录制状态管理
let isRecord = false
let recordWidth = 0
let recordHeight = 0
let recordStateCallbackRegistered = false

// 统一生命周期检查函数
globalThis.isWorkerActive = (): boolean => {
  if (Singleton.flag || !context) {
    console.warn('[CameraWorker] Worker已释放或context无效');
    return false;
  }
  return true;
}

// 录制状态枚举（对应C++中的R_STATE枚举）
enum RecorderState {
  NODE = 0,        // 初始状态
  START = 1,       // 开始录制
  PLAYING = 2,     // 正在录制
  STOP = 3,        // 停止录制
  COMPLETE = 4,    // 录制完成
  ERROR = 5,       // 错误状态
  ENCODING = 6     // 正在编码
}

function startRecordVideo(width:number, height:number) {
  // 使用统一生命周期检查`
  if (!globalThis.isWorkerActive()) {
    return;
  }
  
  let recordPath = context?.cacheDir + "/record.mp4"
  libentry.resetPixelReader()

  if (fs.accessSync(recordPath)) {
    fs.unlinkSync(recordPath)
  }
  let file: fs.File = fs.openSync(recordPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
  
  // 注册录制状态回调（只注册一次）
  if (!recordStateCallbackRegistered) {
    STRecorder.setRecorderStateCallback((state: number) => {
      if (!globalThis.isWorkerActive()) return;
      
      console.log(`[CameraWorker] Recorder state changed: ${getStateDescription(state)}`);
      
      switch (state) {
        case RecorderState.START:
          console.log('[CameraWorker] 录制开始');
          break;
          
        case RecorderState.PLAYING:
          console.log('[CameraWorker] 录制进行中');
          break;
          
        case RecorderState.ENCODING:
          console.log('[CameraWorker] 正在编码帧数据');
          // 可以在这里发送编码进度事件
          //EventBus.emitEvent(EventType.RecordingProgress, {data:{"progress":"encoding"}});
          break;
          
        case RecorderState.COMPLETE:
          console.log('[CameraWorker] 录制完成，所有帧已编码');
          isRecord = false;
          //EventBus.emitEvent(EventType.RecordingComplete, {data:{"message":"录制完成"}});
          break;
          
        case RecorderState.ERROR:
          console.error('[CameraWorker] 录制过程中发生错误');
          isRecord = false;
          EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"录制过程中发生错误"}});
          break;
          
        case RecorderState.STOP:
          console.log('[CameraWorker] 录制被停止');
          isRecord = false;
          break;
      }
    });
    recordStateCallbackRegistered = true;
  }
  
  let setDataSourceCallback: ICallBack = {
    callBackResult: (code: number) => {
      if (!globalThis.isWorkerActive()) return;
      
      if (code == 0) {
        let startCallback: ICallBack = {
          callBackResult: (code: number) => {
            if (!globalThis.isWorkerActive()) return;
            
            if (code == 0) {
              isRecord = true;
              console.log('[CameraWorker] 录制启动成功');
            } else {
              EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"录制启动失败"}});
            }
          }
        }
        STRecorder.startRecord(startCallback);
      } else {
        EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"输出视频路径设置失败"}});
      }
    }
  }
  
  recordWidth = width
  recordHeight = height
  STRecorder.setRecorderDataSource(recordPath, file.fd, width, height, 0, 0, setDataSourceCallback);
}

// 获取状态描述文本
function getStateDescription(state: number): string {
  switch (state) {
    case RecorderState.NODE:
      return '初始状态';
    case RecorderState.START:
      return '开始录制';
    case RecorderState.PLAYING:
      return '正在录制';
    case RecorderState.STOP:
      return '停止录制';
    case RecorderState.COMPLETE:
      return '录制完成';
    case RecorderState.ERROR:
      return '错误状态';
    case RecorderState.ENCODING:
      return '正在编码';
    default:
      return `未知状态: ${state}`;
  }
}
function stopRecordVideo() {
  if (!globalThis.isWorkerActive() || !isRecord) {
    console.warn('[CameraWorker] stopRecordVideo: 条件不满足,跳过停止录制');
    return;
  }
  
  isRecord = false;
  let fd = STRecorder.stopRecord();
  
  if (fd != 0) {
    fs.close(fd).then((error) => {
      if (error != null) {
        EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"视频录制失败"}});
      } else {
        console.log('[CameraWorker] 录制文件句柄已关闭');
      }
    });
  } else {
    EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"视频录制失败"}});
  }
}
async function saveRecordVideo() {
  try {
    if (!globalThis.isWorkerActive()) return;
    let recordPath = context?.cacheDir + "/record.mp4";
    if (!fs.accessSync(recordPath)) {
      EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"保存失败,未找到视频文件"}});
      return;
    }
    
    // 二次检查确保Worker仍然活跃
    if (!globalThis.isWorkerActive()) return;
    
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest = 
      photoAccessHelper.MediaAssetChangeRequest.createVideoAssetRequest(context, recordPath);
    await phAccessHelper.applyChanges(assetChangeRequest);
    EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"视频保存成功"}});
    console.log('[CameraWorker] 视频保存完成');
  } catch (err) {
    console.error(`[CameraWorker] saveRecordVideo failed: ${err.code}, ${err.message}`);
    EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"视频保存失败"}});
  }
}


function saveScreenPicture(pixelBuffer: Uint8Array, width: number, height: number): Promise<void> {
  return new Promise((resolve: Function) => {
    if (!globalThis.isWorkerActive()) {
      resolve();
      return;
    }
    
    for (let index = 0; index < width * height * 4; index += 4) {
      let temp = pixelBuffer[index];
      pixelBuffer[index] = pixelBuffer[index+2];
      pixelBuffer[index+2] = temp;
    }

    image.createPixelMap(uint8ArrayToArrayBuffer(pixelBuffer), {
      size: { width, height },
      pixelFormat: image.PixelMapFormat.RGBA_8888,
      editable: true
    }).then((pixelMap) => {
      savePixelMapToAlbum(pixelMap);
      resolve();
    }).catch((error: BusinessError) => {
      console.log(`[CameraWorker] createPixelMap error ${error}`);
      resolve();
    });
  });
}
function savePixelMapToAlbum(pixelMap: PixelMap): void {
  if (!globalThis.isWorkerActive()) return;
  
  // encode image
  let imagePacker = image.createImagePacker();
  let packOpts: image.PackingOption = { format: "image/jpeg", quality: 98 };
  
  imagePacker.packToData(pixelMap, packOpts).then(async (outputArrayBuffer) => {
    try {
      if (!globalThis.isWorkerActive()) return;
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      // Creating a Media File
      let uri =  await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg')
      let file = fileIo.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fileIo.writeSync(file.fd, outputArrayBuffer);
      fileIo.closeSync(file);
      EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"图片保存成功"}});
      console.log('[CameraWorker] 图片保存完成');
    }catch (error) {
      console.error(`[CameraWorker] 图像保存失败: ${error}`);
      EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"图片保存失败"}});
    }
  }).catch((error: BusinessError) => {
    console.error(`[CameraWorker] 图像打包失败: ${error}`);
    EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"图片保存失败"}});
  })
    .finally(()=>{
      pixelMap.release();
    })

}
function uint8ArrayToArrayBuffer(uint8Array: Uint8Array) {
  let arrayBuffer = new ArrayBuffer(uint8Array.length);
  let bufferView = new Uint8Array(arrayBuffer);
  bufferView.set(uint8Array);
  return arrayBuffer;
}

let  mediaPlayer : media.AVPlayer|undefined = undefined
let url:string
function initMediaPlayer() {
  if (mediaPlayer == undefined) {
    media.createAVPlayer((info, player) => {
      mediaPlayer = player
      mediaPlayer.on('stateChange', (state: string) => {
        if (state == 'stopped ' || state == 'initialized') {
          mediaPlayer?.prepare((err: BusinessError) => {
            if (err) {
              console.error('ts sound prepare:Failed to prepare,error message is :' + err.code + "    " + err.message);
            } else {
              console.info('ts sound prepare:Succeeded in preparing');
            }
          });
        } else if (state = 'prepared') {
          mediaPlayer?.play(); // 准备完成后播放
        }

      });
      libentry.setSoundLoadCallback((result: string) => {
        console.error("ts sound load : " + result)
        if (mediaPlayer) {
          if (url == result) {
            return
          }
          url = result
          mediaPlayer.reset(() => {
            if (mediaPlayer) {
              let fd = fileIo.openSync(result).fd
              mediaPlayer.url = `fd://${fd}`
              console.info('ts sound load:' + mediaPlayer.state)
            }
          })
        }
      });
      libentry.setSoundPlayCallback((loop: number) => {
        console.error("ts sound play : " + loop)
        if (mediaPlayer) {
          mediaPlayer.loop = true
          mediaPlayer?.prepare(() => {
            mediaPlayer?.play((err: BusinessError) => {
              if (err) {
                console.error('ts sound play error :' + err.code + "    " + err.message);
              } else {
                console.info('ts sound play success.');
              }
            })
          })
        }
      });
      libentry.setSoundStopCallback(() => {
        console.error("ts sound stop")
        mediaPlayer?.stop()
      });
      libentry.setSoundPauseCallback(() => {
        console.error("ts sound pause")
        mediaPlayer?.pause()
      });
      libentry.setSoundResumeCallback(() => {
        console.error("ts sound resume")
        mediaPlayer?.play()
      });
    });
  }
}

let pixelBufferWidth: number = 0
let pixelBufferHeight: number = 0
let pixelBufferRotate: number = 0
let playerState : PlayerState = PlayerState.PLAYER_NODE
function preparePlayerSource(uri: string, pageData:PageData) {
  let setDataSourceCallback: ICallBack = {
    callBackResult: (code: number) => {
      if (code == 0) {
        let stateCallBack: ICallBack = {
          callBackResult: (state: number) => {
            if(!globalThis.isWorkerActive()) return
            playerState = state

            EventBus.emitEvent(EventType.VideoStateChange,{data:{"state":state}})
            if ((state == PlayerState.PLAYER_STOP)) {
              stopRecordVideo()
            }
          }
        }
        STPlayer.setPlayerCallback(stateCallBack);
        let videoInfo = STPlayer.getVideoInfo();
        //旋转
        if (videoInfo.rotate == 1 || videoInfo.rotate == 3) {
          pixelBufferWidth = videoInfo.height
          pixelBufferHeight = videoInfo.width
        }
        else{
          pixelBufferWidth = videoInfo.width
          pixelBufferHeight = videoInfo.height
        }
        pixelBufferRotate = videoInfo.rotate
        //this.photoAspectRatio = videoInfo.width / videoInfo.height
        let isFirstFrame = true;
        let frameCallBack: IFrameCallBack = {
          callBackResult: (data: ArrayBuffer, width: number, height: number, rotate: number, state: number) => {
            if(!globalThis.isWorkerActive()) return
            originalDecodedPixelBuffer = data.slice(0)
            if (isFirstFrame) {
              libentry.resetPixelReader()
              isFirstFrame = false

              processData = new ProcessData()
              processData.width = width
              processData.height = height
              processData.rotation = rotate
              processData.stride = width
              processData.format = PixelFormat.ST_PIX_FMT_NV21
              processData.pageData = pageData
            }
            processData.buffer = originalDecodedPixelBuffer
            process(processData)
          }
        }
        STPlayer.startPlay(frameCallBack);
        startRecordVideo(pixelBufferWidth, pixelBufferHeight)
      } else {
        EventBus.emitEvent(EventType.ShowMessage,{data:{"message":"解码器不支持该视频，请重新选择视频"}})
      }
    }
  }
  //相册
  let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
  fs.stat(file.fd).then((value) => {
    STPlayer.setPlayerDataSource(uri, file.fd, value.size, setDataSourceCallback);
  });
}

workerPort.onmessageerror = (event: MessageEvents) => {
  console.error('[Camera Worker] onmessageerror:' + event.data);
};

workerPort.onerror = (event: ErrorEvent) => {
  console.error('[Camera Worker] onerror:' + event.message);
};
