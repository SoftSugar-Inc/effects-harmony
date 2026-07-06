import Camera from '../camera/Camera'
import { common, sendableContextManager } from '@kit.AbilityKit';
import PermissionManager from "../utils/Permission"
import { CommonConstant as Common } from '../common/CommonConstant';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import {  display, router } from '@kit.ArkUI'
import libstmobile, { EffectsMode, PixelFormat, BeautyParamType,MeshType, st_effect_3D_beauty_part_info_t} from '@softsugar/mars_effects'
import { BeautyType } from '@softsugar/mars_effects'

import { FilterPanel } from '../panels/FilterPanel'
import { BeautyPanel } from '../panels/BeautyPanel'
import { PanelState, PreviewBottomPanel } from '../panels/PreviewBottomPanel'
import { camera } from '@kit.CameraKit';
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager';
import { StickerPanel } from '../panels/StickerPanel';
import { MakeUpPanel } from '../panels/MakeUpPanel';
import { TryOnPanel } from '../panels/TryOnPanel';
import { HomeParam, HomeType, STDefines } from '../common/STDefines';
import { DetectType, STCustomEvent } from '../models/native_js_object/DetectType';
import DBManager from '../models/DBJson/DBManager';
import { EventBus, EventType } from '../utils/EventBus';
import { singletonContext } from '../utils/SingletonContext';
import { MessageEvents, taskpool, ThreadWorkerPriority, worker } from '@kit.ArkTS';
import { VideoRecordPanel } from '../panels/VideoRecordPanel';
import { CameraData, PageMode } from '../workers/CameraData';
import { Singleton } from '../workers/Singleton';
import { ViewData } from '../workers/ViewData';
import { LoadingView } from '../utils/LoadingView';


const context = getContext(this) as common.UIAbilityContext;
const filesDir = context.filesDir
const resourceManager = context.resourceManager

let TAG: string = "CameraPreview"


enum Resolution {
  r1920x1080 = 0,
  r1280x720 = 1
}

// 底部面板类型枚举 - 使用位掩码支持多面板组合显示
enum BottomPanelType {
  NONE = 0,
  BOTTOM = 1 << 0,     // 底部主面板 (1)
  STICKER = 1 << 1,    // 贴纸面板 (2)
  MAKEUP = 1 << 2,     // 美妆面板 (4)
  FILTER = 1 << 3,     // 滤镜面板 (8)
  BEAUTY = 1 << 4,     // 美颜面板 (16)
  RECORD = 1 << 5,     // 录制面板 (32)
  TRYON = 1 << 6       // 试穿面板 (64)
}

@Entry
@Component
struct CameraPreview {
  @State photoAspectRatio: number = 1080.0 / 1920.0
  private comparing: boolean = false

  private selectedPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_FRONT
  private resolutions: Array<camera.Size> = [{ width: 1920, height: 1080 }, { width: 1280, height: 720 }]
  private selectedResolution: Resolution = Resolution.r1280x720
  // 使用位掩码管理面板状态，支持多面板组合显示
  @State currentPanels: number = BottomPanelType.BOTTOM

  // 辅助方法：检查面板是否显示
  private isPanelVisible(panel: BottomPanelType): boolean {
    return (this.currentPanels & panel) !== 0
  }

  // 辅助方法：显示单个面板（与底部主面板互斥）
  private showPanel(panel: BottomPanelType): void {
    // 录制面板独占
    if (panel === BottomPanelType.RECORD) {
      this.currentPanels = BottomPanelType.RECORD
      return
    }
    // 底部主面板与其他子面板互斥
    if (panel === BottomPanelType.BOTTOM) {
      this.currentPanels = BottomPanelType.BOTTOM
      return
    }
    // 子面板：隐藏底部主面板，显示当前子面板
    this.currentPanels = (this.currentPanels & ~BottomPanelType.BOTTOM) | panel
  }

  // 辅助方法：隐藏底部主面板并显示子面板（保持原有子面板显示状态）
  private showSubPanel(panel: BottomPanelType): void {
    this.currentPanels = (this.currentPanels & ~BottomPanelType.BOTTOM) | panel
  }

  @State resolutionResource: Resource = $r('app.media.preview_resolution_720')

  loadingView: LoadingView = new LoadingView();

