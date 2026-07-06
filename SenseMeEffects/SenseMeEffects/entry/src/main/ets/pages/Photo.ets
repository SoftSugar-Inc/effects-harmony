import { componentUtils, display, RectShape, router, window } from '@kit.ArkUI'
import { FilterPanel } from '../panels/FilterPanel'
import libstmobile, {BodyBeautyParam, EffectsMode, PixelFormat, RenderingResizingMode, RotateType,BeautyType,MeshType, HumanActionDetectConfig, HumanActionDetectResult, FaceDetectInfo, BodyDetectInfo, Rect, st_image_t, Point2D } from '@softsugar/mars_effects'
import { CommonConstant as Common } from '../common/CommonConstant'
import { fileIo } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit'
import {  common,
  sendableContextManager } from '@kit.AbilityKit'
import { BusinessError } from '@ohos.base'
import { PanelState, PreviewBottomPanel } from '../panels/PreviewBottomPanel'
import { BeautyPanel } from '../panels/BeautyPanel'
import fs from '@ohos.file.fs';
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager';
import { StickerPanel } from '../panels/StickerPanel';
import { MakeUpPanel } from '../panels/MakeUpPanel';
import { EventBus, EventType } from '../utils/EventBus'
import { STMaterialManager } from '../models/STMaterialManager'
import { DetectType, STCustomEvent } from '../models/native_js_object/DetectType'
import { LoadingView } from '../utils/LoadingView'
import { singletonContext } from '../utils/SingletonContext'
import { MessageEvents, taskpool, worker } from '@kit.ArkTS'
import { CameraData, PageMode } from '../workers/CameraData'
import { Singleton } from '../workers/Singleton'

import { BodyAndGanMaterialFetcherImpl, BodyAndGanMaterialFetcher } from '../networking/BodyAndGanIndex';
import TargetPersonAssociationHelper, { TargetPersonAssociationResult } from '../utils/TargetPersonAssociationHelper'

// 创建实例
const fetcher = new BodyAndGanMaterialFetcherImpl();


@Entry
@Component
struct Photo {
  @State uri: string = (router.getParams() as Map<string, string>)['uri']
  private xcomponentController: XComponentController = new XComponentController();
  private windowTop: number = 0
  private windowBottom: number = 0


  private _originalImageBuffer: ArrayBuffer|undefined
  private originalImageBuffer = (() => {
    return () => {
      if (!this._originalImageBuffer) {
        let file = fileIo.openSync(this.uri, fileIo.OpenMode.READ_ONLY)
        let stat = fileIo.statSync(file.fd)
        this._originalImageBuffer = new ArrayBuffer(stat.size)
        fileIo.readSync(file.fd, this._originalImageBuffer)
        fileIo.closeSync(file)
      }
      return this._originalImageBuffer;
    };
  })()
  private _originImageSource = (() => {
    let imageSource: image.ImageSource
    return () => {
      if (!imageSource) {
        imageSource = image.createImageSource(this.originalImageBuffer())
      }
      return imageSource
    }
  })()

  // 压缩图片相关成员
  private _compressedPixelBuffer: ArrayBuffer | undefined
  private _compressedWidth: number = 0
  private _compressedHeight: number = 0
  private _imageScale: number = 1.0
  private _imageCompressed: boolean = false

  // 预先压缩图片，只执行一次，其他地方直接使用压缩后的数据
  async initCompressedImage() {
    if (this._imageCompressed) {
      return
    }
    let file = fileIo.openSync(this.uri, fileIo.OpenMode.READ_ONLY)
    let stat = fileIo.statSync(file.fd)
    let rawBuffer = new ArrayBuffer(stat.size)
    fileIo.readSync(file.fd, rawBuffer)
    fileIo.closeSync(file)

    // 同时设置原始编码图片 buffer，供 _originImageSource 使用
    this._originalImageBuffer = rawBuffer

    let imageSource = image.createImageSource(rawBuffer)
    let imageInfo = await imageSource.getImageInfo()
    let width = imageInfo.size.width
    let height = imageInfo.size.height

    // 如果图片分辨率大于1080，压缩图片尺寸以降低内存占用
    const MAX_SIZE = 1080
    this._imageScale = 1.0
    if (Math.max(width, height) > MAX_SIZE) {
      this._imageScale = MAX_SIZE / Math.max(width, height)
    }
    this._compressedWidth = Math.floor(width * this._imageScale)
    this._compressedHeight = Math.floor(height * this._imageScale)

    let pixelMap = await imageSource.createPixelMap({
      editable: true,
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
      desiredSize: { width: this._compressedWidth, height: this._compressedHeight },
    })
    this._compressedPixelBuffer = new ArrayBuffer(this._compressedWidth * this._compressedHeight * 4)
    pixelMap.readPixelsToBufferSync(this._compressedPixelBuffer)
    this._imageCompressed = true
    console.info(`initCompressedImage: original=${width}x${height}, compressed=${this._compressedWidth}x${this._compressedHeight}, scale=${this._imageScale}`)
  }


