import Camera from '../camera/Camera'
import { common } from '@kit.AbilityKit';
import PermissionManager from "../utils/Permission"
import XComponentContext from '../interface/XComponentContext';
import { CommonConstant as Common } from '../common/CommonConstant';
import Image from '../interface/types'
import Logger from '../utils/Logger'
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import { componentUtils, display, router } from '@kit.ArkUI'
import libstmobile, { EffectsMode, PixelFormat, BeautyParamType} from 'libentry.so'
import { BeautyType } from 'libentry.so'
import { RotateType } from 'libentry.so'
import { promptAction } from '@kit.ArkUI'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import FilterObject from '../models/FilterObject'
// import BeautyCleanObject from '../models/BeautyCleanObject'
import { FilterPanel } from '../panels/FilterPanel'
import { BeautyPanel } from '../panels/BeautyPanel'
import { PreviewBottomPanel } from '../panels/PreviewBottomPanel'
import sensor from "@ohos.sensor"
import { camera } from '@kit.CameraKit';
import { STRecorder, ICallBack } from '@ohos/stplayer'
import BeautyObject from '../models/Beauty/BeautyObject';
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager';
import { StickerPanel } from '../panels/StickerPanel';
import { MakeUpPanel } from '../panels/MakeUpPanel';
import { EffectMode, STDefines } from '../common/STDefines';
import { DetectType } from '../models/native_js_object/HumanAction';


const context = getContext(this) as common.UIAbilityContext;
const filesDir = context.filesDir
const resourceManager = context.resourceManager

let TAG: string = "CameraPreview"


enum Resolution {
  r1920x1080 = 0,
  r1280x720 = 1
}

@Entry
@Component
struct CameraPreview {
  @State private cameraInstance: Camera = new Camera();
  @State photoAspectRatio: number = 1080.0 / 1920.0
  private flag: boolean = false
  private snapshoting: boolean = false
  @State isRecording: boolean = false
  private comparing: boolean = false
  private outputArrayBuffer: ArrayBuffer | undefined
  private curRotate: RotateType = RotateType.ROTATE_0
  private cnt = 0
  private lastTime = 0
  private selectedPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_FRONT
  private resolutions: Array<camera.Size> = [{ width: 1920, height: 1080 }, { width: 1280, height: 720 }]
  private selectedResolution: Resolution = Resolution.r1280x720
  private recordPath = getContext(this).cacheDir + "/record.mp4";
  @State filterPanelVisibility: boolean = false
  @State beautyPanelVisibility: boolean = false
  @State stickerVisiabilty : boolean = false
  @State makeUpVisiabilty : boolean = false
  @State bottomViewVisiablity : boolean = true
  @State resolutionResource: Resource = $r('app.media.preview_resolution_720')
  private recordCtr: boolean = false
  private humanActionHandle: ArrayBuffer | undefined
  @State subDataSource: BeautyObject[] | undefined = undefined

  private isPageHide = false;
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

            Image(this.resolutionResource)
              .focusable(true)
              .focusOnTouch(true)
              .width(30)
              .height(30)
              .margin({ right: 10 })
              .onClick(() => {
                this.cameraInstance.beforeChange().then(() => {
                  this.selectedResolution =
                    this.selectedResolution == Resolution.r1920x1080 ? Resolution.r1280x720 : Resolution.r1920x1080
                  this.resolutionResource =
                    this.selectedResolution == Resolution.r1920x1080 ? $r('app.media.preview_resolution_1080') :
                    $r('app.media.preview_resolution_720')
                  const resolution = this.resolutions[this.selectedResolution]
                  this.photoAspectRatio = resolution.height / resolution.width
                  let displayInfo = display.getDefaultDisplaySync()
                  libstmobile.updateWindowSize(displayInfo.width, displayInfo.width /this.photoAspectRatio)
                  this.initCamera(this.selectedPosition, resolution)
                }).catch((error: BusinessError) => {
                })
              })

            Blank()
              .width(50)