  private cameraData = new CameraData()
  private cameraWorker : worker.ThreadWorker = new worker.ThreadWorker('entry/ets/workers/CameraWorker',{
    priority: 0  // 设置为高优先级
  });
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
                this.selectedResolution =
                  this.selectedResolution == Resolution.r1920x1080 ? Resolution.r1280x720 : Resolution.r1920x1080
                this.resolutionResource =
                  this.selectedResolution == Resolution.r1920x1080 ? $r('app.media.preview_resolution_1080') :
                  $r('app.media.preview_resolution_720')
                const resolution = this.resolutions[this.selectedResolution]
                this.photoAspectRatio = resolution.height / resolution.width
                let displayInfo = display.getDefaultDisplaySync()
                libstmobile.updateWindowSize(displayInfo.width, displayInfo.width /this.photoAspectRatio)

                this.changeCameraByWorker()
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
                this.selectedPosition = this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_BACK ?
                camera.CameraPosition.CAMERA_POSITION_FRONT : camera.CameraPosition.CAMERA_POSITION_BACK
                this.changeCameraByWorker()
              })
          }
          .width('100%')
          .height(44)
          .backgroundColor(Color.White)
          .visibility(this.isPanelVisible(BottomPanelType.RECORD) ? Visibility.Hidden : Visibility.Visible)

          Stack({ alignContent: Alignment.Top }) {
            XComponent({
              id: Common.XCOMPONENT_ID,
              type: XComponentType.TEXTURE,
              libraryname: Common.LIBRARY_NAME,
            })
              .onLoad(()=>{
                this.onXcomponentLoad()
              })
              .onDestroy(()=>{
                // 不在这里释放,由 aboutToDisappear 统一处理
              })
              .backgroundColor(Color.Black)
              .width('100%')
              .aspectRatio(this.photoAspectRatio)
          }
        }
        .width('100%')
      }
      .priorityGesture(
        TapGesture({ count: 2 })
          .onAction(() => {
            this.changeCustomEvent(true)
          }),
      )
      .onClick(()=>{
        if (!this.isPanelVisible(BottomPanelType.TRYON)) {
          // 重置为主面板（关闭所有子面板）
          this.currentPanels = BottomPanelType.BOTTOM
        }
        this.changeCustomEvent(false)
        EventBus.emitEvent(EventType.OnXComponentClick)
      })
      .height('100%')
      if (this.isPanelVisible(BottomPanelType.RECORD)){
        VideoRecordPanel({
          onRecordSaveClick: () => {
            this.saveRecordVideo()
          },
          onRecordDeleteClick: () => {
            this.deleteRecordVideo()
          },
          onRecordStopClick: () => {
            this.stopRecordVideo()
          },
        })
          .width('100%')
          .height('100%')
      }

      PreviewBottomPanel({
          onSnapshotClick: () => {
            this.cameraData.pageData.isSavePicture = true
          },
          onEntranceClick: (index) => {
            // 根据索引切换到对应子面板
            // 原逻辑：只设置当前子面板，不关闭其他子面板
            const panelMap: Record<number, BottomPanelType> = {
              0: BottomPanelType.STICKER,
              1: BottomPanelType.MAKEUP,
              3: BottomPanelType.FILTER,
              4: BottomPanelType.BEAUTY
            }
            if (panelMap[index] !== undefined) {
              this.showSubPanel(panelMap[index])
            }
          },
          onRecordOnClick: ()=>{
            this.startRecordVideo()
          },
          panelState : 2
        })
          .width('100%')
          .height(264)
          .visibility(this.isPanelVisible(BottomPanelType.BOTTOM) ? Visibility.Visible : Visibility.Hidden)
      StickerPanel({
        panelState:PanelState.Preview
      })
        .margin({bottom : 0})
          .width('100%')
          .height(300)
          .visibility(this.isPanelVisible(BottomPanelType.STICKER) ? Visibility.Visible : Visibility.Hidden)
      MakeUpPanel({
          panelState: PanelState.Preview,
        })
          .width('100%')
          .height(220)
          .visibility(this.isPanelVisible(BottomPanelType.MAKEUP) ? Visibility.Visible : Visibility.Hidden)
      FilterPanel({
          panelState: PanelState.Preview,
        })
          .height(220)
          .width('100%')
          .visibility(this.isPanelVisible(BottomPanelType.FILTER) ? Visibility.Visible : Visibility.Hidden)
      BeautyPanel({
          panelState: PanelState.Preview,
        })
          .height(240)
          .width('100%')
          .visibility(this.isPanelVisible(BottomPanelType.BEAUTY) ? Visibility.Visible : Visibility.Hidden)
      TryOnPanel({
        onSnapshotClick: () => {
          this.cameraData.pageData.isSavePicture = true
        },
        })
          .height(220)
          .width('100%')
          .visibility(this.isPanelVisible(BottomPanelType.TRYON) ? Visibility.Visible : Visibility.Hidden)
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
        .visibility(this.isPanelVisible(BottomPanelType.RECORD) ? Visibility.Hidden : Visibility.Visible)
        .position({ right: 10 , bottom : this.isPanelVisible(BottomPanelType.STICKER) ? 310 : 230})
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  changeCameraByWorker(){

    this.cameraData.type = 'changeCamera'
    this.cameraData.pageData.context = getContext()
    this.cameraData.cameraPosition =  this.selectedPosition
    this.cameraData.cameraWidth = this.resolutions[this.selectedResolution].width
    this.cameraData.cameraHeight = this.resolutions[this.selectedResolution].height
    this.cameraWorker.postMessageWithSharedSendable(this.cameraData)
  }
  initCameraByWorker(){
    this.cameraData.type = 'initCamera'
    this.cameraData.pageData.mode = PageMode.Preview
    this.cameraData.cameraPosition =  this.selectedPosition
    this.cameraData.cameraWidth = this.resolutions[this.selectedResolution].width
    this.cameraData.cameraHeight = this.resolutions[this.selectedResolution].height
    this.cameraData.pageData.context = getContext()

    this.cameraWorker.postMessageWithSharedSendable(this.cameraData)

    this.cameraWorker.onmessage = (e :MessageEvents)=>{
      if(Singleton.flag ) return
      let data = e.data as ViewData
      //this.viewData = data
      this.cameraData.type = "updatePageData"
      this.cameraData.pageData.mCustomEvent = this.mCustomEvent
      this.cameraData.pageData.isOrigin = this.comparing
      this.cameraData.pageData.immediately = false

      this.cameraWorker.postMessage(this.cameraData)
      this.cameraData.pageData.isSavePicture = false
      this.mCustomEvent = 0
    }
  }
  releaseCameraByWorker(){
    this.cameraData.type = 'releaseCamera'
    this.cameraWorker.postMessageWithSharedSendable(this.cameraData)
    this.cameraWorker.terminate()
  }

  async onPageShow() {
    if (this.isPageHide) {
      this.changeCameraByWorker()
      this.isPageHide = false;
    }
  }
  onPageHide(): void {
    this.stopRecordVideo()
    this.isPageHide = true;
  }
  aboutToAppear(): void {
    this.loadingView.showLoading({ msg: '初始化中...', isModal: true });

    BeautyResourceManager.getInstance().updateDataSource()

    if (globalThis.homeParam) {
      // 根据入口类型设置初始面板（与原逻辑一致：只有一个面板显示）
      switch (globalThis.homeParam.type) {
        case HomeType.Sticker:
        case HomeType.Avatar:
          this.currentPanels = BottomPanelType.STICKER
          break
        case HomeType.Makeup:
          this.currentPanels = BottomPanelType.MAKEUP
          break
        case HomeType.Filter:
          this.currentPanels = BottomPanelType.FILTER
          break
        case HomeType.Beauty:
        case HomeType.Body:
          this.currentPanels = BottomPanelType.BEAUTY
          break
/*        case HomeType.TryOn:
          this.currentPanels = BottomPanelType.TRYON
          break*/
        case HomeType.All:
        case HomeType.Style:
        default:
          this.currentPanels = BottomPanelType.BOTTOM
          break
      }
    }

 }
  onXcomponentLoad(): void {

    // // 加载通用模型->加载GAN模型->加载3D微整形素材->恢复效果
    let result = libstmobile.InitializeByMode(EffectsMode.PREVIEW)
    taskpool.execute(InitTask).then(()=>{
      setTimeout(()=>{
        this.loadingView.hide();
      },200)
      console.log('onXcomponentLoad init success.')
    }).catch((e: BusinessError) => {
      this.loadingView.hide();
      console.error('onXcomponentLoad init : ' + e)
    })

    let displayInfo = display.getDefaultDisplaySync()
    libstmobile.updateWindowSize(displayInfo.width, displayInfo.width /this.photoAspectRatio)

    Singleton.flag = false
    PermissionManager.requestPermissions(['ohos.permission.CAMERA']).then((permission) => {
      if (permission) {
        this.initCameraByWorker()
      }
    })
  }

  aboutToDisappear() {
    DBManager.Instance().save()
    Singleton.flag = true
    this.releaseCameraByWorker();
  }

  startRecordVideo() {
    // 录制面板独占显示
    this.currentPanels = BottomPanelType.RECORD

    this.cameraData.type = 'startRecordVideo'
    this.cameraWorker.postMessage(this.cameraData)
  }

  stopRecordVideo() {
    this.cameraData.type = 'stopRecordVideo'
    this.cameraWorker.postMessage(this.cameraData)

  }
  saveRecordVideo() {
    this.currentPanels = BottomPanelType.BOTTOM

    this.cameraData.type = 'saveRecordVideo'
    this.cameraWorker.postMessage(this.cameraData)
  }
  deleteRecordVideo() {
    this.currentPanels = BottomPanelType.BOTTOM
  }

  @State mCustomEvent:number = 0
  changeCustomEvent(doubleClick:boolean) {
    this.mCustomEvent = libstmobile.getCustomEventConfig();
    if (doubleClick) {
      this.mCustomEvent &= ~STCustomEvent.ST_CUSTOM_EVENT_SCREEN_TAP;
    } else {
      this.mCustomEvent &= ~STCustomEvent.ST_CUSTOM_EVENT_SCREEN_DOUBLE_TAP;
    }
  }

}
//trigger dialog


