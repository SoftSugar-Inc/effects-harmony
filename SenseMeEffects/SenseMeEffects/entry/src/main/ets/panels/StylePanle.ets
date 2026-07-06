import { STEffectModel } from "../models/Sticker/STEffectModel"
import { STGroupResult } from "../models/Sticker/STGroupResult"
import { STListItem } from "../models/STListItem"
import { CellState } from "../models/STMaterial"
import { STMaterialManager } from "../models/STMaterialManager"
import { WebImage } from "../STWebImage/WebImage"
import { Item } from "./ListItemCell"
import { StickerCell } from "./StickerCell"
import libstmobile ,{ BeautyType,EffectBeautyGroup }from '@softsugar/mars_effects'
import BeautyResourceManager from "../models/Beauty/BeautyResourceManager"
import { emitter } from "@kit.BasicServicesKit"
import { HomeType } from "../common/STDefines"
import DBManager from "../models/DBJson/DBManager"
import { EventBus, EventType } from "../utils/EventBus"
import { PanelState } from "./PreviewBottomPanel"
import BeautyObject from "../models/Beauty/BeautyObject"
import { UIInstance } from "../utils/UIInstance"

@Entry
@Component
export struct StylePanel {
  @Prop panelState: PanelState
  @State isFilterSlider:boolean = true

  @State sliderValue:number = 80

  @State typeIndex:number = 0

  @State itemData : string[] = []
  @State styleModel : STEffectModel[] = []

  private manager = STMaterialManager.GetInstance()



  private filterStrength:number = 80
  private makeupStrength:number = 80
  private styleGroup :STGroupResult[]|undefined
  @State preSelectedModel : STEffectModel | undefined = undefined

  aboutToAppear(): void {
    if (this.styleGroup == undefined) {
      this.styleGroup =Array.from(this.manager.styles()!.values(), value => value!)
      this.styleGroup.forEach((item, index) => {
        if (item.listName) {
          this.itemData.push(item.listName)
        }
      })
      this.styleGroup.forEach((group) => {
        if (group.effects){
          group.effects.forEach((model) => {
            model.selected = false
          })
        }
      })
      if (this.styleGroup.length > 0 && this.styleGroup[0].effects){
        this.styleGroup[0].effects.forEach((model) => {
          this.styleModel.push(model)
        })
      }
    }

    EventBus.listenEvent(EventType.OnModelLoaded,()=>{
      let index = 0
      let childIndex = -1
      let filterValue = 0
      let makeUpValue = 0
      if(this.panelState == PanelState.Preview){
        let dbInfo = DBManager.Instance().getStyle()
        if (dbInfo) {
          index = dbInfo.parentIndex<0?0:dbInfo.parentIndex
          childIndex = dbInfo.childIndex
          filterValue = dbInfo.filterStrength
          makeUpValue = dbInfo.makeupStrength
        }else {
          let userInfo = DBManager.Instance().getUserInfo()
          let isMale:boolean = userInfo?.gender == 1
          index = isMale?2:0
          childIndex = isMale?1:0  //一键美颜-经典  轻妆-气色
          filterValue = isMale ? 50: 80
          makeUpValue = isMale ? 50: 40
        }
      }else {
        index = 0
        childIndex = 0
        filterValue = 80
        makeUpValue = 40
      }
      if (globalThis.homeParam && globalThis.homeParam.type == HomeType.Style){
        this.onSelectItem(globalThis.homeParam.index)
      }
      else {
        this.onSelectItem(index)
      }

      if (childIndex>=0 &&this.styleGroup && index< this.styleGroup.length) {
        let effects =this.styleGroup[index].effects
        if (effects&& childIndex < effects.length) {
          this.onSelectStyle(effects[childIndex], childIndex)
        }
      }
      this.isFilterSlider = false
      this.onSliderChange(makeUpValue)
      this.isFilterSlider = true
      this.onSliderChange(filterValue)
    })
  }
  aboutToDisappear(): void {
    EventBus.unListenEvent(EventType.OnModelLoaded)
    UIInstance.GetInstance().resetOverLap()
  }

  onSelectItem(index : number){
    this.typeIndex = index
    if (this.styleGroup && this.styleGroup.length > index){
      this.styleModel = []
      let effects = this.styleGroup[index].effects
      if (effects != undefined){
        effects.forEach((model) => {
          this.styleModel.push(model)
        })
      }
    }
  }
  onSliderChange(value : number){
    this.sliderValue = value
    if (this.isFilterSlider){
      libstmobile.setPackageBeautyStrength(this.preSelectedModel?.packageId??0,EffectBeautyGroup.EFFECT_BEAUTY_GROUP_FILTER,value / 100.0)
      this.filterStrength = value
    }else {
      libstmobile.setPackageBeautyStrength(this.preSelectedModel?.packageId??0,EffectBeautyGroup.EFFECT_BEAUTY_GROUP_MAKEUP, value / 100.0)
      this.makeupStrength = value
    }
    if (this.panelState == PanelState.Preview) {
      DBManager.Instance().updateStyleStrength(this.filterStrength,this.makeupStrength)
    }
    EventBus.emitProcess()
  }

