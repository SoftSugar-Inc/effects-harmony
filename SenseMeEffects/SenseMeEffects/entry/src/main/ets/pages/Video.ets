import { display, router } from '@kit.ArkUI';
import { FilterPanel } from '../panels/FilterPanel'
import fs from '@ohos.file.fs';
import { image } from '@kit.ImageKit'
import { STPlayer, ICallBack, IFrameCallBack, PlayerState} from '@ohos/stplayer'
import { Permissions, common } from '@kit.AbilityKit'
import PermissionManager from "../utils/Permission"
import libstmobile, { EffectsMode, PixelFormat, RotateType,BeautyParamType } from 'libentry.so'

import {BeautyType} from 'libentry.so'
import { CommonConstant as Common } from '../common/CommonConstant';
import FilterObject from '../models/FilterObject'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import { promptAction } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import {STRecorder} from '@ohos/stplayer'
import { PreviewBottomPanel } from '../panels/PreviewBottomPanel';
import XComponentContext from '../interface/XComponentContext'
import { BeautyPanel } from '../panels/BeautyPanel'
import BeautyObject from '../models/Beauty/BeautyObject';
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager';
import { StickerPanel } from '../panels/StickerPanel';
import { MakeUpPanel } from '../panels/MakeUpPanel';
import { STEffectModel } from '../models/Sticker/STEffectModel';
import { RenderingResizingMode } from 'libentry.so/Index';

const PERMISSIONS: Array<Permissions> = [
  'ohos.permission.READ_MEDIA',
  'ohos.permission.WRITE_MEDIA',
]

const context = getContext() as common.UIAbilityContext
const resourceManager = context.resourceManager
const filesDir = context.filesDir

const decodingOptions: image.DecodingOptions = {
  editable: true,
  desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
}

@Entry
@Component
struct VideoPage {
  @State imagePixelMap?: PixelMap = undefined
  @State uri: string = (router.getParams() as Map<string, string>)['uri']
  private start = Date.now()
  private originalDecodedPixelBuffer: ArrayBuffer | undefined
  private outputArrayBuffer: ArrayBuffer = new ArrayBuffer(1024)
  private pixelBufferWidth: number = 0
  private pixelBufferHeight: number = 0
  private pixelBufferRotate: number = 0
  private curWidth : number = 0
  private curHeight : number = 0
  private  curStride:number = 0

  private bStartRecord: boolean = false
  private cnt = 0
  private lastTime = 0
  private xComponentContext: XComponentContext | undefined = undefined
  private xcomponentController: XComponentController = new XComponentController()
  @State photoAspectRatio: number = 1080.0 / 1920.0
  @State playerState : PlayerState = PlayerState.PLAYER_PLAYING
  @State filterPanelVisibility: boolean = false
  @State beautyPanelVisibility: boolean = false
  @State stickerVisiabilty : boolean = false
  @State makeUpVisiabilty : boolean = false
  @State bottomViewVisiablity : boolean = true
  @State timerVisibility: Visibility = Visibility.Hidden
  textTimerController: TextTimerController = new TextTimerController();
  @State format: string = 'mm:ss';
  private comparing: boolean = false
  private humanActionHandle: ArrayBuffer | undefined

  @State subDataSource: BeautyObject[] | undefined = undefined

