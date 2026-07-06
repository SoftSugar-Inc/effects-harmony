import FilterResource from '../models/FilterResource'
import FilterObject from '../models/FilterObject'
import IndexPath from '../models/IndexPath'
import libstmobile from '@softsugar/mars_effects'
import { BeautyType } from '@softsugar/mars_effects'
import { common } from '@kit.AbilityKit';
import DBManager from '../models/DBJson/DBManager'
import { HomeParam, HomeType } from '../common/STDefines'
import { PanelState } from './PreviewBottomPanel'
import { EventBus, EventType } from '../utils/EventBus'

const context = getContext(this) as common.UIAbilityContext;
const filesDir = context.filesDir
const resourceManager = context.resourceManager

@Component
export struct FilterPanel {
  filterResource: FilterResource = new FilterResource()
  private listController: Scroller = new Scroller()
  @State currentCategory: string = ""
  @State selectedIndex: IndexPath  = new IndexPath()
  private selectedColor = Color.White
  @State sliderValue: number = 80;

  @Prop panelState: PanelState

  private overLapIndex = new IndexPath()
  private itemController = new Scroller()
  build() {
    Column() {
      Text(`${Math.floor(this.sliderValue)}`){

      }
      .fontSize(14)
      .fontColor(Color.White)
      .position({ y:-10, x:`${this.sliderValue*0.6 + 20}%`}) //滑块offset
      .backgroundColor('#00000000')
      .markAnchor({x:'50%'})
      .visibility(this.selectedIndex.index >= 0 ? Visibility.Visible : Visibility.Hidden)
      Slider({
        value: this.sliderValue,
        step: 1,
        min: 0,
        max: 100,
        style: SliderStyle.OutSet
      })
        .visibility(this.selectedIndex.index >= 0 ? Visibility.Visible : Visibility.Hidden)
        .width('64%')
        .showTips(false)
        .showSteps(true)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.sliderValue = value
          if (this.onFilterStrengthChanged !== undefined) {
            this.onFilterStrengthChanged(value)
          }
        })
      Column(){
        List({space: 5,scroller :this.itemController}) {
          ForEach(Array.from(this.filterResource.resource.keys()), (item: string, index) => {
            ListItem() {
              Text($r(`app.string.${item}`))// .margin({ top: 5 })
                .fontColor(this.currentCategory == item ? this.selectedColor : Color.Gray)
                .width(70)
                .height('100%')
                .textAlign(TextAlign.Center)
                .fontSize(14)
                .padding({top:10})
            }
            .onClick(()=>{
              this.onItemSelect(index)

            })
          })
        }
        .alignListItem(ListItemAlign.Center)
        .listDirection(Axis.Horizontal)
        .height(50)
        .scrollBar(BarState.Off)
        .padding({right:0})


        List({ scroller: this.listController, initialIndex: 0, space: 0 }) {
          ForEach(this.filterResource.resource.get(this.currentCategory), (item: FilterObject, index) => {
            ListItem() {
              Column() {
                Image($rawfile(item.thumbnail))
                  .height(50)
                  .margin({ top: 10, bottom: 5 })
                  .borderColor(this.selectedColor)
                  .borderWidth(this.selectedIndex.category == this.currentCategory&& this.selectedIndex.index == index ? 2 : 0)
                  .borderRadius(10)

                Text(item.name)
                  .fontSize(10)
                  .maxLines(1)
                  .fontColor(this.selectedIndex.category == this.currentCategory&&this.selectedIndex.index == index ? this.selectedColor : Color.Gray)
              }
              .width(60)
              .onClick(() => {
                let isInvert = false
                if (this.selectedIndex.category == this.currentCategory&& this.selectedIndex.index == index) {
                  this.selectedIndex.index = -1
                  isInvert = true
                } else {

                  this.selectedIndex.category = this.currentCategory
                  this.selectedIndex.index = index

                  if (this.overLapIndex.categoryIndex >= 0) {
                    this.overLapIndex = new IndexPath()
                  }
                  /* this.currentLength = 80;*/
                }
                if (this.onFilterSelected !== undefined) {
                  this.onFilterSelected(item, isInvert)
                }
              })
            }
          }, (item : FilterObject, index)=>{
            return item.thumbnail + index.toString()
          })
        }
        .height(80)
        .width('100%')
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)

