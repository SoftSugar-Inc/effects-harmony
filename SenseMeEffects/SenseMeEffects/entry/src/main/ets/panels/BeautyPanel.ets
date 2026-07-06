import { BeautyType,BeautyParamType,st_effect_3D_beauty_part_info_t, st_face_shape_t } from '@softsugar/mars_effects'
import BeautyGroup from '../models/Beauty/BeautyGroup'
import BeautyObject from '../models/Beauty/BeautyObject'
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager'
import DBManager from '../models/DBJson/DBManager'

import { HomeParam, HomeType } from '../common/STDefines'
import { PanelState } from './PreviewBottomPanel'
import { BeautyParam } from '../models/Beauty/BeautyObject'
import libstmobile from '@softsugar/mars_effects'
import { EventBus, EventType } from '../utils/EventBus'
import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import BeautyCleanObject from '../models/Beauty/BeautyCleanObject'

const context = getContext() as common.UIAbilityContext
const resourceManager = context.resourceManager
@Component
struct BindStrengthView {
  // 子组件ViewA的@ObjectLink的类型是ClassA
  @ObjectLink beautyObject: BeautyObject

  build() {
    Text(`${Math.floor( this.beautyObject.currentStrength*100)}`)
      .fontSize(10)
      .maxLines(1)
      .fontColor(Color.White)
  }
}

@Component
export struct BeautyPanel {
  onBeautyFirstChanged = (beauty: BeautyObject) => {
    if (beauty.cleanObject.is_3d_plastic) return
    if (beauty.cleanObject.beauty_asset_path) {
      let fileContent = resourceManager.getRawFileContentSync(beauty.cleanObject.beauty_asset_path)
      const buffer = fileContent.buffer.slice(0);
      libstmobile.setBeautyPackageByBuffer(beauty.cleanObject.beauty_type, buffer)
    }
    else {
      libstmobile.setBeautyPackageByBuffer(beauty.cleanObject.beauty_type, null)
    }
    libstmobile.setBeautyMode(beauty.cleanObject.beauty_mode_param, beauty.cleanObject.beauty_mode_value)
    libstmobile.setBeautyParam(BeautyParamType.EFFECT_BEAUTY_PARAM_ENABLE_WHITEN_SKIN_MASK, beauty.cleanObject.need_open_whiten_skin_mask?1:0)

    EventBus.emitProcess()
  }
  onBeautyStrengthChanged = (beauty: BeautyObject) => {
    if (beauty.cleanObject.is_3d_plastic) {
      let parts : st_effect_3D_beauty_part_info_t[]= libstmobile.get3DBeautyParts()
      parts.forEach((part)=>{
        if (part.name === beauty.cleanObject.uid) {
          part.strength = beauty.currentStrength
        }
      })
      let result = libstmobile.set3dBeautyPartsStrength(parts)
    }else {
      if (this.panelState == PanelState.Photo && this.isMultiBody && this.isSupportMultiBody()) {
        if (this.currentSelectFaceIndex >= 0) {
          if (this.groupData[this.currentTypeIndex].name == '美体') {
            libstmobile.setBodyBeautyStrengthByBodyId(beauty.cleanObject.beauty_type??-1,  (beauty.currentStrength?beauty.currentStrength:0), this.currentSelectFaceIndex)
          }else {
            libstmobile.setFaceBeautyStrengthByFaceId(beauty.cleanObject.beauty_type??-1,  (beauty.currentStrength?beauty.currentStrength:0), this.currentSelectFaceIndex)
          }
          // 设置指定人脸的美体参数
          console.info(`setSelectedFaceBodyBeauty: type=${ beauty.cleanObject.beauty_type}, value=${beauty.currentStrength}, face_id=${this.currentSelectFaceIndex}`)
        }
        else {
          console.error("当前没有选中人脸，无法设置美体参数")
        }
      } else {
        libstmobile.setBeautyStrength(beauty.cleanObject.beauty_type,  (beauty.currentStrength?beauty.currentStrength:0))
      }
    }
    EventBus.emitProcess()
  }

