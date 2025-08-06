import { STEffectModel } from '../models/Sticker/STEffectModel'
import { CellState } from '../models/STMaterial'
import { STMaterialManager } from '../models/STMaterialManager'
import { MakeUpCell } from './MakeUpCell'
import { STListItem } from '../models/STListItem'

import { ListItemCell, Item } from './ListItemCell'
import map from '@hms.core.map.map'
import { Popup } from '@kit.ArkUI'

@Component
export struct MakeUpPanel {
  @State itemData : STListItem<Item> = new STListItem<Item>()
  @State makeUpModel : STListItem<STEffectModel> = new STListItem<STEffectModel>()
  makeUpModelList : STListItem<STListItem<STEffectModel>> = new STListItem<STListItem<STEffectModel>>()

  //@State makeUpModel : STListItem<STEffectModel> = new STListItem<STEffectModel>()

  @State selectItem : Item | undefined = undefined
  @State selectItemIndex : number = 0

  @State selectMakeUpMap : Map<number, STEffectModel> = new Map()

  @State strengthMap : Map<number, number> = new Map()

  /**
   * callback
   */
  didSelectedMaterial?:(path:STEffectModel) => void
  didDeselectedMaterial?:(type: number) => void
  //onMakeUpClose?:(close:boolean) => void
  onMakeUpStrengthChanged?: (type: number, strength : number) => void

  onResetOrClear?: (makeUps: STEffectModel[]) => void

  private manager = STMaterialManager.GetInstance()
  private listScroller = new ListScroller()
  private itemListScroller = new ListScroller()

 aboutToDisappear(): void {
    this.didSelectedMaterial = undefined
   this.didDeselectedMaterial = undefined
   this.onMakeUpStrengthChanged = undefined
   this.onResetOrClear = undefined
 }
  aboutToAppear(): void {
    this.selectMakeUpMap.forEach((model)=>{
      model.selected = false
    })
    this.selectMakeUpMap.clear()

    if(this.makeUpModelList.totalCount() <= 0){
        let index = 0;
        this.manager.makeUps()?.forEach((item, key)=>{
          this.itemData.pushData(new Item(item,  index == 0 ? true : false))
          this.strengthMap.set(index, 80)
          index ++;
          let effects = new STListItem<STEffectModel>()
          item.effects?.forEach((model)=>{
            model.type = item.type!
            model.selected = false
            effects.pushData(model)
          })
          this.makeUpModelList.pushData(effects)
        })
    }


    this.updateItems(0)
  }

  updateCell(index : number){

    let curItem = this.makeUpModel.getData(index)

    let preItem = this.selectMakeUpMap.get(this.selectItemIndex)
    if (preItem != undefined && preItem != curItem) {
      preItem.selected = false
    }
    curItem.selected = !curItem.selected
    if (curItem.selected){
      this.selectMakeUpMap.set(this.selectItemIndex,  curItem)

      if (curItem.pkgLocalPath){
        if (this.didSelectedMaterial) {
          this.didSelectedMaterial(curItem)
          this.onMakeUpStrengthChanged?.(curItem.type, this.strengthMap.get(this.selectItemIndex)!)
        }
        return
      }
      if (!curItem.downloaded) {
        curItem.state = CellState.Downloading
      }
      this.manager.downloadMaterial(curItem, (filePath) => {
        curItem.downloaded = true
        curItem.pkgLocalPath = filePath
        curItem.state = CellState.Downloaded
        if (curItem.selected && this.didSelectedMaterial) {
          this.didSelectedMaterial(curItem)
          this.onMakeUpStrengthChanged?.(curItem.type, this.strengthMap.get(this.selectItemIndex)!)
        }
      }, (message) =>{
        curItem.state = CellState.NeedDonwload
      })
    }else{
      this.selectMakeUpMap.delete(this.selectItemIndex)

      if (curItem.downloaded) {
        if (this.didDeselectedMaterial) {
          this.didDeselectedMaterial(curItem.type)
        }
      }
    }
  }


  updateItems(index:number){
    this.selectItemIndex = index
    this.listScroller.scrollToIndex(index, true, ScrollAlign.CENTER)
    this.selectItem = this.itemData.getData(index)
    let dataArray = this.itemData.getDataArray()
    dataArray.forEach(element => {
      element.selected = false
    });
    animateTo({ duration: 300, curve: Curve.Friction}, () => {
      if(this.selectItem){
        this.selectItem.selected = true
      }
    })

    this.makeUpModel.deleteAllData()
    let temp = this.makeUpModelList.getData(index)
    for (let index = 0; index < temp.totalCount(); index++) {
      this.makeUpModel.pushData(temp.getData(index))
    }

    /*let values = Array.from(this.manager.makeUps()!.values())
    this.makeUpModel.deleteAllData()
    Array.from(values[index].effects!).forEach((model) =>{
      model.type = values[index].type!
      this.makeUpModel.pushData(model)
    })*/
  }