@Concurrent
async function InitTask() {
  let context: common.Context = sendableContextManager.convertToContext(singletonContext.getContext())
  let resourceManager = context.resourceManager
  let filesDir = context.filesDir

  let writeModelToSandbox = (modelName: string, dir:string)=>{
    const modelPath = filesDir + '/' + modelName
    if (fs.accessSync(modelPath)) {
      return modelPath;
    }
    const fileContent = resourceManager.getRawFileContentSync(dir + '/' + modelName)
    const fileArrayBuffer = fileContent.buffer.slice(0)
    writeBufferToPath(fileArrayBuffer, modelPath)
    return modelPath
  }

  let writeBufferToPath = (contentBuffer: ArrayBuffer, targetPath: string)=> {
    if (fs.accessSync(targetPath)) {
      fs.unlinkSync(targetPath)
    }
    let destFile = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    let writeLength = fs.writeSync(destFile.fd, contentBuffer)
    fs.closeSync(destFile)
  }

  const models = resourceManager.getRawFileListSync(`models`)
  models.forEach(model => {
    const subModelPath = writeModelToSandbox(model,'models')
    const result = libstmobile.addSubModelByPath(subModelPath)
  })

  const bodyModelPath = writeModelToSandbox('M_SenseME_Body_Contour_77_p_1.5.0.model','models_body')
  const result = libstmobile.addSubModelByPath(bodyModelPath)

  const aniModels = resourceManager.getRawFileListSync(`aniModels`)
  aniModels.forEach(model => {
    const subModelPath = writeModelToSandbox(model,'aniModels')
    const result = libstmobile.addAnimalSubModelByPath(subModelPath)
  })
  const ganModels = resourceManager.getRawFileListSync(`gan_model`)
  ganModels.forEach(model => {
    const subModelPath = writeModelToSandbox(model,'gan_model')
    const result = libstmobile.setBeautyPackageByPath(BeautyType.EFFECT_BEAUTY_BASE_FACE_SMOOTH, subModelPath)
  })
  const skinDetailPath = writeModelToSandbox('SDKSkinDetailAssets0924.zip','beauty_materials')
  libstmobile.setBeautyPackageByPath(BeautyType.EFFECT_RESOURCE_EXTERNAL, skinDetailPath)
  const beautyPath = writeModelToSandbox('3DMicroPlasticDefault.zip','beauty_materials')
  libstmobile.setBeautyPackageByPath(BeautyType.EFFECT_BEAUTY_3D_MICRO_PLASTIC, beautyPath)
  libstmobile.updateFaceMeshList(MeshType.ST_MOBILE_FACE_MESH)

  EventBus.emitEvent(EventType.OnModelLoaded)
}
