
import { CommonConstant as Common } from '../common/CommonConstant';
import libstmobile, { EffectsMode,RotateType, PixelFormat,st_image_t,DetectResult,Rect,st_face_shape_t} from '@softsugar/mars_effects'
import PermissionManager from '../utils/Permission';
import Camera from '../camera/Camera'
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';
import { STDefines } from '../common/STDefines';
import DBManager from '../models/DBJson/DBManager';
import DBUserInfo from '../models/DBJson/DBUserInfo';
import CameraService from '../camera/Camera';

const context = getContext(this) as common.UIAbilityContext;
const filesDir = context.filesDir
const resourceManager = context.resourceManager
@Entry
@Component
struct ScanFacePage {
  @State photoAspectRatio: number = 480.0 / 640.0
  @State promptText:string = "把脸移入圈内"

  @State isScanFace:boolean = false


  private flag: boolean = false


  aboutToDisappear() {
    this.flag = true
    CameraService.beforeChange()
  }

  onXcomponentLoad(): void {
    let result = libstmobile.InitializeByMode(EffectsMode.PREVIEW)
    const model1 = this.writeModelToSandbox(STDefines.MODEL_106,'models')
    const model2 = this.writeModelToSandbox(STDefines.MODEL_NAME_FACE_ATTRIBUTE,'models_attribute')

    result = libstmobile.addSubModelByPath(model1)
    result =  libstmobile.addFaceAttributeModel(model2)

    let displayInfo = display.getDefaultDisplaySync()
    libstmobile.updateWindowSize(displayInfo.width, displayInfo.width /this.photoAspectRatio)
    PermissionManager.requestPermissions(['ohos.permission.CAMERA']).then((permission) => {
      if (permission) {
        this.initCamera();
      }
    })
  }

  async initCamera() {
    await CameraService.initCamera(getContext(),camera.CameraPosition.CAMERA_POSITION_FRONT, { width: 640, height: 480 })
    CameraService.captureOutputDidOutputImage = (nextImage: image.Image) => {
      if (!this.flag) {
        nextImage.getComponent(4, (err: BusinessError, imgComponent: image.Component) => {
          if (err || imgComponent === undefined ||this.flag) {
            nextImage.release();
            return;
          }
          let buffer: ArrayBuffer;
          if (imgComponent.byteBuffer as ArrayBuffer) {
            buffer = imgComponent.byteBuffer
            let width = nextImage.size.width
            let height = nextImage.size.height
            let rotate :RotateType = RotateType.ROTATE_270
            let mirror = true
            let inRotate : RotateType = globalThis.deviceRotate;
            libstmobile.process(buffer, PixelFormat.ST_PIX_FMT_NV21, width, height, width, inRotate,mirror,0,null,PixelFormat.ST_PIX_FMT_NV21,rotate,false,false,0)

            let image_t :st_image_t= {
              data : buffer,
              pixel_format: PixelFormat.ST_PIX_FMT_NV21,
              width:width,
              height:height,
              stride:width,
              time_stamp : 0
            }
            if (!this.isScanFace) {
              let detectResult:DetectResult|null = libstmobile.getDetectResult(image_t, rotate, mirror)
              this.checkFace(detectResult, width, height)
            }

            nextImage.release();
          } else {
            nextImage.release();
            return;
          }
        });
      }
    }
  }

  checkFace(detectResult:DetectResult|null, width:number, height:number){
    if (detectResult) {
      let rect: Rect = detectResult.faceRect
      if(Math.abs((rect.left + rect.right)/2 - width/2) < 40 && Math.abs((rect.top + rect.bottom)/2 - (height/2)) < 40
        && (rect.right - rect.left) > 100 &&  (rect.right - rect.left) < 250){
        if(detectResult.faceYaw < -10){
          this.promptText = "人脸角度偏右"
        }else if(detectResult.faceYaw > 10){
          this.promptText = "人脸角度偏左"
        }else if(detectResult.facePitch < 5){
          this.promptText = "人脸角度偏上"
        }else if(detectResult.facePitch > 15){
          this.promptText = "人脸角度偏下"
        }else {
          this.promptText = "保持脸部在圈内"
          const fileContent = resourceManager.getRawFileContentSync('sticker_face_shape/lianxingface.zip')
          let code =  libstmobile.changePackageByBuffer(fileContent.buffer.slice(0))
          this.isScanFace = true
          let userInfo :DBUserInfo = {
            faceShape: detectResult.faceShape,
            gender: detectResult.gender == 'male' ? 1:0,
            age: Number.parseInt(detectResult.age),
            attractive: Number.parseInt(detectResult.attractive)
          }

          console.log('Detect FaceInfo : faceShape ' + detectResult.faceShape + ', gender ' + detectResult.gender + ', age ' + detectResult.age + ', attractive ' + detectResult.attractive);
          DBManager.Instance().updateUserInfo(userInfo)

          this.flag = true

          router.pushUrl({
            url: "pages/Index", // 目标url
          }, router.RouterMode.Standard, (err) => {
            if (err) {
              console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
              return;
            }
            console.info('Invoke pushUrl succeeded.');
          });

        }
      }else {
        this.promptText = "将人脸移入圈内"
      }
    }
    else {
      this.promptText = "未识别到人脸"
    }
  }

  build() {
    Column(){
      Column(){
        Text('退出')
          .fontSize(16)
          .width(40)
          .padding({right:20})
          .onClick(()=>{
            router.back()
          })
          .textAlign(TextAlign.End)
          .width('100%')
          .height('100%')
      }
      .height('10%')
      .width('100%')

      Stack(){
        XComponent({
          id: Common.XCOMPONENT_ID,
          type: XComponentType.TEXTURE,
          libraryname: Common.LIBRARY_NAME,
        })
          .onLoad(()=>{
            this.onXcomponentLoad()
          })
          .width('100%')
          .height('100%')

        Image($r('app.media.bg_scan_face'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      }
      .height('70%')
      .width('100%')
      Column(){
        Text(this.promptText)
          .fontSize(16)
      }
      .justifyContent(FlexAlign.Center)
      .height('20%')
      .width('100%')
    }
    .width('100%')
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