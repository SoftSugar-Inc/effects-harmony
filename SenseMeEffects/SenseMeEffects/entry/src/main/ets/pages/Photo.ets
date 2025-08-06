import { display, router } from '@kit.ArkUI'
import { FilterPanel } from '../panels/FilterPanel'
import libstmobile, { EffectsMode, PixelFormat, RenderingResizingMode, RotateType,BeautyParamType } from 'libentry.so'
import { BeautyType } from 'libentry.so'
import FilterObject from '../models/FilterObject'
import { CommonConstant as Common } from '../common/CommonConstant'
import XComponentContext from '../interface/XComponentContext'
import { fileIo } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager, common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { BusinessError } from '@ohos.base'
import PermissionManager from "../utils/Permission"
import { PreviewBottomPanel } from '../panels/PreviewBottomPanel'
import { BeautyPanel } from '../panels/BeautyPanel'
import BeautyObject from '../models/Beauty/BeautyObject';
import fs from '@ohos.file.fs';
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager';
import { StickerPanel } from '../panels/StickerPanel';
import { MakeUpPanel } from '../panels/MakeUpPanel';
import { EffectMode, STDefines } from '../common/STDefines'

const PERMISSIONS: Array<Permissions> = [
 'ohos.permission.READ_MEDIA',
 'ohos.permission.WRITE_MEDIA',
  //'ohos.permission.WRITE_IMAGEVIDEO'
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
struct Photo {
  @State uri: string = (router.getParams() as Map<string, string>)['uri']
  private xcomponentController: XComponentController = new XComponentController();
  private xComponentContext: XComponentContext | undefined = undefined;
  private _originalImageBuffer = (() => {
    let value: ArrayBuffer
    return () => {
      if (!value) {
        let file = fileIo.openSync(this.uri, fileIo.OpenMode.READ_ONLY)
        let stat = fileIo.statSync(file.fd)
        value = new ArrayBuffer(stat.size)
        fileIo.readSync(file.fd, value)
        fileIo.closeSync(file)
      }
      return value;
    };
  })()
  private _originImageSource = (() => {
    let imageSource: image.ImageSource
    return () => {
      if (!imageSource) {
        imageSource = image.createImageSource(this._originalImageBuffer())
      /*  imageSource.createPixelMap(decodingOptions).then((pixelMap) => {
          this.outputPixelMap = pixelMap
        })*/
      }
      return imageSource
    }
  })()
  private outputPixelMap: image.PixelMap | undefined
  //private origingalPixelMap: image.PixelMap | undefined
  private originalImageInfo: image.ImageInfo | undefined
  private originalDecodedPixelBuffer: ArrayBuffer | undefined
  @State filterPanelVisibility: boolean = false
  @State beautyPanelVisibility: boolean = false
  @State stickerVisiabilty : boolean = false
  @State makeUpVisiabilty : boolean = false
  @State bottomViewVisiablity : boolean = true
  private humanActionHandle: ArrayBuffer | undefined
  @State subDataSource: BeautyObject[] | undefined = undefined

  private isProcess = false
  build() {
    Stack() {
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

        Image($r('app.media.photo_save'))
          .focusable(true)
          .focusOnTouch(true)
          .width(23)
          .height(23)
          .margin({ right: 10 })
          .onClick(() => {
            PermissionManager.requestPermissions(PERMISSIONS).then((permission) => {
              if (permission) {
                if (this.outputPixelMap) {
                  this.savePixelMapToAlbum(this.outputPixelMap)
                }
              }
            })
          })
      }
      .zIndex(100)
      .position({top:0})
      .width('100%')
      .height(44)
      .backgroundColor(Color.White)
      Row() {
        Column() {
          Stack({ alignContent: Alignment.Top }) {
            XComponent({
              id: Common.XCOMPONENT_ID,
              type: XComponentType.TEXTURE,
              libraryname: Common.LIBRARY_NAME,
              controller: this.xcomponentController
            })
              .onLoad((xComponentContext) => {
                this.xComponentContext = xComponentContext as XComponentContext;
                this.onXcomponentLoad()
              })// .width('100%')// .height('95%')
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
          }
        })
          .width('100%')
          .height(120)
          .visibility(this.bottomViewVisiablity ? Visibility.Visible : Visibility.Hidden)
      StickerPanel({
          didSelectedMaterial: (model) => {
            const result = libstmobile.changePackageByPath(model.pkgLocalPath)
            model.packageId = result
            this.processAndRender()
          },
          didDeselectedMaterial: (model) => {
            const result = libstmobile.removePackage(model.packageId)
            this.processAndRender()
          },
          onClearMaterial: (model) => {
            if (model) {
              const result = libstmobile.removePackage(model.packageId)
              this.processAndRender()
            }
          },
        })
          .width('100%')
          .height(300)
          .visibility(this.stickerVisiabilty ? Visibility.Visible : Visibility.Hidden)

      MakeUpPanel({
          didSelectedMaterial: (model) => {
            const result = libstmobile.setBeautyPackageByPath(model.type, model.pkgLocalPath)
            this.processAndRender()
          },
          didDeselectedMaterial: (type) => {
            const result = libstmobile.setBeautyPackageByPath(type, "")
            this.processAndRender()
          },
          onMakeUpStrengthChanged:(type, strength)=>{
            //染发系数
            if(type == 401){
              strength *= 0.22
            }
            const result = libstmobile.setBeautyStrength(type, strength / 100.0)
            this.processAndRender()
          }
        })
          .width('100%')
          .height(220)
          .visibility(this.makeUpVisiabilty ? Visibility.Visible : Visibility.Hidden)

      FilterPanel({
          onFilterSelectedCallback: () => {
            this.processAndRender()
          },
          onFilterStrengthChangedCallback: () => {
            this.processAndRender()
          }/*,
          onFilterCloseCallback: () => {
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
            this.processAndRender()
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

          let imageInfo = this.originalImageInfo
          let decodedPixelBuffer = this.originalDecodedPixelBuffer
          if (imageInfo && decodedPixelBuffer && !this.isProcess ) {
            this.isProcess = true
            libstmobile.processASync(decodedPixelBuffer, PixelFormat.ST_PIX_FMT_RGBA8888, imageInfo.size.width, imageInfo.size.height,
              imageInfo.size.width *4, RotateType.ROTATE_0,false, 0, null, PixelFormat.ST_PIX_FMT_RGBA8888,RotateType.ROTATE_0,false,true).then(()=>{
                this.isProcess = false
            })
          }
          //this.processAndRender()
        },
          onResetOrClear: (beauties: BeautyObject[]) => {
            beauties.forEach(element => {
              libstmobile.setBeautyStrength(element.cleanObject.type, element.currentStrength)
            })
            this.processAndRender()
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
            if (this.originalDecodedPixelBuffer && this.originalImageInfo) {
              libstmobile.process(this.originalDecodedPixelBuffer, PixelFormat.ST_PIX_FMT_RGBA8888, this.originalImageInfo.size.width, this.originalImageInfo.size.height
                , this.originalImageInfo.size.width *4, RotateType.ROTATE_0,false,0,null,  PixelFormat.ST_PIX_FMT_RGBA8888,RotateType.ROTATE_0,true,true)
            }
          } else if (event.type == TouchType.Up) {
            this.processAndRender()
          }
        })
        .position({ right: 10 , bottom : this.stickerVisiabilty ? 310:230})
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)

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
  setDefaultEffects() {
    let defaultEffects = BeautyResourceManager.getInstance().defaultEffects
    defaultEffects.forEach((beauty) => {
      if (beauty != undefined) {
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

  aboutToAppear(): void {
    BeautyResourceManager.getInstance().updateDataSource()
    this.subDataSource = BeautyResourceManager.getInstance().dataSource[0].beauties
    this.setDefaultValue()
    this.bottomViewVisiablity = true;
  }
  onXcomponentLoad() {
    libstmobile.InitializeByMode(EffectsMode.PHOTO)
    //libstmobile.createHandle(2)
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
    libstmobile.setResizingMode(RenderingResizingMode.AspectFit)


    let imageSource = this._originImageSource()
    imageSource.getImageInfo().then((imageInfo) => {
      this.originalImageInfo = imageInfo

      imageSource.createPixelMap(decodingOptions).then((pixelMap) => {
        this.outputPixelMap = pixelMap
        let width = imageInfo.size.width
        let height = imageInfo.size.height
        this.originalDecodedPixelBuffer = new ArrayBuffer(width * height * 4);
        pixelMap.readPixelsToBuffer(this.originalDecodedPixelBuffer).then(() => {
          this.processAndRender()
        })
      })
    })

    imageSource.getImageProperty(image.PropertyKey.ORIENTATION).then((orientation) => {
    }).catch((error: BusinessError) => {
      console.log(`@error occured ${JSON.stringify(error)}`)
    })
  }

  aboutToDisappear(): void {
    this.outputPixelMap?.release();

    libstmobile.makeEmpty()
  }

  processAndRender() {
    let imageInfo = this.originalImageInfo
    let decodedPixelBuffer = this.originalDecodedPixelBuffer
    if (imageInfo && decodedPixelBuffer) {
      libstmobile.process(decodedPixelBuffer, PixelFormat.ST_PIX_FMT_RGBA8888, imageInfo.size.width, imageInfo.size.height, imageInfo.size.width *4, RotateType.ROTATE_0,false, 0, null, PixelFormat.ST_PIX_FMT_RGBA8888,RotateType.ROTATE_0,false,true)
    }
  }

  savePixelMapToAlbum(pixelMap: PixelMap): void {
    let imageInfo = this.originalImageInfo
    let decodedPixelBuffer = this.originalDecodedPixelBuffer

    libstmobile.resetPixelReader()
    if (imageInfo && decodedPixelBuffer) {
      let outputPixelBuffer = new ArrayBuffer(imageInfo.size.width*imageInfo.size.height* 4)
      let result = libstmobile.process(decodedPixelBuffer, PixelFormat.ST_PIX_FMT_RGBA8888, imageInfo.size.width, imageInfo.size.height, imageInfo.size.width *4, RotateType.ROTATE_0,false, 0, outputPixelBuffer, PixelFormat.ST_PIX_FMT_RGBA8888,RotateType.ROTATE_0,false,true)
      if (result) {
        if (this.outputPixelMap) {
          this.outputPixelMap.writeBufferToPixels(outputPixelBuffer)
        }
      }
    }


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
          let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE)
          let writeLen = fileIo.writeSync(file.fd, outputArrayBuffer)
          promptAction.showToast({ message: 'save success', duration: 1000 })
          fileIo.closeSync(file)
        }
      })
    }).catch((error: BusinessError) => {
      console.error('Failed to pack the image. And the error is: ' + error);
    })
  }

  writeModelToSandbox(modelName: string ,dir:string): string {
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