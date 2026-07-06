import { STEffectModel } from '../models/Sticker/STEffectModel'
import { STListItem } from '../models/STListItem'
import { CellState } from '../models/STMaterial'
import { STMaterialManager } from '../models/STMaterialManager'
import { StickerCell } from './StickerCell'
import { ListItemCell, Item } from './ListItemCell'

import libstmobile,{ st_image_t, PixelFormat,EffectParam, HumanActionParam}  from '@softsugar/mars_effects'
import { media } from '@kit.MediaKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit'
import fileIo from '@ohos.file.fs'
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager'
import { HomeType,HomeParam, STDefines } from '../common/STDefines'
import { fileUri, picker } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { image } from '@kit.ImageKit'
import { EventBus, EventType } from '../utils/EventBus'
import { DetectType, STCustomEvent } from '../models/native_js_object/DetectType'
import { PanelState } from './PreviewBottomPanel'
import { UIInstance } from '../utils/UIInstance'

const context = getContext(this) as common.UIAbilityContext;
const bgDir = context.filesDir + "/background"
const decodingOptions: image.DecodingOptions = {
  editable: true,
  desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
}
const ST_MOBILE_NAIL_DETECT : bigint= 0x4000000000000000n
@Component
export struct StickerPanel {
  /**
   * property
   */
  @State itemData : STListItem<Item> = new STListItem<Item>()
  @State stickerModel : STListItem<STEffectModel> = new STListItem<STEffectModel>()
  @State selectedItem : Item | undefined = undefined

  private manager = STMaterialManager.GetInstance()
  private listScroller = new ListScroller()
  private gridScroller = new Scroller()
  private selectItemIndex = 0
  private selectGridIndex = 0
  private selectGridItemIndex = 0

  private  preSelectedModel : STEffectModel | undefined = undefined

  @Prop panelState: PanelState

  @State localBgImages:string[] = []
  private localImagesScroller:ListScroller = new ListScroller()
  @State selectBgIndex :number= -1
  @State isShowBgList :boolean= false

  didSelectedMaterial = (model: STEffectModel) => {
    const result = libstmobile.addPackageByPath(model.pkgLocalPath)
    model.packageId = result

    if (this.panelState == PanelState.Preview) {
      let trigger = libstmobile.getTriggerActions()
      this.showTrigger(trigger)

      let customTrigger = libstmobile.getCustomEventConfig()
      this.showCustomTrigger(customTrigger)
    }

    let config =BigInt(libstmobile.getDetectConfig())
    if ((config & ST_MOBILE_NAIL_DETECT) != 0n) {
      console.log('~~~~~~~~~有指甲检测')
      libstmobile.setParamByHumanActionParam(HumanActionParam.ST_HUMAN_ACTION_PARAM_DELAY_FRAME,2)
      libstmobile.setParamByEffectParam(EffectParam.EFFECT_PARAM_RENDER_DELAY_FRAME,2)
    }
    else {
      console.log('~~~~~~~~~无指甲检测')
      libstmobile.setParamByHumanActionParam(HumanActionParam.ST_HUMAN_ACTION_PARAM_DELAY_FRAME,0)
      libstmobile.setParamByEffectParam(EffectParam.EFFECT_PARAM_RENDER_DELAY_FRAME,0)
    }
    EventBus.emitProcess()
  }
  didDeselectedMaterial = (model: STEffectModel) => {
    const result = libstmobile.removePackage(model.packageId)
    EventBus.emitProcess()
    UIInstance.GetInstance().resetOverLap()
  }
  onClearMaterial = (model: STEffectModel) => {
    const result = libstmobile.removePackage(model.packageId)
    EventBus.emitProcess()
    UIInstance.GetInstance().resetOverLap()

    this.isShowBgList = false
  }
  //onStickerClose?:(close:boolean) => void

  aboutToDisappear(): void {
    UIInstance.GetInstance().resetOverLap()
  }


  aboutToAppear(): void {
    if (fileIo.accessSync(bgDir)) {
      try {
        let bgImages = fileIo.listFileSync(bgDir)
        for (let img of bgImages){
          try {
            let uri = fileUri.getUriFromPath(bgDir + '/' + img)
            if (uri && typeof uri === 'string') {
              this.localBgImages.push(uri)
            }
          } catch (e) {
            console.error('Failed to get URI for image:', img, e)
          }
        }
      } catch (e) {
        console.error('Failed to list background images:', e)
      }
    }

    if (this.itemData.totalCount() <= 0) {
      Array.from(this.manager.stickers()!.values(), value => value!).forEach((item, index) => {
        this.itemData.pushData(new Item(item, index == 0 ? true : false))
      })
      let values = Array.from(this.manager.stickers()!.values())
      values.forEach((group)=>{
        group.effects?.forEach((model)=>{
          model.selected = false
        })
      })
      Array.from(values[0].effects!).forEach((model) =>{
        this.stickerModel.pushData(model)
      })
    }

    if (globalThis.homeParam && (globalThis.homeParam.type == HomeType.Sticker || globalThis.homeParam.type == HomeType.Avatar)){
      setTimeout(()=>{
        this.updateItems(globalThis.homeParam.index)
      }, 300)
    }

  }