  // 判断是否是美体类型
/*  private isBodyBeautyType(type: number | undefined): boolean {
    if (type === undefined) return false
    // 美体类型范围：EFFECT_BEAUTY_BODY 相关的类型
    return type >= BeautyType.EFFECT_BEAUTY_BODY_WHOLE && type <= BeautyType.EFFECT_BEAUTY_BODY_FLAT_BELLY&& this.isMultiBody
  }*/
  onResetOrClear = (beauties: BeautyObject[]) => {
    if (this.panelState == PanelState.Photo && this.isMultiBody && this.isSupportMultiBody())
    {
      beauties.forEach(element=>{
        if (this.groupData[this.currentTypeIndex].name == '美体') {
          libstmobile.setBodyBeautyStrengthByBodyId(element.cleanObject.beauty_type??-1, element.currentStrength, this.currentSelectFaceIndex)
        }else {
          libstmobile.setFaceBeautyStrengthByFaceId(element.cleanObject.beauty_type??-1, element.currentStrength, this.currentSelectFaceIndex)
        }
      })
    }else {
      beauties.forEach(element=>{
        if (element.cleanObject.is_3d_plastic) {
          let parts : st_effect_3D_beauty_part_info_t[]= libstmobile.get3DBeautyParts()
          parts.forEach((part)=>{
            if (part.name === element.cleanObject.uid) {
              part.strength = element.currentStrength
            }
          })
          libstmobile.set3dBeautyPartsStrength(parts)
        }else {
          libstmobile.setBeautyStrength(element.cleanObject.beauty_type, element.currentStrength)
        }
      })
    }
    EventBus.emitProcess()
  }


  @State groupData:BeautyGroup[] =[]

  @State currentTypeIndex: number = 0
  private itemController: Scroller = new Scroller()
  private listController: Scroller = new Scroller()
  @State selectedBeautyIndex: number = -1
  @State currentStrength: number = 0
  @State subDataSource: BeautyObject[] | undefined = undefined
  @State isShowSub: boolean = false
  @State selectedSubIndex: number = -1
  @State curObject : BeautyObject | undefined = undefined
  private isChangeObj = false

  @State isMultiBody:boolean = false

  //key:type
  //@State typeBeautyMap:Map<number, BeautyObject> = new Map

  //key:title index
  @State indexSelectMap:Map<number, number> = new Map

  @State isStartCenter:boolean=false

  @Prop panelState: PanelState

  @Prop isMultiImage: boolean = false

  @State bgLockState: boolean = false


  @State faceParamsCache: Map<number, Map<string, number>> = new Map()  // 每个人脸的参数缓存