  @State filterPanelVisibility: boolean = false
  @State beautyPanelVisibility: boolean = false
  @State stickerVisiabilty : boolean = false
  @State makeUpVisiabilty : boolean = false
  @State bottomViewVisiablity : boolean = true
  
  // 多人美体检测结果
  // face_id 到 rect 的映射
  private  faceIdMap: Map<number, Rect> = new Map()
  // body id 到 rect 的映射
  private  bodyIdMap: Map<number, Rect> = new Map()

  private faceBodyResult :TargetPersonAssociationResult|null = null
  private isUseFaceMap:boolean = false
  private isShowFaceRectMode =false

  @State faceDrawRects: Rect[] = []
  @State isMultiBody: boolean = false
  @State isMultiImage: boolean = false

  getSelectedId(){
    return Array.from(this.isUseFaceMap? this.faceIdMap.keys() : this.bodyIdMap.keys())[this.selectedFaceIndex]
  }

  // 多人逻辑：选中的人脸索引和参数缓存
  @State selectedFaceIndex: number = -1  // -1 表示未选中


  private cameraData = new CameraData()
  private cameraWorker : worker.ThreadWorker = new worker.ThreadWorker('entry/ets/workers/CameraWorker',{
    priority: 0  // 设置为高优先级
  });

  private bodyBeautyZipPath :string|undefined= undefined
  private bodyBeautyMeshPath :string|undefined= undefined
  loadingView: LoadingView = new LoadingView();
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
            this.cameraData.pageData.isSavePicture = true
            this.processByWorker(false)
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
                this.onXcomponentLoad()
              })
            // 人脸框绘制层
            FaceRectOverlay({
              faceRects: this.faceDrawRects,
              imageWidth: this.getImageWidth(),
              imageHeight: this.getImageHeight(),
              windowTop: this.windowTop,
              windowBottom: this.windowBottom,
              selectedIndex: this.selectedFaceIndex,
              onFaceSelected: (index: number) => {
                this.onFaceSelected(index)
              }
            })
              .width('100%')
              .height('100%')
              .position({ x: 0, y: 0 })
              .visibility(this.isMultiBody ? Visibility.Visible : Visibility.Hidden)
              .zIndex(9999)
          }
        }
        .id('XComponent')
        .width('100%')
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

            //多人模式重置人脸框
            if (this.isMultiBody){
              if (index == 4 && this.isShowFaceRectMode) {
                if (this.isUseFaceMap) {
                  this.faceDrawRects = Array.from(this.faceIdMap.values())
                }else {
                  this.faceDrawRects = Array.from(this.bodyIdMap.values())
                }
              }
              else {
                this.faceDrawRects =  []
              }
            }
          },
          panelState: 1,
        })
          .width('100%')
          .height(264)
          .visibility(this.bottomViewVisiablity ? Visibility.Visible : Visibility.Hidden)
      StickerPanel({
        panelState:PanelState.Photo
      })
          .width('100%')
          .height(300)
          .visibility(this.stickerVisiabilty ? Visibility.Visible : Visibility.Hidden)

      MakeUpPanel({
          panelState: PanelState.Photo,
        })
          .width('100%')
          .height(220)
          .visibility(this.makeUpVisiabilty ? Visibility.Visible : Visibility.Hidden)

      FilterPanel({
          panelState: PanelState.Photo,
        })
          .height(220)
          .width('100%')
          .opacity(0.9)
          .visibility(this.filterPanelVisibility ? Visibility.Visible : Visibility.Hidden)

      BeautyPanel({
          panelState: PanelState.Photo,
          isMultiImage: this.isMultiImage,
        })
          //.height(240)
          .width('100%')
          .visibility(this.beautyPanelVisibility ? Visibility.Visible : Visibility.Hidden)

      //对比按钮
      Image($r('app.media.comparison'))
        .width(30)
        .height(30)
        .onTouch((event) => {
          if (event.type == TouchType.Down) {
            this.processByWorker(true)
          } else if (event.type == TouchType.Up) {
            this.processByWorker(false)
          }
        })
        .position({ right: 10 , bottom : this.stickerVisiabilty ? 300:220})

    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)

  }

  async aboutToAppear(): Promise<void> {
    this.loadingView.showLoading({ msg: '初始化中...', isModal: true });
    BeautyResourceManager.getInstance().updateDataSource()
    this.bottomViewVisiablity = true;

    // 预先压缩图片，其他地方直接使用压缩后的数据
    await this.initCompressedImage()

    // 获取窗口安全区信息
    try {
      const win = await window.getLastWindow(getContext())
      const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      this.windowTop = avoidArea.topRect.height
      this.windowBottom = avoidArea.bottomRect.height
      console.info(`Photo aboutToAppear: windowTop=${this.windowTop}, windowBottom=${this.windowBottom}`)
    } catch (e) {
      console.error(`Photo aboutToAppear: failed to get avoid area, error=${e}`)
    }
  }
  onXcomponentLoad() {
    libstmobile.InitializeByMode(EffectsMode.PHOTO)
    taskpool.execute(InitTask).then(()=>{
      setTimeout(()=>{
        this.loadingView.hide();
        // 多人体检测
        this.performHumanActionDetect()
      },200)
      console.log('onXcomponentLoad init success.')
    }).catch((e: BusinessError) => {
      console.error('onXcomponentLoad init : ' + e)
    })

    const size = this.getUIContext().getComponentUtils().getRectangleById('XComponent').size
    libstmobile.updateWindowSize(size.width, size.height)
    libstmobile.setResizingMode(RenderingResizingMode.AspectFit)

    EventBus.listenEvent(EventType.ProcessRender,()=>{
      this.processByWorker()
    })

    EventBus.listenEvent(EventType.BodyBeautyLock,async (data)=>{
      let isLock = data?.data?.['param'] as boolean
      if (isLock) {
        if (this._originImageSource) {
          if (this.bodyBeautyZipPath){
            libstmobile.setBodyBeauty(BodyBeautyParam.EFFECT_BODY_BEAUTIFY_LOCK_BACKGROUND, this.bodyBeautyZipPath)
            return
          }
          this.loadingView.showLoading({ msg: '设置中...', isModal: true, tmpHUDNum: 0 });


          const localPath = await fetcher.createAndQueryTask(
            this._originImageSource(),
            BodyAndGanMaterialFetcher.TASK_TYPE_BODY_EFFECT,
            1
          );
          if (localPath) {
            console.info('下载完成: ' + localPath);
            this.bodyBeautyZipPath = localPath
            libstmobile.setBodyBeauty(BodyBeautyParam.EFFECT_BODY_BEAUTIFY_LOCK_BACKGROUND, localPath)
          }
          else {
            console.error('下载失败')
            EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"素材获取失败"}})
          }
          this.loadingView.hide();
         /* STMaterialManager.GetInstance().getBodyBeautyMaterial("image/jpeg", this._originImageSource(), BodyBeautyParam.EFFECT_BODY_BEAUTIFY_LOCK_BACKGROUND,(result)=>{

            this.bodyBeautyZipPath = result
            libstmobile.setBodyBeauty(BodyBeautyParam.EFFECT_BODY_BEAUTIFY_LOCK_BACKGROUND, result)
            this.loadingView.hide();
          },(msg)=>{
            console.error('getBodyBeautyMaterial failed : ' + msg)
            this.loadingView.hide();
            EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"素材获取失败"}})
          })*/

        }
      }else {
        libstmobile.setBodyBeauty(BodyBeautyParam.EFFECT_BODY_BEAUTIFY_LOCK_BACKGROUND, "")
      }
    })

    EventBus.listenEvent(EventType.BodyBeautyMesh,async ()=>{
      if (this._originImageSource) {
        if (this.bodyBeautyMeshPath){
          libstmobile.setBodyBeauty(BodyBeautyParam.EFFECT_BODY_BEAUTIFY_BODY_MESH, this.bodyBeautyMeshPath)
          return
        }
        this.loadingView.showLoading({ msg: '设置中...', isModal: true, tmpHUDNum: 0 });

        const localPath = await fetcher.createAndQueryTask(
          this._originImageSource(),
          BodyAndGanMaterialFetcher.TASK_TYPE_BODY_EFFECT,
          16
        );
        if (localPath) {
          console.info('下载完成: ' + localPath);
          this.bodyBeautyMeshPath = localPath
          libstmobile.setBodyBeauty(BodyBeautyParam.EFFECT_BODY_BEAUTIFY_BODY_MESH, localPath)
        }
        else {
          console.error('下载失败')
          EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"素材获取失败"}})
        }
        this.loadingView.hide();

        /*STMaterialManager.GetInstance().getBodyBeautyMaterial("image/jpeg", this._originImageSource(), BodyBeautyParam.EFFECT_BODY_BEAUTIFY_BODY_MESH,(result)=>{

          this.bodyBeautyMeshPath = result
          libstmobile.setBodyBeauty(BodyBeautyParam.EFFECT_BODY_BEAUTIFY_BODY_MESH, result)
          this.loadingView.hide();
        },(msg)=>{
          console.error('getBodyBeautyMaterial failed : ' + msg)
          this.loadingView.hide();
          EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"素材获取失败"}})
        })*/
      }
    })


    
    EventBus.listenEvent(EventType.MultiBodyChange,async (data)=>{
      const isChangeBody = data.data?.['isChangeBody'] as boolean
      this.isMultiBody = isChangeBody
      if (isChangeBody) {
        // 使用 originalImageBuffer 进行 humanActionDetect 检测
        //await this.performHumanActionDetect()
        this.faceDrawRects = []
        setTimeout(()=>{
          if (this.isUseFaceMap) {
            this.faceDrawRects = Array.from(this.faceIdMap.values())
          }
          else {
            this.faceDrawRects = Array.from(this.bodyIdMap.values())
          }
          this.onFaceSelected(0)
        },200)

      }
      else {
        // 清除检测结果和人脸框
        this.faceDrawRects = []
        this.selectedFaceIndex = -1

       /* this.bodyIdMap.forEach((v,k)=>{
          libstmobile.clearBodyBeautyStrengthByBodyId(k)
        })*/
        // this.faceIdMap.forEach((v,k)=>{
        //   libstmobile.clearFaceBeautyStrengthByFaceId(k)
        // })
      }
    })

    EventBus.listenEvent(EventType.OnBeautyModeChange, (data) => {
      const mode = data.data?.['beautyMode'] as string
      if (mode == '美体') {
        this.isShowFaceRectMode = true
        this.isUseFaceMap = false

        if (!this.isMultiBody) {
          return
        }
        let lastFaceId = this.getSelectedId()
        let currentBodyId = -1
        if (this.faceBodyResult) {
          const result = this.faceBodyResult.faceToBodyMap
          currentBodyId = result.get(lastFaceId)|| -1
        }
        this.faceDrawRects = []
        setTimeout(()=>{
          this.faceDrawRects = Array.from(this.bodyIdMap.values())
          if (currentBodyId >= 0) {
            let index = 0
            let foundIndex = -1
            this.bodyIdMap.forEach((value, key) => {
              if (key == currentBodyId) {
                foundIndex = index
                this.onFaceSelected(index)
              }
              index++
            })
          }
          else {
            this.onFaceSelected(0)
          }
        },200)
      }
      else if (mode == '微整形'|| mode == '美形')
      {
        this.isShowFaceRectMode = true
        const isChangeId = !this.isUseFaceMap
        this.isUseFaceMap = true
        if (!this.isMultiBody) {
          return
        }
        let lastBodyId = this.getSelectedId()
        let currentFaceId = -1
        if (this.faceBodyResult) {
          const result = this.faceBodyResult.bodyToFaceMap
          currentFaceId = result.get(lastBodyId)|| -1
        }
        this.faceDrawRects = []
        setTimeout(()=>{
          this.faceDrawRects = Array.from(this.faceIdMap.values())
          if (isChangeId) {
            this.isUseFaceMap = true
            if (currentFaceId >= 0 ) {
              let index = 0
              let foundIndex = -1
              this.faceIdMap.forEach((value, key) => {
                if (key == currentFaceId) {
                  foundIndex = index
                  this.onFaceSelected(index)
                }
                index++
              })
            }
            else {
              this.onFaceSelected(0)
            }
            return
          }
        },200)
      }
      else {
        if (mode != '') {
          this.isShowFaceRectMode = false
        }
        this.faceDrawRects = []
      }
    })



    this.bodyBeautyZipPath = undefined
    this.bodyBeautyMeshPath = undefined

    this.initByWorker()
    Singleton.flag = false
  }

  aboutToDisappear(): void {

    EventBus.unListenEvent(EventType.ProcessRender)
    EventBus.unListenEvent(EventType.BodyBeautyLock)
    EventBus.unListenEvent(EventType.BodyBeautyMesh)
    EventBus.unListenEvent(EventType.MultiBodyChange)
    EventBus.unListenEvent(EventType.OnBeautyModeChange)
    Singleton.flag = true
    this.cameraData.type = "destroy"
    this.cameraWorker.postMessage(this.cameraData)
  }

  // 执行 humanActionDetect 检测（使用预压缩的图片数据）
  async performHumanActionDetect() {
    try {
      if (!this._compressedPixelBuffer) {
        console.error('performHumanActionDetect: compressed image not initialized')
        return
      }
      const stImage: st_image_t = {
        data: this._compressedPixelBuffer,
        pixel_format: PixelFormat.ST_PIX_FMT_RGBA8888,
        width: this._compressedWidth,
        height: this._compressedHeight,
        stride: this._compressedWidth * 4,
        time_stamp: Date.now()
      }
      
      // 检测配置：检测人脸 + 检测肢体

      let  config = libstmobile.getDetectConfig()
      config |= 0x08000000n
      config |= 0x10000000n
      // 调用 humanActionDetect 接口
      const result:HumanActionDetectResult|null = libstmobile.humanActionDetect(stImage, RotateType.ROTATE_0, config, false)

      if (result == null) {
        console.log('humanActionDetect result is null')
        return
      }
      // 保存并打印检测结果
      console.info(`humanActionDetect config :${config}, result: face_count=${result?.face_count}, body_count=${result?.body_count}`)
      
      // 清空缓存
      this.faceIdMap.clear()
      this.bodyIdMap.clear()
      
      // 缓存 face 的 rect 和 id
      if (result && result.faces && result.faces.length > 1) {
        this.isMultiImage = true
        // 提取人脸 Rect 信息
        console.info(`Detected ${result.faces.length} faces:`)
        result.faces.forEach((face: FaceDetectInfo, index: number) => {
          console.info(`  Face ${index}: face_id=${face.face_id}, rect={left:${face.rect.left}, top:${face.rect.top}, right:${face.rect.right}, bottom:${face.rect.bottom}}, score=${face.score}`)
          // 缓存 face_id -> rect（坐标已在压缩图片空间，getImageWidth/Height 也返回压缩尺寸，FaceRectOverlay 映射一致）
          this.faceIdMap.set(face.face_id, face.rect)
        })
        if (this.isUseFaceMap) {
          this.faceDrawRects = []
          setTimeout(()=>{
            this.faceDrawRects = Array.from(this.faceIdMap.values())
          },200)
        }
      } else {
        this.isMultiImage = false
        this.faceDrawRects = []
        this.selectedFaceIndex = -1
        console.info('No faces detected')
      }
      
      // 缓存 body 的 rect 和 id（根据 contourPoints 和 keyPoints 计算）
      if (result && result.bodys && result.bodys.length > 0) {
        console.info(`Detected ${result.bodys.length} bodys:`)
        result.bodys.forEach((body: BodyDetectInfo, index: number) => {
          const keyPoints = body.key_points
          const contourPoints = body.contour_points
          
          // 需要 keyPoints 至少2个点，contourPoints 至少59个点（索引0和58）
          if (!keyPoints || keyPoints.length < 2 || !contourPoints || contourPoints.length < 59) {
            console.info(`  Body ${index}: id=${body.id}, keyPoints or contourPoints insufficient, skip`)
            return
          }
          
          // 宽度由 contourPoints[0] 和 contourPoints[58] 确定
          const width = Math.abs(contourPoints[58].x - contourPoints[0].x)
          // keyPoints[0]、keyPoints[1] 在头部垂直中心轴上，以该轴为中心水平居中框
          const centerX = (keyPoints[0].x + keyPoints[1].x) / 2
          const left = centerX - width / 2
          const right = centerX + width / 2

          const originalTop = keyPoints[0].y
          const originalBottom = keyPoints[1].y
          const centerY = (originalTop + originalBottom) / 2;
          
          const top = centerY - width / 2
          const bottom = centerY + width / 2
          
          const bodyRect: Rect = {
            left: Math.floor(left),
            top: Math.floor(top),
            right: Math.floor(right),
            bottom: Math.floor(bottom)
          }

          // 缓存 body id -> rect
          this.bodyIdMap.set(body.id, bodyRect)
          console.info(`  Body ${index}: id=${body.id}, rect={left:${bodyRect.left}, top:${bodyRect.top}, right:${bodyRect.right}, bottom:${bodyRect.bottom}}, width=${Math.floor(right - left)}, height=${Math.floor(bottom - top)}`)
        })
        if (!this.isUseFaceMap) {
          this.faceDrawRects = []
          setTimeout(()=>{
            this.faceDrawRects = Array.from(this.bodyIdMap.values())
          },200)
        }
        this.faceBodyResult = TargetPersonAssociationHelper.buildAssociations(this.faceIdMap, this.bodyIdMap)
      }
    } catch (error) {
      console.error('humanActionDetect failed:', error)
    }
  }
  initByWorker(){
    this.cameraData.type = "initPhoto"
    this.cameraData.uri = this.uri
    this.cameraData.pageData.mode = PageMode.Photo
    this.cameraData.pageData.isOrigin = false
    this.cameraData.pageData.immediately = true
    this.cameraData.pageData.context = getContext()
    this.cameraWorker.postMessageWithSharedSendable(this.cameraData)

    this.cameraWorker.onmessage = (e :MessageEvents)=>{
      this.isProcess = false
      if (this.isLateUpdate) {
        this.cameraWorker.postMessage(this.cameraData)
        this.mCustomEvent = 0
        this.isProcess = true
        this.isLateUpdate = false
      }
    }
  }
  isProcess = false
  isLateUpdate = false
  processByWorker(isOri:boolean = false) {
    this.cameraData.type = "updateProcess"
    this.cameraData.pageData.mCustomEvent = this.mCustomEvent
    this.cameraData.pageData.isOrigin = isOri
    this.cameraData.pageData.immediately = true
    if (this.isProcess) {
      this.isLateUpdate = true
      return
    }
    this.cameraWorker.postMessage(this.cameraData)
    this.cameraData.pageData.isSavePicture = false
    this.isProcess = true
    this.mCustomEvent = 0
  }
  @State mCustomEvent:number = 0
  
  // 获取图片宽度（压缩后的尺寸，用于人脸框绘制）
  getImageWidth(): number {
    return this._compressedWidth
  }

  // 获取图片高度（压缩后的尺寸，用于人脸框绘制）
  getImageHeight(): number {
    return this._compressedHeight
  }

  // 处理人脸选中事件
  onFaceSelected(index: number) {
    // 切换到新的人脸
    this.selectedFaceIndex = index
    // 通知 BeautyPanel 更新滑动条显示
    EventBus.emitEvent(EventType.SelectedFaceChanged, {data:{'faceIndex': this.getSelectedId()}})
  }
  

  changeCustomEvent(doubleClick:boolean) {
    this.mCustomEvent = libstmobile.getCustomEventConfig();
    if (doubleClick) {
      this.mCustomEvent &= ~STCustomEvent.ST_CUSTOM_EVENT_SCREEN_TAP;
    } else {
      this.mCustomEvent &= ~STCustomEvent.ST_CUSTOM_EVENT_SCREEN_DOUBLE_TAP;
    }
    if (this.mCustomEvent > 0) {
      this.processByWorker(false)
    }
    this.mCustomEvent = 0
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
    libstmobile.addSubModelByPath(subModelPath)
  })

  const bodyModelPath = writeModelToSandbox('M_SenseME_Body_Contour_77_ppl3_1.3.5.model','models_body')
  const result = libstmobile.addSubModelByPath(bodyModelPath)

  const aniModels = resourceManager.getRawFileListSync(`aniModels`)
  aniModels.forEach(model => {
    const subModelPath = writeModelToSandbox(model,'aniModels')
    libstmobile.addAnimalSubModelByPath(subModelPath)
  })
  const ganModels = resourceManager.getRawFileListSync(`gan_model`)
  ganModels.forEach(model => {
    const subModelPath = writeModelToSandbox(model,'gan_model')
    libstmobile.setBeautyPackageByPath(BeautyType.EFFECT_BEAUTY_BASE_FACE_SMOOTH, subModelPath)
  })
  const skinDetailPath = writeModelToSandbox('SDKSkinDetailAssets0924.zip','beauty_materials')
  libstmobile.setBeautyPackageByPath(BeautyType.EFFECT_RESOURCE_EXTERNAL, skinDetailPath)
  const beautyPath = writeModelToSandbox('3DMicroPlasticDefault.zip','beauty_materials')
  libstmobile.setBeautyPackageByPath(BeautyType.EFFECT_BEAUTY_3D_MICRO_PLASTIC, beautyPath)
  libstmobile.updateFaceMeshList(MeshType.ST_MOBILE_FACE_MESH)

  EventBus.emitEvent(EventType.OnModelLoaded)
}