  updateItems(index:number){
    this.selectGridItemIndex = this.selectItemIndex
    this.selectedItem = this.itemData.getData(index)

    this.gridScroller.scrollToIndex(this.selectGridItemIndex == index? this.selectGridIndex:0, true, ScrollAlign.START)
    this.listScroller.scrollToIndex(index, true, ScrollAlign.CENTER)

    let dataArray = this.itemData.getDataArray()
    dataArray.forEach(element => {
      element.selected = false
    });
    animateTo({ duration: 300, curve: Curve.Friction}, () => {
      if(this.selectedItem){
        this.selectedItem.selected = true
      }
    })
    let values = Array.from(this.manager.stickers()!.values())
    this.stickerModel.deleteAllData()
    Array.from(values[index].effects!).forEach((model) =>{
      if (model.selected) {
        this.preSelectedModel = model
      }
      this.stickerModel.pushData(model)
    })
  }

  updateCell(index : number){

    this.selectGridIndex = index
    let curItem = this.stickerModel.getData(index)
    if (!this.preSelectedModel){
      this.preSelectedModel = curItem
    }
    curItem.selected = !curItem.selected
    this.isShowBgList = curItem.selected &&STDefines.IsCanChangeBg(curItem.id)
    this.selectBgIndex = -1
    if (curItem.selected){
      if (this.preSelectedModel.id != curItem.id){
        this.preSelectedModel.selected = false
        libstmobile.removePackage(this.preSelectedModel.packageId)
      }
      this.preSelectedModel = curItem
      if (!curItem.downloaded) {
        curItem.state = CellState.Downloading
      }
      this.manager.downloadMaterial(curItem, (filePath) => {
        curItem.downloaded = true
        curItem.pkgLocalPath = filePath
        curItem.state = CellState.Downloaded
        if (curItem.selected && this.didSelectedMaterial) {
          this.didSelectedMaterial(curItem)

          //overlap
          setTimeout(()=>{
            UIInstance.GetInstance().setOverLap()
          }, 100)
        }
      }, (message) =>{
        curItem.state = CellState.NeedDonwload
      })
    }else{
      if (curItem.downloaded) {
        if (this.didDeselectedMaterial) {
          this.didDeselectedMaterial(curItem)
        }
      }
    }
  }

  onChangeBg(path:string,index:number){
    let file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY)
    let stat = fileIo.statSync(file.fd)
    let buffer = new ArrayBuffer(stat.size)
    fileIo.readSync(file.fd, buffer)
    fileIo.closeSync(file)
    if (index < 0) {
      if (!fileIo.accessSync(bgDir)) {
        fileIo.mkdirSync(bgDir)
      }
      let dst = bgDir+"/"+ path.split('/').pop()
      let uri = fileUri.getUriFromPath(dst)
      if (!fileIo.accessSync(dst)) {
        let destFile = fileIo.openSync(dst, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
        fileIo.writeSync(destFile.fd, buffer)
        fileIo.closeSync(destFile)

        this.localBgImages.push(uri)
        this.selectBgIndex = this.localBgImages.length - 1
      }else {
        this.selectBgIndex = this.localBgImages.indexOf(uri)
      }
      this.listScroller.scrollToIndex(this.selectBgIndex)
    }
    else {
      this.selectBgIndex= index
    }
    let imageSource = image.createImageSource(buffer)
    imageSource.getImageInfo().then((imageInfo) => {
      imageSource.createPixelMap(decodingOptions).then((pixelMap) => {
        let width = imageInfo.size.width
        let height = imageInfo.size.height
        let oriBuffer = new ArrayBuffer(width * height * 4);
        pixelMap.readPixelsToBuffer(oriBuffer).then(() => {
          let image_t :st_image_t= {
            data : oriBuffer,
            pixel_format: PixelFormat.ST_PIX_FMT_RGBA8888,
            width:width,
            height:height,
            stride:width*4,
            time_stamp : 0
          }
          libstmobile.changePackageBg(this.preSelectedModel?.packageId, image_t)
          EventBus.emitEvent(EventType.ProcessRender)
        })
      })
    })


  }

