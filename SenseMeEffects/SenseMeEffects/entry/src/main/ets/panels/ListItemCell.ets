import { STGroupResult } from '../models/Sticker/STGroupResult'

@Extend(Text)
function listitemStyle() {
  .fontSize(14)
  .width('100%')
  .height(30)
  .textAlign(TextAlign.Center)
}

@Observed
export class Item{
  public content : STGroupResult
  public selected : boolean
  constructor(content:STGroupResult, selected : boolean) {
    this.content = content
    this.selected = selected
  }
}

@Component
export struct ListItemCell {
  @ObjectLink cellItem : Item
  build() {
    Column(){
      Text(this.cellItem.content.listName)
        .listitemStyle()
        .fontColor(this.cellItem.selected ? Color.White : Color.Gray)
        .padding({top: 5})
      if(this.cellItem.selected){
        Rect()
          .width('50%')
          .height(1)
          .fill(Color.White)
          .align(Alignment.Bottom)
      }
    }
    // .backgroundColor(Color.Red)
  }
}