// 人脸框绘制组件
@Component
struct FaceRectOverlay {
  @Prop faceRects: Rect[]
  @Prop imageWidth: number
  @Prop imageHeight: number
  @Prop windowTop: number
  @Prop windowBottom: number
  @Prop selectedIndex: number  // 当前选中的人脸索引，-1表示未选中
  onFaceSelected?: (index: number) => void  // 人脸选中回调


  private getBackgroundColor(index: number) {
    return index === this.selectedIndex ? '#DB77E5': Color.White
  }

  // 角线长度比例（相对于人脸框宽高的比例）
  private readonly CORNER_LENGTH_RATIO: number = 0.25
  // 角线宽度
  private readonly CORNER_THICKNESS: number = 5

  build() {
    Stack() {
      ForEach(this.faceRects, (rect: Rect, index: number) => {
        this.FaceRectCornerBuilder(rect, index)
      }, (rect: Rect, index: number) => index.toString())
    }
    .width('100%')
    .height('100%')
  }

  // 四角扫描框组件构建器
  @Builder
  FaceRectCornerBuilder(rect: Rect, index: number) {
    Stack() {
      // 左上角 - 水平线
      Row()
        .width(`${Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`)
        .height(`${this.CORNER_THICKNESS}px`)
        .backgroundColor(this.getBackgroundColor(index))
        .position({ x: 0, y: 0 })

      // 左上角 - 垂直线
      Row()
        .width(`${this.CORNER_THICKNESS}px`)
        .height(`${Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`)
        .backgroundColor(this.getBackgroundColor(index))
        .position({ x: 0, y: 0 })

      // 右上角 - 水平线
      Row()
        .width(`${Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`)
        .height(`${this.CORNER_THICKNESS}px`)
        .backgroundColor(this.getBackgroundColor(index))
        .position({ x: `${this.getRectWidth(rect) - Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`, y: 0 })

      // 右上角 - 垂直线
      Row()
        .width(`${this.CORNER_THICKNESS}px`)
        .height(`${Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`)
        .backgroundColor(this.getBackgroundColor(index))
        .position({ x: `${this.getRectWidth(rect) - this.CORNER_THICKNESS}px`, y: 0 })

      // 左下角 - 水平线
      Row()
        .width(`${Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`)
        .height(`${this.CORNER_THICKNESS}px`)
        .backgroundColor(this.getBackgroundColor(index))
        .position({ x: 0, y: `${this.getRectHeight(rect) - this.CORNER_THICKNESS}px` })

      // 左下角 - 垂直线
      Row()
        .width(`${this.CORNER_THICKNESS}px`)
        .height(`${Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`)
        .backgroundColor(this.getBackgroundColor(index))
        .position({ x: 0, y: `${this.getRectHeight(rect) - Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px` })

      // 右下角 - 水平线
      Row()
        .width(`${Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`)
        .height(`${this.CORNER_THICKNESS}px`)
        .backgroundColor(this.getBackgroundColor(index))
        .position({ x: `${this.getRectWidth(rect) - Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`, y: `${this.getRectHeight(rect) - this.CORNER_THICKNESS}px` })

      // 右下角 - 垂直线
      Row()
        .width(`${this.CORNER_THICKNESS}px`)
        .height(`${Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px`)
        .backgroundColor(this.getBackgroundColor(index))
        .position({ x: `${this.getRectWidth(rect) - this.CORNER_THICKNESS}px`, y: `${this.getRectHeight(rect) - Math.min(this.getRectWidth(rect), this.getRectHeight(rect)) * this.CORNER_LENGTH_RATIO}px` })
    }
    .width(`${this.getRectWidth(rect)}px`)
    .height(`${this.getRectHeight(rect)}px`)
    .position({
      x: `${this.getDisplayX(rect)}px`,
      y: `${this.getDisplayY(rect)}px`
    })
    .onClick(() => {
      console.info(`FaceRectOverlay: face ${index} clicked`)
      if (this.onFaceSelected) {
        this.onFaceSelected(index)
      }
    })
  }

