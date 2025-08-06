import { BeautyType } from 'libentry.so'
import BeautyGroup from '../models/Beauty/BeautyGroup'
import BeautyObject from '../models/Beauty/BeautyObject'
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager'
import IndexPath from '../models/IndexPath'

@Component
struct BindStrengthView {
  // 子组件ViewA的@ObjectLink的类型是ClassA
  @ObjectLink beautyObject: BeautyObject

  build() {
    Text(`${Math.floor(this.beautyObject.currentStrength == undefined ? 0 : this.beautyObject.currentStrength *100)}`)
      .fontSize(10)
      .maxLines(1)
      .fontColor(Color.White)
  }
}

@Component
export struct BeautyPanel {
  onBeauSelected?: (beauty: BeautyObject) => void
  onBeautyFirstChanged?: (beauty: BeautyObject) => void
  onBeautyStrengthChanged?: (beauty: BeautyObject) => void
  onResetOrClear?: (beautys: BeautyObject[]) => void

  @State currentCategory: number = 0
  private listController: Scroller = new Scroller()
  @State selectedIndexPath: IndexPath | null = null
  @State currentStrength: number = 0
  @State subDataSource: BeautyObject[] | undefined = undefined
  @State isShowSub: boolean = false
  @State selectedSubIndex: number = -1
  private resourceManager = BeautyResourceManager.getInstance()
  private curObject : BeautyObject | undefined
  private isChangeObj = false

  @State isStartCenter:boolean=false
  build() {
    Column() {
      Text(`${Math.floor(this.currentStrength)}`){

      }
      .fontSize(14)
      .fontColor(Color.White)
      .position({
        x:`${
          this.isStartCenter?
            (this.currentStrength*0.3 + 50 - ((this.currentStrength)/200) * 4)
            :
            (this.currentStrength*0.6 + 20 - ((this.currentStrength-50)/100) * 4)}%`,
        y:-10

      }) //滑块offset
      .backgroundColor('#00000000')
      .markAnchor({x:'50%'})
      .visibility(this.isShowSub ?
        (this.selectedSubIndex >= 0 ? Visibility.Visible : Visibility.Hidden) :
        (this.selectedIndexPath && this.selectedIndexPath.index >= 0 &&
          this.currentCategory == this.selectedIndexPath.category ? Visibility.Visible : Visibility.Hidden))
      Slider({
        value: this.currentStrength,
        step: 1,
        min: this.isStartCenter?-100:0,
        max: 100,
        style: SliderStyle.OutSet
      })
        .visibility(this.isShowSub ?
          (this.selectedSubIndex >= 0 ? Visibility.Visible : Visibility.Hidden) :
          (this.selectedIndexPath && this.selectedIndexPath.index >= 0 &&
            this.currentCategory == this.selectedIndexPath.category ? Visibility.Visible : Visibility.Hidden))
        .width('100%')
        .showTips(false)
        .showSteps(true)
        .padding({ left: '20%', right: '20%' })
        .onChange((value: number, mode: SliderChangeMode) => {
          this.currentStrength = value
          if (this.onBeautyStrengthChanged != undefined) {
            if (mode == SliderChangeMode.Begin){
              //type一致的互斥
              //this.resourceManager.resetMutex(this.curObject)
              if (this.curObject?.cleanObject.type == 101) { //美白
                this.resourceManager.whiteMutexs.forEach(element => {
                  element.currentStrength = 0.0
                  this.onBeautyStrengthChanged?.(element)
                })
              } else if (this.curObject?.cleanObject.type == 103) { //磨皮
                this.resourceManager.smoothMutexs.forEach(element => {
                  element.currentStrength = 0.0
                  this.onBeautyStrengthChanged?.(element)
                })
              }

              //other_mutual_beauty_type 定义的互斥 type不一致
              if (this.curObject?.cleanObject.other_mutual_beauty_type!=undefined) {
                this.curObject?.cleanObject.other_mutual_beauty_type.forEach((type)=>{
                  if (this.isShowSub && this.subDataSource != undefined) {
                    this.subDataSource.forEach((subObj)=>{
                      if (subObj.cleanObject.type == type) {
                        subObj.currentStrength = 0
                        this.onBeautyStrengthChanged?.(subObj)
                      }
                    })
                  } else {
                    this.resourceManager.dataSource[this.currentCategory].beauties.forEach((obj: BeautyObject)=>{
                      if (obj.cleanObject.type == type) {
                        obj.currentStrength = 0
                        this.onBeautyStrengthChanged?.(obj)
                      }
                    })
                  }
                })
              }
            }
            if (this.isShowSub && this.subDataSource != undefined) {
              this.subDataSource[this.selectedSubIndex].currentStrength = value/100.0
              if (mode == SliderChangeMode.Begin && this.isChangeObj){
                this.onBeautyFirstChanged?.(this.subDataSource[this.selectedSubIndex])
                this.isChangeObj = false
              }
              this.onBeautyStrengthChanged(this.subDataSource[this.selectedSubIndex])
            } else {
              if (this.selectedIndexPath) {
                this.resourceManager.dataSource[this.currentCategory].beauties[this.selectedIndexPath.index].currentStrength =
                  value/100.0
                if (mode == SliderChangeMode.Begin && this.isChangeObj){
                  this.onBeautyFirstChanged?.(this.resourceManager.dataSource[this.currentCategory].beauties[this.selectedIndexPath.index])
                }
                this.onBeautyStrengthChanged(this.resourceManager.dataSource[this.currentCategory].beauties[this.selectedIndexPath.index])
              }
            }
          }
        })
      GridRow({
        columns: this.resourceManager.dataSource.length,
        // gutter: { x: 5, y: 10 },
        breakpoints: {
          value: ["400vp", "600vp", "800vp"],
          reference: BreakpointsReference.WindowSize
        },
        direction: GridRowDirection.Row
      }) {
        ForEach(Array.from(this.resourceManager.dataSource), (item: BeautyGroup, index) => {
          GridCol({
            span: {
              xs: 1,
              sm: 1,
              md: 1,
              lg: 1
            },
            offset: 0,
            order: 0
          }) {
            Column() {
              Text(item.name)// .margin({ top: 5 })
                .fontColor(this.currentCategory == index ? Color.White : Color.Gray)
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
              this.subDataSource = this.resourceManager.dataSource[this.currentCategory].beauties
              this.listController.scrollToIndex(0)
            }
          })
        })
      }
      .width('100%')
      .height(40)
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.9)