  /**
   * 拉起picker选择图片/视频
   */
  async callFilePickerSelectImage(): Promise<void> { // async 用于申明一个 function 是异步的
    let array: string[];
    try {
      // 设置photoPicker的参数
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType =picker.PhotoViewMIMETypes.IMAGE_TYPE
      PhotoSelectOptions.maxSelectNumber = 1; // 选择媒体文件的最大数目
      let mediaFlag = false;
      let photoPicker = new picker.PhotoViewPicker(); // 使用图库选择器对象前，需要先创建PhotoViewPicker实例
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        if (PhotoSelectResult !== null && PhotoSelectResult !==
          undefined) {
          array = PhotoSelectResult['photoUris'];
          array.forEach((value) => {
            mediaFlag = true;
            console.log(`select image/video uri: ${value}}`)
          })
        }
        if (mediaFlag) {
          this.onChangeBg(array[0], -1)
        }
      })
        .catch((err: BusinessError) => {
          console.log('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
        });
    } catch (err) {
      console.log('PhotoViewPicker failed with err: ' + err);
    }
  }

  build() {
    Column({space:5}) {
      //绿幕背景列表
      if (this.isShowBgList){
        Row(){
          Image($r("app.media.choose_bg_add"))
            .margin({left:10,right:10})
            .height(20)
            .width(20)
            .onClick(()=>{
              this.callFilePickerSelectImage()
            })
          List({space:5,scroller: this.localImagesScroller}){
            ForEach(this.localBgImages,(image:string, index :number)=>{
              ListItem(){
                Stack(){
                  Image(image)
                    .width('100%')
                    .onClick(()=>{
                      this.onChangeBg(image,index)}
                    )
                  if (this.selectBgIndex == index) {
                    Image($r("app.media.select_icon"))
                      .width('100%')
                  }
                }
                .width(40)
                .height(40)
              }
            })
          }
          .height(40)
          .scrollBar(BarState.Off)
          .listDirection(Axis.Horizontal)
        }
        .alignItems(VerticalAlign.Center)
        .width('80%')
        .height('15%')
        .borderRadius(5)
        .backgroundColor('rgba(255, 255, 255, 0.5)')
      }
      Column(){
        Row(){
          Image($r('app.media.clear'))
            .width(30)
            .height(30)
            .onClick(() =>{
              //clear sticker
              if (this.onClearMaterial) {
                if (this.preSelectedModel) {
                  this.preSelectedModel.selected = false
                  this.onClearMaterial(this.preSelectedModel)
                }
                //EventBus.emitEvent(EventType.ResetBeauty)
              }
            })

          List({space: 5, scroller:this.listScroller}) {
            LazyForEach(this.itemData, (item: Item, index) => {
              ListItem() {
                ListItemCell({cellItem:item})
                  .width(60)
                  .height('100%')
                  .padding({top:10})
              }
              .onClick(()=>{
                this.updateItems(index)
              })
            })
          }
          .alignListItem(ListItemAlign.Center)
          .listDirection(Axis.Horizontal)
          .height('100%')
          .scrollBar(BarState.Off)
        }
        .padding({right:20})
        .height('20%')
        .width('100%')

        Grid(this.gridScroller) {
          LazyForEach(this.stickerModel, (item: STEffectModel, index) => {
            GridItem() {
              StickerCell({model:item})
                .width('80%')
                .height(50)
            }
            .onClick(()=>{
              this.updateCell(index)
            })
          }, (item : STEffectModel, index)=>{
            return item.thumbnail + index.toString()
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(15)
        .height('80%')
        .width('100%')
      }
      .padding({ left: 12, right: 12})
      .width('100%')
      .height('85%')
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.85)
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
  }

  @State triggerTips:string = ""
  @State triggerIcon:string = ""
  showCustomTrigger(actionNum: number){
    //this.triggerTips = ""
    let tips = ""
    let icon = ""
    if((actionNum & STCustomEvent.ST_CUSTOM_EVENT_SCREEN_TAP) > 0){
      icon = 'app.media.ic_trigger_screen_tag_selected'
      tips += "请点击屏幕"
    }
    if((actionNum & STCustomEvent.ST_CUSTOM_EVENT_SCREEN_DOUBLE_TAP) > 0){
      icon = 'app.media.ic_trigger_screen_tag_selected'
      tips += "请双击屏幕"
    }
    if(tips == "") return;
    this.triggerTips = tips
    this.triggerIcon = icon
    this.dialogController.open()
    setTimeout(()=>{
      this.dialogController.close()
    },3000)
  }
  showTrigger(actionNum: number){
    let tips = ""
    if((actionNum & DetectType.ST_MOBILE_EYE_BLINK) > 0){
      this.triggerIcon = 'app.media.ic_trigger_blink'
      tips += "请眨眨眼"
    }
    if((actionNum & DetectType.ST_MOBILE_MOUTH_AH) > 0){
      this.triggerIcon = 'app.media.ic_trigger_mouth'
      tips += "请张张嘴"
    }
    if((actionNum & DetectType.ST_MOBILE_HEAD_YAW) > 0){
      this.triggerIcon = 'app.media.ic_trigger_shake'
      tips += "请摇摇头"
    }
    if((actionNum & DetectType.ST_MOBILE_HEAD_PITCH) > 0){
      this.triggerIcon = 'app.media.ic_trigger_nod'
      tips += "请点点头"
    }
    if((actionNum & DetectType.ST_MOBILE_BROW_JUMP) > 0){
      this.triggerIcon = 'app.media.ic_trigger_frown'
      tips += "请挑挑眉"
    }
    if((actionNum & DetectType.ST_MOBILE_FACE_LIPS_UPWARD) > 0){
      this.triggerIcon = 'app.media.ic_trigger_lips_upward'
      tips += "嘴角上扬"
    }
    if((actionNum & DetectType.ST_MOBILE_FACE_LIPS_POUTED) > 0){
      this.triggerIcon = 'app.media.ic_trigger_lips_pouted'
      tips += "请嘟嘴"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_PALM) > 0){
      this.triggerIcon = 'app.media.ic_trigger_palm_selected'
      tips += "请伸手掌"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_LOVE) > 0){
      this.triggerIcon = 'app.media.ic_trigger_heart_hand_selected'
      tips += "请爱心手势"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_HOLDUP) > 0){
      this.triggerIcon = 'app.media.ic_trigger_palm_up_selected'
      tips += "请托个手"
    }

    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_CONGRATULATE) > 0){
      this.triggerIcon = 'app.media.ic_trigger_congratulate_selected'
      tips += "请抱个拳"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_FINGER_HEART) > 0){
      this.triggerIcon = 'app.media.ic_trigger_finger_heart_selected'
      tips += "请单手比心"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_GOOD) > 0){
      this.triggerIcon = 'app.media.ic_trigger_thumb_selected'
      tips += "大拇指"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_OK) > 0){
      this.triggerIcon = 'app.media.ic_trigger_ok_selected'
      tips += "请亮出OK手势"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_SCISSOR) > 0){
      this.triggerIcon = 'app.media.ic_trigger_scissor_selected'
      tips += "请比个剪刀手"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_PISTOL) > 0){
      this.triggerIcon = 'app.media.ic_trigger_pistol_selected'
      tips += "请比个手枪"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_FINGER_INDEX) > 0){
      this.triggerIcon = 'app.media.ic_trigger_one_finger_selected'
      tips += "请伸出食指"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_FIST) > 0){
      this.triggerIcon = 'app.media.ic_trigger_first_selected'
      tips += "请举起拳头"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_666) > 0){
      this.triggerIcon = 'app.media.ic_trigger_sixsixsix_selected'
      tips += "请亮出666手势"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_BLESS) > 0){
      this.triggerIcon = 'app.media.ic_trigger_handbless_selected'
      tips += "请双手合十"
    }
    if((actionNum & DetectType.ST_HAND_ACTION_TYPE_ILOVEYOU) > 0){
      this.triggerIcon = 'app.media.ic_trigger_love_selected'
      tips += "请亮出我爱你手势"
    }
    if(tips == "") return;
    this.triggerTips = tips
    this.dialogController.open()
    setTimeout(()=>{
      this.dialogController.close()
    },3000)
  }
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogBuilder({icon:this.triggerIcon,message:this.triggerTips}),
    backgroundColor: undefined,
    backgroundBlurStyle: BlurStyle.Thin,
    backgroundBlurStyleOptions: {
      colorMode: ThemeColorMode.LIGHT,
      adaptiveColor: AdaptiveColor.AVERAGE,
      scale: 1,
      blurOptions: { grayscale: [20, 20] },
    },
    offset:{dx:0,dy:100},
    width:200,
    height:40,
    autoCancel:false,
    isModal :false
  })
}
@CustomDialog
@Component
struct CustomDialogBuilder {
  controller?: CustomDialogController;
  @Link  icon:string
  @Link  message:string
  build() {
    Row() {
      Image($r(this.icon)).width('64px').height('64px')
      Blank().width(10)
      Text(this.message).fontSize(18).fontColor(Color.White)
    }
    .alignItems(VerticalAlign.Center)
    .width(100)
    .height(40)
    .hitTestBehavior(HitTestMode.Transparent)

  }
}