  // 获取实际渲染高度（屏幕高度减去上下安全区）
  private getActualRenderHeight(): number {
    //const screenHeight = display.getDefaultDisplaySync().height
    //const actualHeight = screenHeight - this.windowTop - this.windowBottom

    const actualHeight = this.getUIContext().getComponentUtils().getRectangleById('XComponent').size.height //通过id获取指定组件
    return actualHeight
  }

  private getActualRenderWidth(): number {
    return display.getDefaultDisplaySync().width
  }

  // 计算缩放比例（AspectFit 模式）
  private getScale(): number {
    const renderWidth = this.getActualRenderWidth()
    const renderHeight = this.getActualRenderHeight()
    if (this.imageWidth <= 0 || this.imageHeight <= 0) {
      return 1
    }
    const imageAspect = this.imageWidth / this.imageHeight
    const renderAspect = renderWidth / renderHeight
    const scale = imageAspect > renderAspect ? renderWidth / this.imageWidth : renderHeight / this.imageHeight
    return scale
  }

  // 计算 X 方向偏移
  private getOffsetX(): number {
    const renderWidth = this.getActualRenderWidth()
    const renderHeight = this.getActualRenderHeight()
    if (this.imageWidth <= 0 || this.imageHeight <= 0) {
      return 0
    }
    const imageAspect = this.imageWidth / this.imageHeight
    const renderAspect = renderWidth / renderHeight
    let offsetX: number
    if (imageAspect > renderAspect) {
      offsetX = 0
    } else {
      const scaledWidth = this.imageWidth * (renderHeight / this.imageHeight)
      offsetX = (renderWidth - scaledWidth) / 2
    }
    return offsetX
  }