        Row() {
          Row({ space: 3 }){
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Image($r('app.media.clear_makeup')).width(20).height(20)
            }
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
            Text("清零")
              .fontSize(12)
              .fontColor(Color.White)
          }
          .onClick(() => {
            this.onReset()
          })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .margin({left:15})
        }
        .width('100%')
        .height(60)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.85)
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    EventBus.listenEvent(EventType.OnModelLoaded,()=>{
      if (globalThis.homeParam && globalThis.homeParam.type == HomeType.Filter){
        this.itemController.scrollTo(globalThis.homeParam.index)
        this.onItemSelect(globalThis.homeParam.index)
      }
      else {
        let item = DBManager.Instance().getFilter()
        if (this.panelState == PanelState.Preview) {
          const model = this.filterResource.resource.get(item.groupEnumName)?.[item.selectedPosition]
          if (model) {
            this.currentCategory = item.groupEnumName
            this.selectedIndex.category = item.groupEnumName
            this.selectedIndex.index = item.selectedPosition

            this.sliderValue = item.filterStrength *100
            this.onFilterStrengthChanged(item.filterStrength *100)

            this.onFilterSelected(model, false)

          }else {
            this.currentCategory = this.filterResource.resource.keys().next().value
          }
        }else{
          this.currentCategory = this.filterResource.resource.keys().next().value
        }
      }
    })

    EventBus.listenEvent(EventType.SetOverLapFilter,()=>{
      this.overLapIndex.category = this.selectedIndex.category
      this.overLapIndex.categoryIndex = this.selectedIndex.categoryIndex
      this.overLapIndex.index = this.selectedIndex.index

      this.selectedIndex.category = ''
      this.selectedIndex.categoryIndex = -1
      this.selectedIndex.index = -1
    })
    EventBus.listenEvent(EventType.ReSetOverLapFilter,()=>{
      this.selectedIndex.category = this.overLapIndex.category
      this.selectedIndex.categoryIndex = this.overLapIndex.categoryIndex
      this.selectedIndex.index = this.overLapIndex.index
      this.overLapIndex=new IndexPath()
    })
  }
  aboutToDisappear(): void {
    EventBus.unListenEvent(EventType.OnModelLoaded)
    EventBus.unListenEvent(EventType.SetOverLapFilter)
    EventBus.unListenEvent(EventType.ReSetOverLapFilter)
  }

  onItemSelect(index : number){
    let item = Array.from(this.filterResource.resource.keys())[index]
    if (this.currentCategory != item) {
      this.currentCategory = item
      this.listController.scrollToIndex(0)
    }
  }

  onFilterSelected(filter: FilterObject, isInvert: boolean){
    if (isInvert) {
      libstmobile.setBeautyStrength(BeautyType.EFFECT_BEAUTY_FILTER, 0)
      if (this.panelState == PanelState.Preview) {
        DBManager.Instance().deleteAllFilter()
      }
    } else {
      let fileContent = resourceManager.getRawFileContentSync(filter.path)
      const buffer = fileContent.buffer.slice(0);
      libstmobile.setBeautyPackageByBuffer(BeautyType.EFFECT_BEAUTY_FILTER, buffer)
      libstmobile.setBeautyStrength(BeautyType.EFFECT_BEAUTY_FILTER, this.sliderValue / 100.0)

      if (this.panelState == PanelState.Preview) {
        DBManager.Instance().updateFilter(this.selectedIndex.category, this.selectedIndex.index, filter.path)
        DBManager.Instance().updateFilterStrength(this.sliderValue / 100.0)
      }
    }
    EventBus.emitProcess()
  }

  onFilterStrengthChanged(strength: number){
    libstmobile.setBeautyStrength(BeautyType.EFFECT_BEAUTY_FILTER, strength / 100.0)

    if (this.panelState == PanelState.Preview) {
      DBManager.Instance().updateFilterStrength(strength / 100.0)
    }
    EventBus.emitProcess()
  }

  onReset(){
    if (this.selectedIndex) {
      this.selectedIndex.index = -1
    }
    libstmobile.setBeautyStrength(BeautyType.EFFECT_BEAUTY_FILTER, 0)
    this.sliderValue = 80
    if (this.panelState == PanelState.Preview) {
      DBManager.Instance().deleteAllFilter()
    }

    EventBus.emitProcess()
  }
}