            Image($r('app.media.preview_flip'))
              .focusable(true)
              .focusOnTouch(true)
              .width(23)
              .height(23)
              .margin({ right: 10 })
              .onClick(() => {
                this.cameraInstance.beforeChange().then(() => {
                  this.selectedPosition = this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_BACK ?
                  camera.CameraPosition.CAMERA_POSITION_FRONT : camera.CameraPosition.CAMERA_POSITION_BACK
                  this.initCamera(this.selectedPosition, this.resolutions[this.selectedResolution])
                  if (this.isRecording) {
                    this.stopRecordVideo()
                  }
                }).catch((error: BusinessError) => {
                  console.log(`@camera change error: ${error}`)
                })
              })
          }
          .width('100%')
          .height(44)
          .backgroundColor(Color.White)

          Stack({ alignContent: Alignment.Top }) {
            XComponent({
              id: Common.XCOMPONENT_ID,
              type: XComponentType.TEXTURE,
              libraryname: Common.LIBRARY_NAME,
            })
              .onLoad(()=>{
                this.onXcomponentLoad()
              })
              .width('100%')
              .aspectRatio(this.photoAspectRatio)
          }
        }
        .width('100%')
      }
      .onClick(()=>{
        this.stickerVisiabilty = false;
        this.makeUpVisiabilty = false;
        this.filterPanelVisibility = false;
        this.beautyPanelVisibility = false;
        this.bottomViewVisiablity = true;
      })
      .height('100%')
      PreviewBottomPanel({
          onSnapshotClick: () => {
            PermissionManager.requestPermissions(['ohos.permission.WRITE_MEDIA']).then((permission) => {
              if (permission) {
                this.snapshoting = true
                libstmobile.resetPixelReader()
              }
            })
          },
          onEntranceClick: (index) => {
            if (index == 0){
              this.stickerVisiabilty = true
              this.bottomViewVisiablity = !this.stickerVisiabilty
            }else if(index == 1) {
              this.makeUpVisiabilty = true
              this.bottomViewVisiablity = !this.makeUpVisiabilty
            }else if (index == 3) {
              this.filterPanelVisibility = true
              this.bottomViewVisiablity = !this.filterPanelVisibility
            } else if (index == 4) {
              this.beautyPanelVisibility = true
              this.bottomViewVisiablity = !this.beautyPanelVisibility
            }

          },
          onRecorrOnClick: () => {
            this.startRecordVideo()
            libstmobile.resetPixelReader()
          },
          onRecorrOffClick: () => {
            this.stopRecordVideo()
          },
          onStopRecorrOnClick: () => {
            if (this.isRecording) {
              this.recordCtr = false
              this.stopRecordVideo()
            }
          },
          isRecording: this.isRecording
        })
          .width('100%')
          .height(120)
          .visibility(this.bottomViewVisiablity ? Visibility.Visible : Visibility.Hidden)
      StickerPanel({
          didSelectedMaterial: (model) => {
            const result = libstmobile.changePackageByPath(model.pkgLocalPath)

            let trigger = libstmobile.getTriggerActions()
            let detectConfig =  libstmobile.getDetectConfig()
            if (trigger != 0) {
              this.showTrigger(trigger)
            }
            else{
              this.showTrigger(detectConfig)
            }

            model.packageId = result
          },
          didDeselectedMaterial: (model) => {
            const result = libstmobile.removePackage(model.packageId)
          },
          onClearMaterial: (model) => {
            if (model) {
              const result = libstmobile.removePackage(model.packageId)
            }
          },
          /*,
          onStickerClose: (close) => {
            this.stickerVisiabilty = false
            this.bottomViewVisiablity = !this.stickerVisiabilty
          }*/
        })
          .width('100%')
          .height(300)
          .visibility(this.stickerVisiabilty ? Visibility.Visible : Visibility.Hidden)
      MakeUpPanel({
          didSelectedMaterial: (model) => {
            const result = libstmobile.setBeautyPackageByPath(model.type, model.pkgLocalPath)
          },
          didDeselectedMaterial: (type) => {
            const result = libstmobile.setBeautyPackageByPath(type, "")
          },
          /*  onMakeUpClose: (close) => {
              this.makeUpVisiabilty = false
              this.bottomViewVisiablity = !this.stickerVisiabilty
            },*/
          onMakeUpStrengthChanged: (type, strength) => {
            //染发系数
            if(type == 401){
              strength *= 0.22
            }
            const result = libstmobile.setBeautyStrength(type, strength / 100.0)
          }
        })
          .width('100%')
          .height(220)
          .visibility(this.makeUpVisiabilty ? Visibility.Visible : Visibility.Hidden)
      FilterPanel({
        })
          .height(220)
          .width('100%')
          .visibility(this.filterPanelVisibility ? Visibility.Visible : Visibility.Hidden)
      BeautyPanel({
         /* onBeauSelected: (beauty: BeautyObject) => {
            if (beauty.cleanObject.path.length > 0) {
              let fileContent = resourceManager.getRawFileContentSync('beauties/' + beauty.cleanObject.path)
              const buffer = fileContent.buffer.slice(0);
              libstmobile.setBeautyPackageByBuffer(beauty.cleanObject.type, buffer)
            }
            if (beauty.cleanObject.mode > 0) {
              libstmobile.setBeautyMode(beauty.cleanObject.type, beauty.cleanObject.mode)
            }
            libstmobile.setBeautyParam(BeautyParamType.EFFECT_BEAUTY_PARAM_ENABLE_WHITEN_SKIN_MASK, beauty.cleanObject.need_open_whiten_skin_mask?1:0)
            libstmobile.setBeautyStrength(beauty.cleanObject.type, (beauty.currentStrength?beauty.currentStrength:0))
          },*/

          //fix 70907
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
          onResetOrClear: (beauties: BeautyObject[]) => {
            beauties.forEach(element => {
              libstmobile.setBeautyStrength(element.cleanObject.type, element.currentStrength)
            })
          },
          subDataSource:this.subDataSource
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
        })
        .position({ right: 10 , bottom : this.stickerVisiabilty ? 310:230})
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
  }


  async initCamera(cameraPosition: camera.CameraPosition, resolution: camera.Size) {
    await this.cameraInstance.initCamera(cameraPosition, resolution)
    this.cameraInstance.captureOutputDidOutputImage = (nextImage: image.Image) => {
      this.cnt++
      if (this.lastTime == 0) {
        this.lastTime = Date.now()
      } else {
        let currentTime = Date.now()
        let delta = currentTime - this.lastTime
        if (delta >= 1000) {
          this.lastTime = currentTime
          this.cnt = 0
        }
      }
      if (!this.flag) {
        nextImage.getComponent(4, (err: BusinessError, imgComponent: image.Component) => {
          if (err || imgComponent === undefined) {
            nextImage.release();
            return;
          }
          let buffer: ArrayBuffer;
          if (imgComponent.byteBuffer as ArrayBuffer) {
            buffer = imgComponent.byteBuffer
            let width = nextImage.size.width
            let height = nextImage.size.height
            let rotate =
              (this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_FRONT) ? RotateType.ROTATE_270 :
              RotateType.ROTATE_90
            let mirror = (this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_FRONT) ? true : false

            let bufferSize = this.snapshoting?nextImage.size.width * nextImage.size.height * 4:nextImage.size.width * nextImage.size.height * 3/2
            if (this.outputArrayBuffer === undefined ||
                this.outputArrayBuffer.byteLength != bufferSize){
              this.outputArrayBuffer = new ArrayBuffer(bufferSize)
            }
            let inRotate : RotateType = globalThis.deviceRotate;
            if (this.selectedPosition != camera.CameraPosition.CAMERA_POSITION_FRONT){
              inRotate = ((4 - inRotate)%4) as RotateType
            }
            //this.comparing =true
            let isDst = this.isRecording || this.snapshoting
            let outFormat = this.snapshoting? PixelFormat.ST_PIX_FMT_RGBA8888 : PixelFormat.ST_PIX_FMT_NV21
            libstmobile.process(buffer, PixelFormat.ST_PIX_FMT_NV21, width, height, width, inRotate,mirror,0,isDst?this.outputArrayBuffer:null,outFormat,rotate,this.comparing,false)
            if (this.isRecording) {
              let ret = STRecorder.pushVideoFrame(this.outputArrayBuffer, height, width)
              if (ret != 0) {
                console.log(`push video frame error ${ret}`);
              }
            }
            if (this.snapshoting) {
              this.snapshoting = false
              let pixelBuffer = new Uint8Array(this.outputArrayBuffer)
              this.myAsyncFunction(pixelBuffer, nextImage.size.height, nextImage.size.width)
            }
            nextImage.release();
          } else {
            nextImage.release();
            return;
          }
        });
      } else {
        nextImage.release();
      }
    }
  }

  uint8ArrayToArrayBuffer(uint8Array: Uint8Array) {
    let arrayBuffer = new ArrayBuffer(uint8Array.length);
    let bufferView = new Uint8Array(arrayBuffer);
    bufferView.set(uint8Array);
    return arrayBuffer;
  }

  myAsyncFunction(pixelBuffer: Uint8Array, width: number, height: number): Promise<void> {
    return new Promise((resolve: Function) => {
       for (let index = 0; index < width * height * 4; index += 4) {
         let temp = pixelBuffer[index];
         pixelBuffer[index] = pixelBuffer[index+2];
         pixelBuffer[index+2] = temp;
       }

      image.createPixelMap(this.uint8ArrayToArrayBuffer(pixelBuffer), {
        size: { width, height },
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        editable: true
      }).then((pixelMap) => {
        this.savePixelMapToAlbum(pixelMap)
      }).catch((error: BusinessError) => {
        console.log(`@createPixelMap error ${error}`)
      })
    });
  }

  async onPageShow() {
    let param = router.getParams() as Record<string, string>

    this.stickerVisiabilty = param.mode == STDefines.effectStringResource[EffectMode.Sticker];
    this.makeUpVisiabilty = param.mode == STDefines.effectStringResource[EffectMode.Makeup];
    this.filterPanelVisibility = param.mode == STDefines.effectStringResource[EffectMode.Filter];
    this.beautyPanelVisibility = param.mode == STDefines.effectStringResource[EffectMode.Beauty];
    this.bottomViewVisiablity = param.mode == "";
    if (this.isPageHide) {
      this.initCamera(this.selectedPosition, this.resolutions[this.selectedResolution])
      this.isPageHide = false;
    }
  }
  onPageHide(): void {
    if (this.isRecording) {
      this.stopRecordVideo()
    }
    this.isPageHide = true;
    //this.cameraInstance.stop()
  }
  aboutToAppear(): void {
    BeautyResourceManager.getInstance().updateDataSource()
    this.subDataSource = BeautyResourceManager.getInstance().dataSource[0].beauties
    this.setDefaultValue()
 }
  onXcomponentLoad(): void {
    let result = libstmobile.InitializeByMode(EffectsMode.PREVIEW)
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
    libstmobile.updateWindowSize(displayInfo.width, displayInfo.width /this.photoAspectRatio)
    PermissionManager.requestPermissions(['ohos.permission.CAMERA']).then((permission) => {
      if (permission) {
        this.initCamera(this.selectedPosition, this.resolutions[this.selectedResolution]);
      }
    })
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

  aboutToDisappear() {
    this.flag = true
    this.cameraInstance.beforeChange()
    libstmobile.makeEmpty()
    //libstmobile.st_mobile_human_action_destroy(this.humanActionHandle)
  }

  savePixelMapToAlbum(pixelMap: PixelMap): void {
    // encode image
    let imagePacker = image.createImagePacker()
    let packOpts: image.PackingOption = { format: "image/jpeg", quality: 98 };
    imagePacker.packing(pixelMap, packOpts).then((outputArrayBuffer) => {
      promptAction.showToast({ message: 'saving' })
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      // Creating a Media File
      phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', (error, uri) => {
        if (error) {
          promptAction.showToast({
            message: `create asset error ${JSON.stringify(error)}`,
            duration: 1000
          })
        } else {
          // Open the created media file and read the local file and convert it to ArrayBuffer for easy filling.
          let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE)
          // Write the read ArrayBuffer to the new media file.
          let writeLen = fileIo.writeSync(file.fd, outputArrayBuffer)
          promptAction.showToast({ message: 'save success', duration: 1000 })
          fileIo.closeSync(file)
        }
      })
    }).catch((error: BusinessError) => {
      console.error('Failed to pack the image. And the error is: ' + error);
    })
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
            let setDataSourceCallback: ICallBack = {
              callBackResult: (code: number) => {
                if (code == 0) {
                  let startCallback: ICallBack = {
                    callBackResult: (code: number) => {
                      if (code == 0) {
                        this.isRecording = true;
                      }
                    }
                  }
                  STRecorder.startRecord(startCallback);
                } else {
                  this.showDialog('输出视频路径设置失败')
                }
              }
            }
            const resolution = this.resolutions[this.selectedResolution]
            STRecorder.setRecorderDataSource(this.recordPath, file.fd, resolution.height, resolution.width,0,0,
              setDataSourceCallback)
          }
        });
      } else {
        this.showDialog('请开启相册视频写入权限')
      }
    })
  }

  stopRecordVideo() {
    this.isRecording = false;
    let fd = STRecorder.stopRecord();
    if (fd != 0) {
      fs.close(fd).then((error) => {
        if (error == null) {
          promptAction.showToast({ message: 'video save success', duration: 1000 })
        } else {
          promptAction.showToast({ message: 'video save failure', duration: 1000 })
        }
      })
    } else {
      this.showDialog(`视频保存失败`)
    }
  }

  getDeviceOrientation(): Promise<number> {
    return new Promise((resolve: Function, reject: Function) => {
      let orientation = 3
      sensor.once(sensor.SensorId.ORIENTATION, (data: sensor.OrientationResponse) => {
        if (data.gamma >= 70) {
          orientation = 2
        } else if (data.gamma <= -70) {
          orientation = 0
        } else if (data.gamma <= 10 && data.gamma >= -10) {
          if (data.beta >= 70) {
            orientation = 1
          } else if (data.beta <= -70) {
            orientation = 3
          }
        }
        resolve(orientation)
      })
    })
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

  private customDialogComponentId: number = 0
  showTrigger(actionNum: number){
    let triggerTips = ""
    let triggerIcon = ""
    if((actionNum & DetectType.ST_MOBILE_EYE_BLINK) > 0){
      triggerIcon = 'app.media.ic_trigger_blink'
      triggerTips += "请眨眨眼"
    }
    if((actionNum & DetectType.ST_MOBILE_MOUTH_AH) > 0){
      triggerIcon = 'app.media.ic_trigger_mouth'
      triggerTips += "请张张嘴"
    }
    if((actionNum & DetectType.ST_MOBILE_HEAD_YAW) > 0){
      triggerIcon = 'app.media.ic_trigger_shake'
      triggerTips += "请摇摇头"
    }
    if((actionNum & DetectType.ST_MOBILE_HEAD_PITCH) > 0){
      triggerIcon = 'app.media.ic_trigger_nod'
      triggerTips += "请点点头"
    }
    if((actionNum & DetectType.ST_MOBILE_BROW_JUMP) > 0){
      triggerIcon = 'app.media.ic_trigger_frown'
      triggerTips += "请挑挑眉"
    }
    if((actionNum & DetectType.ST_MOBILE_FACE_LIPS_UPWARD) > 0){
      triggerIcon = 'app.media.ic_trigger_lips_upward'
      triggerTips += "嘴角上扬"
    }
    if((actionNum & DetectType.ST_MOBILE_FACE_LIPS_POUTED) > 0){
      triggerIcon = 'app.media.ic_trigger_lips_pouted'
      triggerTips += "请嘟嘴"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_PALM) > 0){
      triggerIcon = 'app.media.ic_trigger_palm_selected'
      triggerTips += "请伸手掌"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_LOVE) > 0){
      triggerIcon = 'app.media.ic_trigger_heart_hand_selected'
      triggerTips += "请爱心手势"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_HOLDUP) > 0){
      triggerIcon = 'app.media.ic_trigger_palm_up_selected'
      triggerTips += "请托个手"
    }

    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_CONGRATULATE) > 0){
      triggerIcon = 'app.media.ic_trigger_congratulate_selected'
      triggerTips += "请抱个拳"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_FINGER_HEART) > 0){
      triggerIcon = 'app.media.ic_trigger_finger_heart_selected'
      triggerTips += "请单手比心"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_GOOD) > 0){
      triggerIcon = 'app.media.ic_trigger_thumb_selected'
      triggerTips += "大拇指"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_OK) > 0){
      triggerIcon = 'app.media.ic_trigger_ok_selected'
      triggerTips += "请亮出OK手势"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_SCISSOR) > 0){
      triggerIcon = 'app.media.ic_trigger_scissor_selected'
      triggerTips += "请比个剪刀手"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_PISTOL) > 0){
      triggerIcon = 'app.media.ic_trigger_pistol_selected'
      triggerTips += "请伸出食指"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_FINGER_INDEX) > 0){
      triggerIcon = 'app.media.ic_trigger_one_finger_selected'
      triggerTips += "请亮出666手势"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_FIST) > 0){
      triggerIcon = 'app.media.ic_trigger_first_selected'
      triggerTips += "请举起拳头"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_666) > 0){
      triggerIcon = 'app.media.ic_trigger_sixsixsix_selected'
      triggerTips += "请亮出666手势"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_BLESS) > 0){
      triggerIcon = 'app.media.ic_trigger_handbless_selected'
      triggerTips += "请双手合十"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_ILOVEYOU) > 0){
      triggerIcon = 'app.media.ic_trigger_love_selected'
      triggerTips += "请亮出我爱你手势"
    }
    if(triggerIcon == "") return;
    promptAction.openCustomDialog({
      builder: () => {
        this.customDialogBuilder(triggerIcon,triggerTips)
      },
      backgroundColor:Color.Transparent,
      width:200,
      height:40,
      alignment:DialogAlignment.Bottom,
      offset:{dx:0, dy: -300}

    }).then((dialogId: number) => {
      this.customDialogComponentId = dialogId
    })
    setTimeout(()=>{
      promptAction.closeCustomDialog(this.customDialogComponentId)
    },3000)
  }

  //trigger dialog
  @Builder
  customDialogBuilder(icon:string, message:string) {
    Row() {
      Image($r(icon)).width('64px').height('64px')
      Blank().width(10)
      Text(message).fontSize(18).fontColor(Color.White)
    }
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.Transparent)
  }
}