  onReset(){
    this.selectMakeUpMap.forEach((model)=>{
      model.selected = false
      this.didDeselectedMaterial?.(model.type)
    })
    this.selectMakeUpMap.clear()

    this.strengthMap.forEach((v,k)=>{
      this.strengthMap.set(k,80)
    })
  }
  build() {
    Column() {
      /*STSlider({curItem:this.curItem, sliderCallback:this.onMakeUpStrengthChanged})
        .padding({ left: 20, right: 20 })  {this.sliderValue/2 + (this.sliderValue-50)*0.6}
        */
      Text(`${Math.floor( this.strengthMap.get(this.selectItemIndex)??0)}`){

      }
      .fontSize(14)
      .fontColor(Color.White)
      .position({ y:-10, x:`${(this.strengthMap.get(this.selectItemIndex)??0)*0.6 + 20 - ((this.strengthMap.get(this.selectItemIndex)??0-50)/100) * 4}%`}) //滑块offset
      .backgroundColor('#00000000')
      .markAnchor({x:'50%'})
      .visibility(this.selectMakeUpMap.get(this.selectItemIndex) ? Visibility.Visible : Visibility.Hidden)
      Slider({
        value: this.strengthMap.get(this.selectItemIndex),
        step: 1,
        min: 0,
        max: 100,
        style: SliderStyle.OutSet
      })
        .visibility(this.selectMakeUpMap.get(this.selectItemIndex) ? Visibility.Visible : Visibility.Hidden)
        .width('100%')
        .showTips(false)
        .showSteps(true)
        .padding({ left: '20%', right: '20%' })
        .onChange((value: number, mode: SliderChangeMode) => {
          let curEffectModel = this.selectMakeUpMap.get(this.selectItemIndex)
          if(curEffectModel != undefined){
            this.strengthMap.set(this.selectItemIndex, value)
            this.onMakeUpStrengthChanged?.(curEffectModel.type, value)
          }
        })

      Column() {
        this.itemList()
        this.makeupList()
        //this.closeBtn()
        Row() {
          Row({ space: 3 }) {
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Image($r('app.media.clear_makeup')).width(20).height(20)
            }
            .width(40)
            .height(40)
            .margin({ left: 15 })
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
        .margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.85)
    }
    .width('100%')
    .height('100%')
  }


  @Builder
  itemList(){
    List({space: 5, scroller:this.listScroller}) {
      LazyForEach(this.itemData, (item: Item, index) => {
        ListItem() {
          ListItemCell({cellItem:item})
            .width(70)
            .height('100%')
            .padding({top:10})
        }
        .onClick(()=>{
          this.updateItems(index)
        })
      })
    }
    .height(50)
    .width('100%')
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
  }

  @Builder
  makeupList(){
    Row(){
      this.noneBut()
      List({space: 20, scroller:this.itemListScroller}) {
        LazyForEach(this.makeUpModel, (item: STEffectModel, index) => {
          ListItem() {
            MakeUpCell({model:item})
              .width(60)
              .height('100%')
          }
          .borderRadius(25)
          .onClick(()=>{
            this.updateCell(index)
            this.itemListScroller.scrollToIndex(index, true, ScrollAlign.CENTER)
          })
        },(item : STEffectModel, index : number)=> { return item.name! + index })
      }
      .alignListItem(ListItemAlign.Center)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .height(60)
    .width('100%')
    .padding({left: 10, right:10})
  }

  @Builder
  noneBut(){
    Column(){
      Stack(){
        Image($r("app.media.none_process"))
          .width(40)
          .height(40)
          .onClick(() =>{
            //clear sticker
            let model = this.selectMakeUpMap.get(this.selectItemIndex)
            if (model != undefined) {
              this.strengthMap.set(this.selectItemIndex,80)
              model.selected = false
              this.selectMakeUpMap.delete(this.selectItemIndex)
              this.didDeselectedMaterial?.(this.selectItem?.content.type!)
            }
          })
        if(this.selectMakeUpMap.get(this.selectItemIndex) == undefined){
          Image($r(`app.media.makeup_select`)).width(40)
            .height(40)
        }
      }
      Blank()
      Text("none")
        .fontSize(12)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor(Color.Gray)
    }
    .width(50)
    .height(60)
  }

  @Builder
  clearBtn(){
    Row(){
      Image("app.media.clear_makeup")
        .autoResize(true)
        .margin({right:10})
      Text("清零")
        .fontSize(12)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
      Blank()
    }
  }
}