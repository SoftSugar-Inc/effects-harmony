import { display, router } from '@kit.ArkUI';
import { FilterPanel } from '../panels/FilterPanel'
import fs from '@ohos.file.fs';
import { image } from '@kit.ImageKit'
import { PlayerState} from 'stplayer'
import { Permissions, common, sendableContextManager } from '@kit.AbilityKit'
import libstmobile, { EffectsMode, RenderingResizingMode, MeshType, } from '@softsugar/mars_effects'

import {BeautyType} from '@softsugar/mars_effects'
import { CommonConstant as Common } from '../common/CommonConstant';
import { promptAction } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { PanelState, PreviewBottomPanel } from '../panels/PreviewBottomPanel';
import { BeautyPanel } from '../panels/BeautyPanel'
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager';
import { StickerPanel } from '../panels/StickerPanel';
import { MakeUpPanel } from '../panels/MakeUpPanel';
import { EventBus, EventType } from '../utils/EventBus';
import { STCustomEvent } from '../models/native_js_object/DetectType';
import { MessageEvents, taskpool, worker } from '@kit.ArkTS';
import { singletonContext } from '../utils/SingletonContext';
import { LoadingView } from '../utils/LoadingView';

import { CameraData, PageMode } from '../workers/CameraData';
import { ViewData } from '../workers/ViewData';
import { Singleton } from '../workers/Singleton';


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

  private xcomponentController: XComponentController = new XComponentController()
  @State photoAspectRatio: number = 1080.0 / 1920.0
  @State playerState : PlayerState = PlayerState.PLAYER_PLAYING
  @State filterPanelVisibility: boolean = false
  @State beautyPanelVisibility: boolean = false
  @State stickerVisiabilty : boolean = false
  @State makeUpVisiabilty : boolean = false
  @State bottomViewVisiablity : boolean = true
  private comparing: boolean = false
  loadingView: LoadingView = new LoadingView();

  private cameraData = new CameraData()
  private cameraWorker : worker.ThreadWorker = new worker.ThreadWorker('entry/ets/workers/CameraWorker',{
    priority: 0  // 设置为高优先级
  });

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
                  this.initByWorker()
                } else if (this.playerState == PlayerState.PLAYER_PLAYING) { //playing
                  this.changeVideoStateByWorker(PlayerState.PLAYER_PAUSE)
                } else if (this.playerState == PlayerState.PLAYER_PAUSE) { //pause
                  this.changeVideoStateByWorker(PlayerState.PLAYER_PLAYING)
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
                  this.cameraData.type = 'saveRecordVideo'
                  this.cameraWorker.postMessage(this.cameraData)
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
                this.onXcomponentLoad()
              })
              //.aspectRatio(this.photoAspectRatio)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .priorityGesture(
          TapGesture({ count: 2 })
            .onAction(() => {
              this.changeCustomEvent(true)
            }))
      }
      .onClick(()=>{
        this.stickerVisiabilty = false;
        this.makeUpVisiabilty = false;
        this.filterPanelVisibility = false;
        this.beautyPanelVisibility = false;
        this.bottomViewVisiablity = true;

        this.changeCustomEvent(false)

        EventBus.emitEvent(EventType.OnXComponentClick)
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
          panelState: 0,
        })
          .width('100%')
          .height(264)
          .visibility(this.bottomViewVisiablity ? Visibility.Visible : Visibility.Hidden)

        StickerPanel({
          panelState:PanelState.Video
        })
          .width('100%')
          .height(300)
          .visibility(this.stickerVisiabilty ? Visibility.Visible : Visibility.Hidden)

        MakeUpPanel({
          panelState: PanelState.Video,
        })
          .width('100%')
          .height(220)
          .visibility(this.makeUpVisiabilty ? Visibility.Visible : Visibility.Hidden)

        FilterPanel({
          panelState: PanelState.Video,
        })
          .height(220)
          .width('100%')
          .opacity(0.9)
          .visibility(this.filterPanelVisibility ? Visibility.Visible : Visibility.Hidden)

        BeautyPanel({
          panelState: PanelState.Video,
        })
          .height(240)
          .width('100%')
          .visibility(this.beautyPanelVisibility ? Visibility.Visible : Visibility.Hidden)

      //对比按钮
      Image($r('app.media.comparison'))
        .width(30)
        .height(30)
        .onTouch((event) => {
          if (event.type == TouchType.Down) {
            this.comparing = true
            if (this.playerState != PlayerState.PLAYER_PLAYING) {
              this.processByWorker(true)
            }
          } else if (event.type == TouchType.Up) {
            this.comparing = false
            if (this.playerState != PlayerState.PLAYER_PLAYING) {
              this.processByWorker(false)
            }
          }

        })
        .position({ right: 10 , bottom : this.stickerVisiabilty ? 310:230})
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    this.loadingView.showLoading({ msg: '初始化中...', isModal: true });
    BeautyResourceManager.getInstance().updateDataSource()
    Singleton.flag = false
  }

  aboutToDisappear(): void {
    EventBus.unListenEvent(EventType.ProcessRender)
    EventBus.unListenEvent(EventType.VideoStateChange)
    this.changeVideoStateByWorker(PlayerState.PLAYER_STOP)
    Singleton.flag = true
    this.cameraData.type = "destroy"
    this.cameraWorker.postMessage(this.cameraData)
  }
  onXcomponentLoad() {
    libstmobile.InitializeByMode(EffectsMode.VIDEO)
    taskpool.execute(InitTask).then(()=>{
      this.initByWorker()

      setTimeout(()=>{
        this.loadingView.hide();
      },200)
      console.log('onXcomponentLoad init success.')
    }).catch((e: BusinessError) => {
      console.error('onXcomponentLoad init : ' + e)
    })

    let displayInfo = display.getDefaultDisplaySync()
    libstmobile.updateWindowSize(displayInfo.width, displayInfo.height)
    libstmobile.setResizingMode(RenderingResizingMode.AspectFit)

    EventBus.listenEvent(EventType.ProcessRender,()=>{
      if (this.playerState != PlayerState.PLAYER_PLAYING) {
        this.processByWorker(false)
      }
    })

    EventBus.listenEvent(EventType.VideoStateChange,(message)=>{
      if (message.data) {
        this.playerState = message.data['state']
      }
    })

  }
  initByWorker(){
    this.cameraData.type = "initVideo"
    this.cameraData.uri = this.uri
    this.cameraData.pageData.mode = PageMode.Video
    this.cameraData.pageData.isOrigin = false
    this.cameraData.pageData.immediately = true
    this.cameraData.pageData.context = getContext()
    this.cameraWorker.postMessageWithSharedSendable(this.cameraData)

    this.cameraWorker.onmessage = (e :MessageEvents)=>{
      this.cameraData.type = "updatePageData"
      this.cameraData.pageData.mCustomEvent = this.mCustomEvent
      this.cameraData.pageData.isOrigin = this.comparing
      this.cameraData.pageData.immediately = false
      this.cameraWorker.postMessage(this.cameraData)
      this.mCustomEvent = 0
    }
  }

  processByWorker(isOri:boolean = false) {
    this.cameraData.type = "updateProcess"
    this.cameraData.pageData.mCustomEvent = this.mCustomEvent
    this.cameraData.pageData.isOrigin = isOri
    this.cameraData.pageData.immediately = true
    this.cameraWorker.postMessage(this.cameraData)
    this.mCustomEvent = 0
  }

  changeVideoStateByWorker(videoState:PlayerState){
    this.cameraData.type = "changeVideoState"
    this.cameraData.pageData.changeVideoState = videoState
    this.cameraWorker.postMessage(this.cameraData)
  }


  @State mCustomEvent:number = 0
  changeCustomEvent(doubleClick:boolean) {
    this.mCustomEvent = libstmobile.getCustomEventConfig();
    if (doubleClick) {
      this.mCustomEvent &= ~STCustomEvent.ST_CUSTOM_EVENT_SCREEN_TAP;
    } else {
      this.mCustomEvent &= ~STCustomEvent.ST_CUSTOM_EVENT_SCREEN_DOUBLE_TAP;
    }
    if (this.mCustomEvent > 0 && this.playerState != PlayerState.PLAYER_PLAYING) {
      this.processByWorker(false)
    }
  }

}
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

  const bodyModelPath = writeModelToSandbox('M_SenseME_Body_Contour_77_ppl3_1.3.5.model','models_body')
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