  build() {
    Stack() {
      Row() {
        Column() {
          Row() {
            Image($r('app.media.ic_back'))
              .focusable(true)
              .focusOnTouch(true)
              .width(25)
              .height(25)
              .align(Alignment.Start)
              .id('back2Index')
              .margin({ left: 10 })
              .onClick(() => {
                router.back();
              })

            Blank()
              .flexGrow(1)

            Image($r(this.playerState == PlayerState.PLAYER_PLAYING ? 'app.media.video_pause' : 'app.media.video_play'))
              .focusable(true)
              .focusOnTouch(true)
              .width(23)
              .height(23)
              .margin({ right: 30 })
              .onClick(() => {
                if (this.playerState == PlayerState.PLAYER_STOP || this.playerState == PlayerState.PLAYER_NODE) { //none|stop
                  this.preparePlayerSource()
                } else if (this.playerState == PlayerState.PLAYER_PLAYING) { //playing
                  STPlayer.pausePlay()
                } else if (this.playerState == PlayerState.PLAYER_PAUSE) { //pause
                  STPlayer.resumePlay()
                }
              })


            Image($r('app.media.photo_save'))
              .focusable(true)
              .focusOnTouch(true)
              .width(23)
              .height(23)
              .margin({ right: 10 })
              .onClick(() => {
                if(this.playerState != PlayerState.PLAYER_STOP) { //playing
                  promptAction.showToast({ message: '请等待视频播放完成', duration: 1000 })
                } else{
                  this.saveVideo()
                }
              })
          }
          .width('100%')
          .height(44)
          .backgroundColor(Color.White)

          Row() {
            XComponent({
              id: Common.XCOMPONENT_ID,
              type: XComponentType.TEXTURE,
              libraryname: Common.LIBRARY_NAME,
              controller: this.xcomponentController
            })
              .onLoad((xComponentContext) => {
                this.xComponentContext = xComponentContext as XComponentContext;
                this.onXcomponentLoad()
              })
              //.aspectRatio(this.photoAspectRatio)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
      }
      .onClick(()=>{
        this.stickerVisiabilty = false;
        this.makeUpVisiabilty = false;
        this.filterPanelVisibility = false;
        this.beautyPanelVisibility = false;
        this.bottomViewVisiablity = true;
      })
      .height('100%')
      .width('100%')


        PreviewBottomPanel({
          onEntranceClick: (index) => {
            if (index == 0) {
              this.stickerVisiabilty = true
              this.bottomViewVisiablity = !this.stickerVisiabilty
            } else if (index == 1) {
              this.makeUpVisiabilty = true
              this.bottomViewVisiablity = !this.makeUpVisiabilty
            } else if (index == 3) {
              this.filterPanelVisibility = true
              this.bottomViewVisiablity = !this.filterPanelVisibility
            } else if (index == 4) {
              this.beautyPanelVisibility = true
              this.bottomViewVisiablity = !this.beautyPanelVisibility
            }
          },
          type: 0
        })
          .width('100%')
          .height(120)
          .visibility(this.bottomViewVisiablity ? Visibility.Visible : Visibility.Hidden)

        StickerPanel({
          didSelectedMaterial: (model) => {
            const result = libstmobile.changePackageByPath(model.pkgLocalPath)
            model.packageId = result
            if (this.playerState != PlayerState.PLAYER_PLAYING)
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
          },
          didDeselectedMaterial: (model) => {
            const result = libstmobile.removePackage(model.packageId)
            if (this.playerState != PlayerState.PLAYER_PLAYING)
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
          },
          onClearMaterial: (model) => {
            if (model) {
              const result = libstmobile.removePackage(model.packageId)
              if (this.playerState != PlayerState.PLAYER_PLAYING)
                this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
            }
          },
        })
          .width('100%')
          .height(300)
          .visibility(this.stickerVisiabilty ? Visibility.Visible : Visibility.Hidden)

        MakeUpPanel({
          didSelectedMaterial: (model) => {
            const result = libstmobile.setBeautyPackageByPath(model.type, model.pkgLocalPath)
            if (this.playerState != PlayerState.PLAYER_PLAYING)
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
          },
          didDeselectedMaterial: (type) => {
            const result = libstmobile.setBeautyPackageByPath(type, "")
            if (this.playerState != PlayerState.PLAYER_PLAYING)
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
          },
          onMakeUpStrengthChanged: (type, strength) => {
            //染发系数
            if(type == 401){
              strength *= 0.22
            }
            const result = libstmobile.setBeautyStrength(type, strength / 100.0)
            if (this.playerState != PlayerState.PLAYER_PLAYING)
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
          }
        })
          .width('100%')
          .height(220)
          .visibility(this.makeUpVisiabilty ? Visibility.Visible : Visibility.Hidden)

        FilterPanel({
          onFilterSelectedCallback: () => {
            if (this.playerState != PlayerState.PLAYER_PLAYING)
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
          },
          onFilterStrengthChangedCallback: () => {
            if (this.playerState != PlayerState.PLAYER_PLAYING)
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
          },
/*          onFilterCloseCallback: () => {
            this.filterPanelVisibility = false
            this.bottomViewVisiablity = !this.filterPanelVisibility
          }*/
        })
          .height(220)
          .width('100%')
          .opacity(0.9)
          .visibility(this.filterPanelVisibility ? Visibility.Visible : Visibility.Hidden)

        BeautyPanel({
        /*  onBeauSelected: (beauty: BeautyObject) => {
            if (beauty.cleanObject.path.length > 0) {
              let fileContent = resourceManager.getRawFileContentSync('beauties/' + beauty.cleanObject.path)
              const buffer = fileContent.buffer.slice(0);
              libstmobile.setBeautyPackageByBuffer(beauty.cleanObject.type, buffer)
            }
            if (beauty.cleanObject.mode > 0) {
              libstmobile.setBeautyMode(beauty.cleanObject.type, beauty.cleanObject.mode)
            }
            libstmobile.setBeautyParam(BeautyParamType.EFFECT_BEAUTY_PARAM_ENABLE_WHITEN_SKIN_MASK, beauty.cleanObject.need_open_whiten_skin_mask?1:0)
            libstmobile.setBeautyStrength(beauty.cleanObject.type, beauty.currentStrength)
            if (this.playerState != PlayerState.PLAYER_PLAYING){
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
            }
          },*/
          onBeautyFirstChanged:(beauty: BeautyObject)=>{
            if (beauty.cleanObject.path.length > 0) {
              let fileContent = resourceManager.getRawFileContentSync('beauties/' + beauty.cleanObject.path)
              const buffer = fileContent.buffer.slice(0);
              libstmobile.setBeautyPackageByBuffer(beauty.cleanObject.type, buffer)
            }
            else {
              libstmobile.setBeautyPackageByBuffer(beauty.cleanObject.type, null)
            }
            libstmobile.setBeautyMode(beauty.cleanObject.type, beauty.cleanObject.mode)
            libstmobile.setBeautyParam(BeautyParamType.EFFECT_BEAUTY_PARAM_ENABLE_WHITEN_SKIN_MASK, beauty.cleanObject.need_open_whiten_skin_mask?1:0)
          },
          onBeautyStrengthChanged: (beauty: BeautyObject) => {
            libstmobile.setBeautyStrength(beauty.cleanObject.type,  (beauty.currentStrength?beauty.currentStrength:0))
          },
         /* onPanelClose: () => {
            this.beautyPanelVisibility = false
            this.bottomViewVisiablity = !this.beautyPanelVisibility
          },*/
          onResetOrClear: (beauties: BeautyObject[]) => {
            beauties.forEach(element => {
              libstmobile.setBeautyStrength(element.cleanObject.type, element.currentStrength)
            })
            if (this.playerState != PlayerState.PLAYER_PLAYING) {
              this.processAndRender(this.curWidth, this.curHeight,this.curStride, this.pixelBufferRotate, false)
            }
          },
          subDataSource: this.subDataSource
        })
          .height(220)
          .width('100%')
          .visibility(this.beautyPanelVisibility ? Visibility.Visible : Visibility.Hidden)

      //对比按钮
      Image($r('app.media.comparison'))
        .width(30)
        .height(30)
        .onTouch((event) => {
          if (event.type == TouchType.Down) {
            this.comparing = true
          } else if (event.type == TouchType.Up) {
            this.comparing = false
          }
          if (this.playerState != PlayerState.PLAYER_PLAYING) {
            this.processAndRender(this.curWidth, this.curHeight,this.curStride,this.pixelBufferRotate, false, this.comparing)
          }
        })
        .position({ right: 10 , bottom : this.stickerVisiabilty ? 310:230})
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
  }

  showfps():void{
    this.cnt++
    if (this.lastTime == 0) {
      this.lastTime = Date.now()
    } else {
      let currentTime = Date.now()
      let delta = currentTime - this.lastTime
      if (delta >= 1000) {
        console.log(`fps is: ${this.cnt / delta * 1000.0}`)
        this.lastTime = currentTime
        this.cnt = 0
      }
    }
  }

  processAndRender(width:number, height:number, stride:number, rotate:number,isRecord:boolean, isOrigin:boolean=false, immediately:boolean = true): void {
    //let stride = this.pixelBufferWidth > this.pixelBufferHeight ? this.pixelBufferHeight : this.pixelBufferWidth

    if (this.outputArrayBuffer === undefined ||this.outputArrayBuffer.byteLength != this.pixelBufferWidth * this.pixelBufferHeight *  3 / 2) {
      this.outputArrayBuffer = new ArrayBuffer(this.pixelBufferWidth * this.pixelBufferHeight * 3 / 2)
    }
    this.curWidth = width
    this.curHeight = height
    this.curStride = stride
    libstmobile.process(this.originalDecodedPixelBuffer, PixelFormat.ST_PIX_FMT_NV21, width, height, width , rotate,false,0,this.outputArrayBuffer,PixelFormat.ST_PIX_FMT_NV21,0,isOrigin,immediately)
    //this.showfps();
    if (isRecord) {
      let ret = STRecorder.pushVideoFrame(this.outputArrayBuffer, this.pixelBufferWidth,this.pixelBufferHeight)
      if (ret != 0) {
        console.log(`push video frame error ${ret}`);
      }
    }
  }
  aboutToAppear(): void {
    BeautyResourceManager.getInstance().updateDataSource()
    this.subDataSource = BeautyResourceManager.getInstance().dataSource[0].beauties
  }
  onXcomponentLoad() {
    libstmobile.InitializeByMode(EffectsMode.VIDEO)
    //libstmobile.createHandle(4)
    //const modelPath = this.writeModelToSandbox('M_SenseME_Face_Video_Template_p_4.0.0.model')
    //this.humanActionHandle = libstmobile.st_mobile_human_action_create(modelPath, 0x00020000)
    const models = resourceManager.getRawFileListSync(`models`)
    models.forEach(model => {
      const subModelPath = this.writeModelToSandbox(model,'models')
      const result = libstmobile.addSubModelByPath(subModelPath)
    })
    const aniModels = resourceManager.getRawFileListSync(`aniModels`)
    aniModels.forEach(model => {
      const subModelPath = this.writeModelToSandbox(model,'aniModels')
      const result = libstmobile.addAnimalSubModelByPath(subModelPath)
    })

    let displayInfo = display.getDefaultDisplaySync()
    libstmobile.updateWindowSize(displayInfo.width, displayInfo.height)
    libstmobile.setResizingMode(libstmobile.RenderingResizingMode.AspectFit)

    this.preparePlayerSource()
  }

  async setDefaultValue(): Promise<void> {
    try {
      const result: string = await new Promise((resolve: Function) => {
        setTimeout(() => {
          this.setDefaultEffects()
        }, 1000);
      });
    } catch (e) {
      console.error(`Get exception: ${e}`);
    }
  }

  setDefaultEffects(){
    let defaultEffects = BeautyResourceManager.getInstance().defaultEffects
    defaultEffects.forEach((beauty) =>{
      if(beauty != undefined){
        if (beauty.cleanObject.path.length > 0) {
          let fileContent = resourceManager.getRawFileContentSync('beauties/' + beauty.cleanObject.path)
          const buffer = fileContent.buffer.slice(0);
          libstmobile.setBeautyPackageByBuffer(beauty.cleanObject.type, buffer)
        }
        if (beauty.cleanObject.mode > 0) {
          libstmobile.setBeautyMode(beauty.cleanObject.type, beauty.cleanObject.mode)
        }
        libstmobile.setBeautyStrength(beauty.cleanObject.type, beauty.currentStrength)
      }
    })
  }

  private preparePlayerSource() {
    let setDataSourceCallback: ICallBack = {
      callBackResult: (code: number) => {
        if (code == 0) {
          let stateCallBack: ICallBack = {
            callBackResult: (state: number) => {
              this.playerState = state
              if ((state == PlayerState.PLAYER_STOP)) {
                this.stopRecordVideo()
              }
            }
          }
          STPlayer.setPlayerCallback(stateCallBack);
          let videoInfo = STPlayer.getVideoInfo();
          //旋转
          if (videoInfo.rotate == 1 || videoInfo.rotate == 3) {
            this.pixelBufferWidth = videoInfo.height
            this.pixelBufferHeight = videoInfo.width
          }
          else{
            this.pixelBufferWidth = videoInfo.width
            this.pixelBufferHeight = videoInfo.height
          }
          this.pixelBufferRotate = videoInfo.rotate
          //this.photoAspectRatio = videoInfo.width / videoInfo.height
          let isFirstFrame = true;
          let frameCallBack: IFrameCallBack = {
            callBackResult: (data: ArrayBuffer, width: number, height: number, rotate: number, state: number) => {
              this.originalDecodedPixelBuffer = data.slice(0)
              if (isFirstFrame) {
                libstmobile.resetPixelReader()
                isFirstFrame = false
              }
              this.processAndRender(width, height, width, rotate, true, this.comparing, false)
            }
          }
          STPlayer.startPlay(frameCallBack);
          this.startRecordVideo()
        } else {
          this.showDialog('解码器不支持该视频，请重新选择视频')
        }
      }
    }
    //相册
    PermissionManager.requestPermissions(PERMISSIONS).then((permission) => {
      if (permission) {
        let file = fs.openSync(this.uri, fs.OpenMode.READ_ONLY);
        fs.stat(file.fd).then((value) => {
          STPlayer.setPlayerDataSource(this.uri, file.fd, value.size, setDataSourceCallback);
        });
      }
    })
  }

  uint8ArrayToArrayBuffer(uint8Array: Uint8Array) {
    let arrayBuffer = new ArrayBuffer(uint8Array.length);
    let bufferView = new Uint8Array(arrayBuffer);
    bufferView.set(uint8Array);
    return arrayBuffer;
  }


  aboutToDisappear(): void {
    //libstmobile.destroyHandle()
  }

  onPageHide(): void {
    STPlayer.stopPlay();
/*    STPlayer.stopPlay();
    this.stopRecordVideo()*/
  }

  showDialog(message: string) {
    promptAction.showDialog({
      message: message,
      buttons: [
        {
          text: '好的',
          color: '#000000'
        }
      ],
    })
      .then(data => {
        console.info('showDialog success, click button: ' + data.index);
      })
  }

  startRecordVideo() {
    if (this.bStartRecord) return
    this.bStartRecord = true
    let path = getContext(this).cacheDir + "/record.mp4";
    let file: fs.File = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    if (file.fd <= 0) {
      console.error(`create output vidoe path error`)
      return
    }
    let setDataSourceCallback: ICallBack = {
      callBackResult: (code: number) => {
        if (code == 0) {
          let startCallback: ICallBack = {
            callBackResult: (code: number) => {
              if (code == 0) {
                console.log(`STRecorder start record`);
              }
            }
          }
          STRecorder.startRecord(startCallback);
        } else {
          this.showDialog('输出视频路径设置失败')
        }
      }
    }
    STRecorder.setRecorderDataSource("", file.fd, this.pixelBufferWidth, this.pixelBufferHeight, 0, 0, setDataSourceCallback)

  }

  stopRecordVideo() {
    this.bStartRecord = false;
    let fd = STRecorder.stopRecord();
    if (fd > 0) {
      fs.close(fd).then(()=>{
        console.log(fd+"视频保存成功");
      });
    } else {
      this.showDialog(`视频保存失败`)
    }
  }

  saveVideo(){
    let savePath = getContext(this).cacheDir + "/record.mp4";
    let saveFile: fs.File = fs.openSync(savePath, fs.OpenMode.READ_ONLY);
    if(saveFile.fd > 0){
      PermissionManager.requestPermissions(['ohos.permission.WRITE_MEDIA']).then((permission) => {
        if (permission) {
          let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
          let options: photoAccessHelper.CreateOptions = {
            title: Date.now().toString()
          };
          phAccessHelper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', options, (error, videoUri) => {
            if (error) {
              this.showDialog('输出视频路径设置失败')
            } else {
              let file: fs.File = fs.openSync(videoUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
              fs.copyFileSync(saveFile.fd, file.fd)
              fs.close(saveFile.fd)
              fs.close(file.fd)
              promptAction.showToast({ message: 'video save success', duration: 1000 })
            }
          });
        } else {
          this.showDialog('请开启相册视频写入权限')
        }
      })
    }else{
      this.showDialog('保存视频失败')
    }
  }

  writeModelToSandbox(modelName: string, dir:string): string {
    const modelPath = filesDir + '/' + modelName
    if (fs.accessSync(modelPath)) {
      return modelPath;
    }
    const fileContent = resourceManager.getRawFileContentSync(dir + '/' + modelName)
    const fileArrayBuffer = fileContent.buffer.slice(0)
    this.writeBufferToPath(fileArrayBuffer, modelPath)
    return modelPath
  }

  writeBufferToPath(contentBuffer: ArrayBuffer, targetPath: string): void {
    if (fs.accessSync(targetPath)) {
      fs.unlinkSync(targetPath)
    }
    let destFile = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    let writeLength = fs.writeSync(destFile.fd, contentBuffer)
    fs.closeSync(destFile)
  }
}