  build() {
    Column() {
      if (this.panelState == PanelState.Photo&&this.groupData[this.currentTypeIndex].name =='美体'){
        Row({space:5}){
          Text('背景锁定').fontSize(12).fontColor(Color.White)
          Toggle({ type: ToggleType.Switch, isOn: this.bgLockState }).onChange((isOn)=>{
            this.onBackgroundLockChange(isOn)
          }).width(40).height(20)
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.beauty_panel_color'))
        .borderRadius(10)
        .width(110)
        .height(30)
        .position({left:10,top: -60})


      }
      if (this.panelState == PanelState.Photo && this.isSupportMultiBody() && this.isMultiImage){
        Image(this.isMultiBody?$r('app.media.body_change_on'):$r('app.media.body_change_off'))
          .width(30)
          .height(30)
          .position({right:10,top: -60})
          .onClick(() => {
            if (this.curObject&&this.curObject.cleanObject.is_unsupport_multiBody) {
              EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"暂不支持多人模式"}})
              return
            }
            // 关闭多人模式时弹窗确认
            if (this.isMultiBody) {
              promptAction.showDialog({
                message: '你已为不同人脸分别设置参数，切换为整体调整将清除多人模式设置，是否继续？',
                buttons: [
                  { text: '取消', color: '#000000' },
                  { text: '确认', color: $r('app.color.selected_color') }
                ]
              }).then((result) => {
                if (result.index === 1) {
                  this.isMultiBody = false
                  this.updateAllBodyBeautyParamsFromSelectedFace(-1)
                  this.faceParamsCache.clear()
                  if (this.curObject) {
                    this.onBeautyStrengthChanged(this.curObject)
                  }

                  this.onResetOrClear(this.groupData[this.currentTypeIndex].beauties)

                  EventBus.emitEvent(EventType.MultiBodyChange, {data:{"isChangeBody":this.isMultiBody}})

                  for (let index = 0; index < 10; index++) {
                    libstmobile.clearBodyBeautyStrengthByBodyId(index)
                    libstmobile.clearFaceBeautyStrengthByFaceId(index)
                  }
                }
              })
              return
            }
            // 开启多人模式，直接切换
            this.isMultiBody = true
            this.updateAllBodyBeautyParamsFromSelectedFace(0)

            for (let index = 1; index < 10; index++) {
              libstmobile.setFaceBeautyStrengthByFaceId(this.curObject?.cleanObject.beauty_type??-1, 0, index)
              libstmobile.setBodyBeautyStrengthByBodyId(this.curObject?.cleanObject.beauty_type??-1, 0, index)
            }
            EventBus.emitEvent(EventType.MultiBodyChange, {data:{"isChangeBody":this.isMultiBody}})
          })
      }

      if (this.curObject&&this.curObject.subParams && this.curObject.subParams.length >0){
        ForEach(this.curObject.subParams,(subParam:BeautyParam)=>{
          Row(){
            Text(subParam.cleanObject.enum_des).fontColor(Color.White).fontSize(14)
            Slider({
              value: subParam.currentStrength,
              step: 1,
              min: 0,
              max: 100,
              style: SliderStyle.OutSet
            })
              .width('60%')
              .showTips(false)
              .showSteps(true)
              .margin({ left: 20, right: 20 })
              .onChange((value)=>{
                this.onSliderValueChange(subParam,value)
              })
            Text(`${Math.floor(subParam.currentStrength)}`).fontColor(Color.White).fontSize(14)
          }
          .justifyContent(FlexAlign.Start)
          .width('80%')
          .height(40)
        })
      }
      else {
        Text(`${Math.floor(this.currentStrength)}`)
          .fontSize(14)
          .fontColor(Color.White)
          .position({
            x:`${
            this.isStartCenter?
              (this.currentStrength*0.3 + 50)
              :
              (this.currentStrength*0.6 + 20)}%`,
            y:-10

          }) //滑块offset
          .backgroundColor('#00000000')
          .markAnchor({x:'50%'})
          .visibility(this.indexSelectMap.has(this.currentTypeIndex)? Visibility.Visible : Visibility.Hidden)
        Slider({
          value: this.currentStrength,
          step: 1,
          min: this.isStartCenter?-100:0,
          max: 100,
          style: SliderStyle.OutSet
        })
          .visibility(this.indexSelectMap.has(this.currentTypeIndex)? Visibility.Visible : Visibility.Hidden)
          .width('64%')
          .showTips(false)
          .showSteps(true)
          //.padding({ left: '18%', right: '18%' })
          .onChange((value: number, mode: SliderChangeMode) => {
            this.onChangeBeauty(value, mode)
          })
      }


      List({space:5 ,scroller : this.itemController}) {
        ForEach(this.groupData, (item: BeautyGroup, index) => {
          ListItem() {
            Column() {
              Text(item.name)// .margin({ top: 5 })
                .fontColor(this.currentTypeIndex == index ? Color.White : Color.Gray)
                .width("100%")
                .height('100%')
                .textAlign(TextAlign.Center)
                .fontSize(14)
            }
            .width(70)
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
          .height('100%')
          .onClick(() => {
            this.onItemSelect(index)
          })
        })
      }
      .scrollBar(BarState.Off)
      .alignListItem(ListItemAlign.Center)
      .listDirection(Axis.Horizontal)
      .width('100%')
      .height(40)
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.9)