      List({ scroller: this.listController, initialIndex: 0, space: 0 }) {
        ForEach(this.subDataSource,
          (item: BeautyObject, index) => {
            ListItem() {
              Column() {

                Image(this.isShowSub ?
                  (this.selectedSubIndex == index ? $r(`app.media.${item.cleanObject.highlightIcon}`) :
                  $r(`app.media.${item.cleanObject.defaultIcon}`)) :
                  (this.selectedIndexPath != null && this.selectedIndexPath.category == this.currentCategory &&
                    this.selectedIndexPath.index == index ? $r(`app.media.${item.cleanObject.highlightIcon}`) :
                  $r(`app.media.${item.cleanObject.defaultIcon}`)))
                  .height(50)
                  .margin({ top: 10, bottom: 5 })// .borderColor(this.selectedColor)
                    // .borderWidth(this.selectedIndexPath != null && this.selectedIndexPath.category == this.currentCategory && this.selectedIndexPath.index == index ? 2 : 0)
                  .borderRadius(10)

                Text(item.cleanObject.name)
                  .fontSize(10)
                  .maxLines(1)
                  .fontColor(Color.White)

                if (item.cleanObject.type > 0 && (item.subBeauties == undefined||item.subBeauties.length <=0)) {
                  BindStrengthView({ beautyObject: item})
                }
              }
              .width(60)
              .onClick(() => {
                // let isInvert = false
                if (item.subBeauties != undefined && item.subBeauties.length > 0) {
                  this.curObject = item
                  this.subDataSource = item.subBeauties
                  this.isShowSub = true
                } else if (item.cleanObject.type == BeautyType.EFFECT_BEAUTY_BACK) { // 返回
                  this.isShowSub = false
                  this.subDataSource = this.resourceManager.dataSource[this.currentCategory].beauties
                } else {
                  this.isChangeObj = true
                  this.curObject = item
                  if (this.isShowSub) {
                    this.selectedSubIndex = index
                  } else {
                    let selectedIndexPath = new IndexPath()
                    selectedIndexPath.category = this.currentCategory
                    selectedIndexPath.index = index
                    this.selectedIndexPath = selectedIndexPath
                  }
                  this.currentStrength = item.currentStrength ? item.currentStrength*100:0
                  this.isStartCenter = item.cleanObject.start_center
                  if (this.onBeauSelected != undefined) {
                     this.onBeauSelected(item)
                  }
                }
              })
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
          this.clearAllEffects()
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
          this.clearAllEffects()
          this.resetAllEffects()
          this.reset()
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.85)
    }
  }

  aboutToDisappear(): void {
    this.onBeauSelected = undefined;
    this.onBeautyFirstChanged = undefined;
    this.onBeautyStrengthChanged = undefined;
    this.onResetOrClear = undefined;
  }
  aboutToAppear(): void {

  }

  clearAllEffects() {
    if (this.onResetOrClear) {
      let beauties: BeautyObject[] = this.resourceManager.dataSource[this.currentCategory].beauties
      let result: BeautyObject[] = []
      beauties.forEach(element => {
        if (element.subBeauties && element.subBeauties.length > 0) {
          element.subBeauties.forEach(subElement => {
            subElement.currentStrength = 0
            result.push(subElement)
          })
        } else if (element.cleanObject.type != BeautyType.EFFECT_BEAUTY_BACK) {
          element.currentStrength = 0
          result.push(element)
        }
      })
      this.onResetOrClear(result)
    }
  }

  resetAllEffects() {
    if (this.onResetOrClear) {
      let beauties: BeautyObject[] = this.resourceManager.dataSource[this.currentCategory].beauties
      let result: BeautyObject[] = []
      beauties.forEach(element => {
        if (element.subBeauties && element.subBeauties.length > 0) {
          element.subBeauties.forEach(subElement => {
            subElement.currentStrength = subElement.cleanObject.defaultStrength
            if (subElement.currentStrength! > 0) {
              result.push(subElement)
            }
          })
        } else if (element.cleanObject.type != BeautyType.EFFECT_BEAUTY_BACK) {
          element.currentStrength = element.cleanObject.defaultStrength
          if (element.currentStrength! > 0) {
            result.push(element)
          }
        }
      })
      this.onResetOrClear(result)
    }
  }

  reset() {
    this.selectedIndexPath = null
    this.selectedSubIndex = -1
  }
}