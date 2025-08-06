import { expect } from '@ohos/hypium'
import { STEffectModel } from '../models/Sticker/STEffectModel'
import { STListItem } from '../models/STListItem'
import { CellState } from '../models/STMaterial'
import { STMaterialManager } from '../models/STMaterialManager'
import { StickerCell } from './StickerCell'
import { ListItemCell, Item } from './ListItemCell'

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
  private preSelectedModel : STEffectModel | undefined = undefined
  /**
   * callback
   */
  didSelectedMaterial?:(model: STEffectModel) => void
  didDeselectedMaterial?:(model: STEffectModel) => void
  onClearMaterial?:(model: STEffectModel|undefined) => void
  //onStickerClose?:(close:boolean) => void

  aboutToDisappear(): void {
    this.didSelectedMaterial = undefined;
    this.didDeselectedMaterial = undefined;
    this.onClearMaterial = undefined;
  }
  aboutToAppear(): void {
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
    if (curItem.selected){
      if (this.preSelectedModel != curItem){
        this.preSelectedModel.selected = false
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

  build() {
    Column() {
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
                }
                this.onClearMaterial(this.preSelectedModel)
              }
            })

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
          .alignListItem(ListItemAlign.Center)
          .listDirection(Axis.Horizontal)
          .height('100%')
          .scrollBar(BarState.Off)
          .padding({right:0})
        }
        .height(50)
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
        .height(230)
        .width('100%')
      }
      .padding({ left: 12, right: 12 })
      .backgroundColor($r('app.color.beauty_panel_color'))
      .opacity(0.85)
    }
  }
}