      List({ scroller: this.listController, initialIndex: 0, space: 0 }) {
        ForEach(this.subDataSource,
          (item: BeautyObject, index) => {
          if (!item.cleanObject.only_show_in_image_mode || this.panelState == PanelState.Photo){
            ListItem() {
              Column() {
                Image(this.isShowSub ?
                  (this.selectedSubIndex == index ? $r(`app.media.${item.cleanObject.select_icon_press_res}`) :
                  $r(`app.media.${item.cleanObject.select_icon_nor_res}`)) :
                  (
                    this.selectedBeautyIndex == index ? $r(`app.media.${item.cleanObject.select_icon_press_res}`) :
                    $r(`app.media.${item.cleanObject.select_icon_nor_res}`)))
                  .height(50)
                  .margin({ top: 10, bottom: 5 })// .borderColor(this.selectedColor)
                  // .borderWidth(this.selectedIndexPath != null && this.selectedIndexPath.category == this.currentCategory && this.selectedIndexPath.index == index ? 2 : 0)
                  .borderRadius(10)

                Text(item.cleanObject.des)
                  .fontSize(10)
                  .maxLines(1)
                  .fontColor(Color.White)

                if (item.cleanObject.beauty_type != undefined &&item.cleanObject.beauty_type != -2 && (item.subBeauties == undefined||item.subBeauties.length <=0) && (item.subParams == undefined)) {
                  BindStrengthView({ beautyObject: item})
                }
              }
              .width(60)
              .onClick(() => {
                this.onObjectSelect(item,index)
              })
            }
          }
          })
      }
      .height(90)
      .width('100%')
      .listDirection(Axis.Horizontal)
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.85)
      .scrollBar(BarState.Off)

      Row() {
        Row({ space: 3 }) {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Image($r('app.media.clear_makeup')).width(20).height(20)
          }
          .width(40)
          .height(40)
          .margin({left:15})
          .backgroundColor(Color.Transparent)

          Text("清零")
            .fontSize(12)
            .fontColor(Color.White)
        }
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.clearSelectEffects(this.currentTypeIndex)
          this.reset()
        })
        Blank()

        Row({ space: 3 }) {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Image($r('app.media.reset_makeup')).width(20).height(20)
          }
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          Text("重置")
            .margin({right:15})
            .fontSize(12)
            .fontColor(Color.White)
        }
        .alignItems(VerticalAlign.Center)
        .onClick(()=>{
          this.resetSelectEffects(this.currentTypeIndex, true)
          this.reset()
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.85)
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
  }

  aboutToDisappear(): void {
    //EventBus.unListenEvent(EventType.ResetBeauty)
    EventBus.unListenEvent(EventType.OnModelLoaded)
    if (this.panelState == PanelState.Photo) {
      EventBus.unListenEvent(EventType.SelectedFaceChanged)
    }
  }

  private currentSelectFaceIndex : number = -1


  // 从选中的人脸获取所有美体参数值并更新
  private updateAllBodyBeautyParamsFromSelectedFace(index:number) {
    if(!this.subDataSource || index == undefined) {
      return
    }
    //缓存旧的
    let oldCache = new Map<string,number>()
    this.groupData.forEach((group) => {
      if (group.isSupportMultiMode){
        group.beauties.forEach((item) => {
          if (item.cleanObject.uid) {
            oldCache.set(item.cleanObject.uid, item.currentStrength)
          }
          if (item.subBeauties) {
            item.subBeauties.forEach((subBeauty) => {
              if (subBeauty.cleanObject.uid) {
                oldCache.set(subBeauty.cleanObject.uid, subBeauty.currentStrength)
              }
            })
          }
        })
      }
    })
    this.faceParamsCache.set(this.currentSelectFaceIndex, oldCache)

    if (!(index == 0 && this.currentSelectFaceIndex == -1)){
      let newCache = this.faceParamsCache.get(index)
      this.groupData.forEach((group) => {
        if (group.isSupportMultiMode){
          group.beauties.forEach((item) => {
            if(newCache && item.cleanObject.uid){
              const value = newCache.get(item.cleanObject.uid)
              item.currentStrength = value?? 0
            }else {
              item.currentStrength = 0
            }
            if (item.subBeauties) {
              item.subBeauties.forEach((subBeauty) => {
                if(newCache && subBeauty.cleanObject.uid){
                  const value = newCache.get(subBeauty.cleanObject.uid)
                  subBeauty.currentStrength = value?? 0
                }else {
                  subBeauty.currentStrength = 0
                }
              })
            }
          })
        }
      })
      // 更新当前选中项的显示
      if (this.curObject) {
        this.currentStrength = this.curObject.currentStrength * 100
      }
    }
    this.currentSelectFaceIndex = index
  }

  aboutToAppear(): void {
    EventBus.listenEvent(EventType.OnModelLoaded,()=>{
      if (globalThis.homeParam && (globalThis.homeParam.type == HomeType.Beauty || globalThis.homeParam.type == HomeType.Body)){
          this.itemController.scrollTo(globalThis.homeParam.index)
          this.onItemSelect(globalThis.homeParam.index)
      }
      this.resetAllBeauty()
      if (this.panelState == PanelState.Preview) {
        this.resetDBBeauty()
      }
    })

    // 监听选中人脸改变事件，更新滑动条显示
    if (this.panelState == PanelState.Photo) {
      EventBus.listenEvent(EventType.SelectedFaceChanged, (data)=>{
        const faceIndex = data.data?.['faceIndex'] as number
        console.info(`BeautyPanel: SelectedFaceChanged, faceIndex=${faceIndex}`)

        if (faceIndex >= 0) {
          // 更新所有美体类型的参数值（而不仅仅是当前选中的）
          this.updateAllBodyBeautyParamsFromSelectedFace(faceIndex)
        }
      })
    }
    this.subDataSource =BeautyResourceManager.getInstance().dataSource[0].beauties
    if (this.panelState != PanelState.Video){
      //照片模式 预览模式  有肤质
      this.groupData = BeautyResourceManager.getInstance().dataSource.convertToArray()
    }else {
      //视频模式  无肤质
      BeautyResourceManager.getInstance().dataSource.forEach(group=>{
        if (group.name != '肤质') {
          this.groupData.push(group)
        }
      })
    }

/*    EventBus.listenEvent(EventType.ResetBeauty,()=>{
      if (this.panelState == PanelState.Preview) {
        this.resetDBBeauty()
      }
      else {
        this.resetAllBeauty()
      }
    })*/
  }

  onItemSelect(index:number){
    if (this.currentTypeIndex != index) {
      this.currentTypeIndex = index
      this.subDataSource = this.groupData[this.currentTypeIndex].beauties
      if (this.groupData[this.currentTypeIndex].name =='肤质' && this.panelState == PanelState.Preview){
        let beauties :BeautyObject[] =[]
        this.subDataSource.forEach(beauty=>{
          if (beauty.cleanObject.des?.includes('gan')) {
            beauties.push(beauty)
          }
        })
        this.subDataSource = beauties
      }

      this.selectedBeautyIndex = this.indexSelectMap.get(index)??-1
      if (this.selectedBeautyIndex >= 0) {
        let obj = this.subDataSource[this.selectedBeautyIndex]
        this.currentStrength = obj.currentStrength * 100
        this.onObjectSelect(obj, this.selectedBeautyIndex)
      }
      this.listController.scrollToIndex(0)

      const selectName = this.groupData[this.currentTypeIndex].name
      EventBus.emitEvent(EventType.OnBeautyModeChange,{data:{'beautyMode':selectName}})
    }
  }
  isSupportMultiBody(){
    return this.groupData[this.currentTypeIndex].isSupportMultiMode
  }

  onObjectSelect(item:BeautyObject, index :number){
    //进入二级菜单
    if (item.subBeauties != undefined && item.subBeauties.length > 0) {
      this.curObject = item
      this.subDataSource = item.subBeauties
      this.isShowSub = true

      this.selectedBeautyIndex = index
      this.indexSelectMap.delete(this.currentTypeIndex)
    }
    //二级子菜单 返回
    else if (item.cleanObject.beauty_type == BeautyType.EFFECT_BEAUTY_BACK) {
      this.isShowSub = false
      this.subDataSource = this.groupData[this.currentTypeIndex].beauties

      this.indexSelectMap.delete(this.currentTypeIndex)
    }
    //选中
    else {
      if (item&&item.cleanObject.is_unsupport_multiBody && this.isMultiBody) {
        EventBus.emitEvent(EventType.ShowMessage, {data:{"message":"暂不支持多人模式"}})
        return
      }
      this.isChangeObj = true
      this.curObject = item
      this.indexSelectMap.set(this.currentTypeIndex, index)
      if (this.isShowSub) {
        this.selectedSubIndex = index
        //this.selectedMakeupIndex = -1
      } else {
        this.selectedSubIndex = -1
        this.selectedBeautyIndex = index
      }
      this.currentStrength = item.currentStrength ? item.currentStrength*100:0
      this.isStartCenter = item.cleanObject.range_negative_to_positive??false

      //事件
      if (item.cleanObject.click_event_type == 'pull_aux_body_mesh'){
        EventBus.emitEvent(EventType.BodyBeautyMesh)
      }
      //图片版 肤质 选中
      if (this.curObject.subParams) {
        this.onChangeSkin()
      }
/*
      if (this.curObject.cleanObject.is_unsupport_multiBody) {
        this.isMultiBody = false
        EventBus.emitEvent(EventType.MultiBodyChange, {data:{"isChangeBody":false}})
      }*/
    }
  }
  mutex(obj:BeautyObject){
    if(!obj) return
    //other_mutual_beauty_type 定义的互斥 type不一致
    if (obj.cleanObject.mutex_other_uid_arr) {
      obj.cleanObject.mutex_other_uid_arr.forEach((uid)=>{
        let model = BeautyResourceManager.getInstance().defaultEffects.get(uid)
        if (model && model.currentStrength > 0){
          model.currentStrength = 0
          this.onBeautyStrengthChanged?.(model)
          if (this.panelState == PanelState.Preview) {
            DBManager.Instance().deleteBeauty(model.cleanObject.uid??"")
          }
        }
      })
    }
  }
  onChangeSkin(){
    if(!this.curObject) return
    this.mutex(this.curObject)

    this.isChangeObj = false
/*    if (this.curObject.currentStrength > 0) {
      this.typeBeautyMap.set(this.curObject.cleanObject.beauty_type??-1, this.curObject)
    }*/

    libstmobile.setBeautyMode(this.curObject.cleanObject.beauty_type, this.curObject.cleanObject.beauty_mode_value)

    if (this.curObject.subParams) {
      this.curObject.subParams.forEach(param=>{
        libstmobile.setBeautyStrength(param.cleanObject.st_beauty_type,  param.currentStrength/100)
      })
    }

  }
  onChangeBeauty(value: number, mode: SliderChangeMode){
    if(!this.curObject) return

    this.curObject.currentStrength =value/100.0
    if (mode == SliderChangeMode.Begin && this.isChangeObj){
      this.onBeautyFirstChanged?.(this.curObject)
      this.isChangeObj = false
      this.mutex(this.curObject)
    }
    this.onBeautyStrengthChanged?.(this.curObject)
   /* if (this.curObject.currentStrength > 0) {
      this.typeBeautyMap.set(this.curObject.cleanObject.beauty_type??-1, this.curObject)
    }*/
    this.currentStrength = value
    if (this.panelState == PanelState.Preview) {
      DBManager.Instance().updateBeauty(this.curObject.cleanObject.uid??"", this.curObject.currentStrength)
    }

  }

  onSliderValueChange(subParam:BeautyParam, value: number){
    subParam.currentStrength = value
    libstmobile.setBeautyStrength(subParam.cleanObject.st_beauty_type,  value/100)

  }


  resetAllBeauty(){
    for (let index = 0; index < this.groupData.length; index++) {
      this.resetSelectEffects(index, false)
    }
  }
  resetDBBeauty(){
    let beauties = DBManager.Instance().getBeauties()
    if (beauties.length > 0){
      let zeroArray = new Array<BeautyObject>()
      let noZeroArray = new Array<BeautyObject>()
      beauties.forEach((element) => {
        let model = BeautyResourceManager.getInstance().defaultEffects.get(element.uid)
        if(!model) return
        model.currentStrength = element.value
        if (model.currentStrength == 0) {
          zeroArray.push(model)
        } else {
          noZeroArray.push(model)
        }
      });
      zeroArray.forEach(model=>{
        this.onBeautyFirstChanged?.(model)
        this.onBeautyStrengthChanged?.(model)
      })
      noZeroArray.forEach(model=>{
        this.mutex(model)
        this.onBeautyFirstChanged?.(model)
        this.onBeautyStrengthChanged?.(model)
      })
    }
  }

  clearSelectEffects(index:number) {
    if (this.onResetOrClear) {
      let beauties: BeautyObject[] = this.groupData[index].beauties
      let result: BeautyObject[] = []
      beauties.forEach(element => {
        if (element.subBeauties && element.subBeauties.length > 0) {
          element.subBeauties.forEach(subElement => {
            subElement.currentStrength = 0
            result.push(subElement)
          })
        } else if (element.cleanObject.beauty_type != BeautyType.EFFECT_BEAUTY_BACK) {
          element.currentStrength = 0
          result.push(element)
        }
      })
      if (this.panelState == PanelState.Preview) {
        result.forEach((item)=>{
          DBManager.Instance().updateBeauty(item.cleanObject.uid??"", 0)
        })
      }
      //DBManager.Instance().deleteAllBeauty()
      this.onResetOrClear(result)
    }
  }

  resetSelectEffects(index:number, isResetBtnClick:boolean) {
    let beauties: BeautyObject[] = this.groupData[index].beauties
    let result: BeautyObject[] = []
    let faceShape:st_face_shape_t|undefined = DBManager.Instance().getUserInfo()?.faceShape
    for (let i = 0; i < beauties.length; i++) {
      let element = beauties[i]
      if (element.subBeauties && element.subBeauties.length > 0) {
        for (let j = 0; j< element.subBeauties.length; j++){
          let subElement = element.subBeauties[j]
          subElement.currentStrength = subElement.getDefaultStrength(faceShape)
          if (isResetBtnClick || subElement.currentStrength > 0){
            result.push(subElement)
          }
          if (isResetBtnClick && this.panelState == PanelState.Preview) {
            DBManager.Instance().updateBeauty(subElement.cleanObject.uid??"",subElement.currentStrength)
          }
        }

      } else if (element.cleanObject.beauty_type != BeautyType.EFFECT_BEAUTY_BACK) {
        element.currentStrength = element.getDefaultStrength(faceShape)

        if (isResetBtnClick || element.currentStrength > 0){
          result.push(element)
        }
        if (isResetBtnClick && this.panelState == PanelState.Preview) {
          DBManager.Instance().updateBeauty(element.cleanObject.uid??"", element.currentStrength)
        }
      }
    }
    this.onResetOrClear?.(result)
  }

  onBackgroundLockChange(isLock:boolean){
    this.bgLockState = isLock
    EventBus.emitEvent(EventType.BodyBeautyLock,{ data: {'param':isLock} })
  }

  reset() {
    this.indexSelectMap.clear()
    this.selectedBeautyIndex = -1
    this.selectedSubIndex = -1
  }
}