  // 计算 Y 方向偏移
  private getOffsetY(): number {
    const renderWidth = this.getActualRenderWidth()
    const renderHeight = this.getActualRenderHeight()
    if (this.imageWidth <= 0 || this.imageHeight <= 0) {
      return 0
    }
    const imageAspect = this.imageWidth / this.imageHeight
    const renderAspect = renderWidth / renderHeight
    let offsetY: number
    if (imageAspect > renderAspect) {
      // 图片较宽，高度有黑边，需要居中偏移
      const scale = renderWidth / this.imageWidth
      const scaledHeight = this.imageHeight * scale
      offsetY = (renderHeight - scaledHeight) / 2
    } else {
      // 图片较高，高度填满，Y 方向无偏移
      offsetY = 0
    }
    return offsetY
  }

  // 转换坐标
  private getDisplayX(rect: Rect): number {
    const scale = this.getScale()
    const offsetX = this.getOffsetX()
    const result = rect.left * scale + offsetX
    return result
  }

  private getDisplayY(rect: Rect): number {
    const scale = this.getScale()
    const offsetY = this.getOffsetY()
    const result = rect.top * scale + offsetY
    return  result
  }

  private getRectWidth(rect: Rect): number {
    const scale = this.getScale()
    const result = (rect.right - rect.left) * scale
    return result
  }

  private getRectHeight(rect: Rect): number {
    const scale = this.getScale()
    const result = (rect.bottom - rect.top) * scale
    return result
  }

}
