import FilterResource from '../models/FilterResource'
import FilterObject from '../models/FilterObject'
import IndexPath from '../models/IndexPath'
import libstmobile from 'libentry.so'
import { BeautyType } from 'libentry.so'
import { common } from '@kit.AbilityKit';

const context = getContext(this) as common.UIAbilityContext;
const filesDir = context.filesDir
const resourceManager = context.resourceManager

@Component
export struct FilterPanel {
  onFilterSelectedCallback?: () => void
  onFilterStrengthChangedCallback?: () => void
  filterResource: FilterResource = new FilterResource()
  @State currentCategory: number = 0
  private listController: Scroller = new Scroller()
  @State selectedIndexPath: IndexPath | null = null
  private selectedColor = Color.White
  @State sliderValue: number = 80;
  build() {
    Column() {
      Text(`${Math.floor(this.sliderValue)}`){

      }
      .fontSize(14)
      .fontColor(Color.White)
      .position({ y:-10, x:`${this.sliderValue*0.6 + 20 - ((this.sliderValue-50)/100) * 4}%`}) //滑块offset
      .backgroundColor('#00000000')
      .markAnchor({x:'50%'})
      .visibility(this.selectedIndexPath && this.selectedIndexPath.index >= 0 ? Visibility.Visible : Visibility.Hidden)
      Slider({
        value: this.sliderValue,
        step: 1,
        min: 0,
        max: 100,
        style: SliderStyle.OutSet
      })
        .visibility(this.selectedIndexPath && this.selectedIndexPath.index >= 0 ? Visibility.Visible : Visibility.Hidden)
        .width('100%')
        .showTips(false)
        .showSteps(true)
        .padding({ left: '20%', right: '20%' })
        .onChange((value: number, mode: SliderChangeMode) => {
          this.sliderValue = value
          if (this.onFilterStrengthChanged !== undefined) {
            this.onFilterStrengthChanged(value)
          }
        })
      Column(){
        GridRow({
          columns: 4,
          // gutter: { x: 5, y: 10 },
          breakpoints: {
            value: ["400vp", "600vp", "800vp"],
            reference: BreakpointsReference.WindowSize
          },
          direction: GridRowDirection.Row
        }) {
          ForEach(Array.from(this.filterResource.resource.keys()), (item: string, index) => {
            GridCol({ span: { xs: 1, sm: 1, md: 1, lg: 1 }, offset: 0, order: 0 }) {
              Column() {
                Text($r(`app.string.${item}`))// .margin({ top: 5 })
                  .fontColor(this.currentCategory == index ? this.selectedColor : Color.Gray)
                  .width("100%")
                  .height('100%')
                  .textAlign(TextAlign.Center)
                  .fontSize(14)
              }
              .width("100%")
              .height('100%')
              .justifyContent(FlexAlign.Center)
            }
            .height('100%')
            .onClick(() => {
              if (this.currentCategory != index) {
                this.currentCategory = index
                let key = Array.from(this.filterResource.resource.keys())[this.currentCategory]
                this.listController.scrollToIndex(0)
              }
            })
          })
        }
        .width('100%')
        .height(50)

        List({ scroller: this.listController, initialIndex: 0, space: 0 }) {
          ForEach(this.filterResource.resource.get(Array.from(this.filterResource.resource.keys())[this.currentCategory]), (item: FilterObject, index) => {
            ListItem() {
              Column() {
                Image($rawfile(item.thumbnail))
                  .height(50)
                  .margin({ top: 10, bottom: 5 })
                  .borderColor(this.selectedColor)
                  .borderWidth(this.selectedIndexPath != null && this.selectedIndexPath.category == this.currentCategory && this.selectedIndexPath.index == index ? 2 : 0)
                  .borderRadius(10)

                Text(item.name)
                  .fontSize(10)
                  .maxLines(1)
                  .fontColor(this.selectedIndexPath != null && this.selectedIndexPath.category == this.currentCategory && this.selectedIndexPath.index == index ? this.selectedColor : Color.Gray)
              }
              .width(60)
              .onClick(() => {
                let isInvert = false
                if (this.selectedIndexPath?.category == this.currentCategory && this.selectedIndexPath?.index == index) {
                  this.selectedIndexPath.index = -1
                  isInvert = true
                } else {
                  let selectedIndexPath = new IndexPath()
                  selectedIndexPath.category = this.currentCategory
                  selectedIndexPath.index = index
                  this.selectedIndexPath = selectedIndexPath
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
  aboutToDisappear(): void {
      this.onFilterSelectedCallback = undefined;
      this.onFilterStrengthChangedCallback = undefined;
  }

  onFilterSelected(filter: FilterObject, isInvert: boolean){
    if (isInvert) {
      libstmobile.setBeautyStrength(BeautyType.EFFECT_BEAUTY_FILTER, 0)
    } else {
      let fileContent = resourceManager.getRawFileContentSync(filter.path)
      const buffer = fileContent.buffer.slice(0);
      libstmobile.setBeautyPackageByBuffer(BeautyType.EFFECT_BEAUTY_FILTER, buffer)
      libstmobile.setBeautyStrength(BeautyType.EFFECT_BEAUTY_FILTER, this.sliderValue / 100.0)
      this.onFilterSelectedCallback?.()
    }
  }

  onFilterStrengthChanged(strength: number){
    libstmobile.setBeautyStrength(BeautyType.EFFECT_BEAUTY_FILTER, strength / 100.0)
    this.onFilterStrengthChangedCallback?.()
  }

  onReset(){
    if (this.selectedIndexPath) {
      this.selectedIndexPath.index = -1
    }
    libstmobile.setBeautyStrength(BeautyType.EFFECT_BEAUTY_FILTER, 0)
    this.sliderValue = 80
    this.onFilterStrengthChangedCallback?.()
  }
}