  onSelectStyle(model : STEffectModel, index :number){
    if (model.selected) return
    if (this.preSelectedModel) {
      this.preSelectedModel.selected = false
      libstmobile.removePackage(this.preSelectedModel.packageId)
    }
    this.preSelectedModel = model
    model.selected = true

    this.filterStrength = 80
    this.makeupStrength = 80
    this.sliderValue = 80

    if (this.panelState == PanelState.Preview) {
      DBManager.Instance().updateStyle(this.typeIndex,index)
      DBManager.Instance().updateStyleStrength(this.filterStrength,this.makeupStrength)
    }
    if (!model.downloaded) {
      model.state = CellState.Downloading
    }
    this.manager.downloadMaterial(model, (filePath) => {
      model.downloaded = true
      model.pkgLocalPath = filePath
      model.state = CellState.Downloaded
      if (model.selected) {
        let result = libstmobile.addPackageByPath(model.pkgLocalPath)
         libstmobile.setPackageBeautyStrength(result,EffectBeautyGroup.EFFECT_BEAUTY_GROUP_FILTER,0.8)
        libstmobile.setPackageBeautyStrength(result,EffectBeautyGroup.EFFECT_BEAUTY_GROUP_MAKEUP,0.8)
        model.packageId =result

        EventBus.emitProcess()
        //overlap
        setTimeout(()=>{
          UIInstance.GetInstance().setOverLap()
        }, 100)
      }
    }, (message) =>{
      model.state = CellState.NeedDonwload
    })
  }
  build() {
    Column() {
      //滑动条
      Row({space : 10}){
        Row({space:8}){
          Text('妆容').fontColor(this.isFilterSlider? '#555555': '#DB77E5').fontSize(12)
            .onClick(()=>{this.isFilterSlider = false; this.sliderValue = this.makeupStrength})
          Row().backgroundColor('#D9D9D9').width(1).height(14)
          Text('滤镜').fontColor(!this.isFilterSlider? '#555555': '#DB77E5').fontSize(12)
            .onClick(()=>{this.isFilterSlider = true; this.sliderValue = this.filterStrength})
        }
        .width(80)
        .height(26)
        .borderRadius(12)
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center)
        .margin({left:10})

        Row(){
          Text(`${Math.floor(this.sliderValue)}`)
          .fontSize(10)
          .fontColor(Color.White)
          .position({ y:-10, x: this.sliderValue *2.1}) //滑块offset
          .backgroundColor('#00000000')
          .markAnchor({x:'50%'})
          //.visibility(this.selectedIndex.index >= 0 ? Visibility.Visible : Visibility.Hidden)
          Slider({
            value: this.sliderValue,
            step: 1,
            min: 0,
            max: 100,
            style: SliderStyle.OutSet
          })
            //.visibility(this.selectedIndex.index >= 0 ? Visibility.Visible : Visibility.Hidden)
            .selectedColor(Color.White)
            .width(217)
            .showTips(false)
            .showSteps(true)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.onSliderChange(value)
            })
        }
        .height(24)
        .width(217)
        .visibility(this.preSelectedModel!=undefined ? Visibility.Visible : Visibility.Hidden)
      }
      .width('100%')
      .height(48)
      .backgroundColor(Color.Transparent)
      Column(){
        //标题
        Row({space:5}){
          Image($r('app.media.forbid_circle')).size({width:18,height:18})
            .onClick(()=>{
              if (this.preSelectedModel) {
                this.preSelectedModel.selected =false
                libstmobile.removePackage(this.preSelectedModel.packageId)
                this.preSelectedModel = undefined

                UIInstance.GetInstance().resetOverLap()
                EventBus.emitProcess()

                if (this.panelState == PanelState.Preview) {
                  DBManager.Instance().deleteStyle()
                }
              }
            })
            .margin({left: 10})
          List({space: 5}) {
            ForEach(this.itemData, (item: string, index) => {
              ListItem() {
                Text(item)// .margin({ top: 5 })
                  .fontColor(this.typeIndex == index ? '#000000' : '#555555')
                  .width(80)
                  .height(28)
                  .textAlign(TextAlign.Center)
                  .fontSize(12)
                  .backgroundColor(this.typeIndex == index ? '#F7F8FA' : Color.White)
                  .borderRadius(14)
              }
              .onClick(()=>{
                this.onSelectItem(index)
              })
            })
          }
          .alignListItem(ListItemAlign.Center)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .padding({right:0})
        }
        .width('100%')
        .height(38)

        Column(){
          List({space:5}) {
            ForEach(this.styleModel, (model: STEffectModel, index: number) => {
              ListItem() {
                Row(){
                  Stack(){
                    StickerCell({model:model})
                    Text(model.name)
                      .fontSize(10)
                      .textAlign(TextAlign.Center)
                      .width('100%')
                      .fontColor(Color.White)
                      .position({bottom:5})
                  }
                }
                .height('100%')
                .justifyContent(FlexAlign.Center)
              }
              .width(54)
              .height(68)
              .onClick(()=>{
                this.onSelectStyle(model,index)
              })
            })
          }
          .alignListItem(ListItemAlign.Center)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .listDirection(Axis.Horizontal) // List组件设置横向滚动
          .scrollBar(BarState.Off)
        }
        .padding({left: 10, right : 10})
        .width('100%')
        .height(116)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(154)
      .backgroundColor(Color.White)
    }
    .width('100%')
  }
}