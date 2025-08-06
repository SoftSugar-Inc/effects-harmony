import { WebImage } from '../STWebImage/WebImage'
import { STEffectModel } from '../models/Sticker/STEffectModel'
import { CellState } from '../models/STMaterial'

@Component
export struct MakeUpCell {
  @ObjectLink model : STEffectModel

  build(){
    Column(){
      Stack({alignContent:Alignment.Center}){
        WebImage({imageUrl:this.model.thumbnail, imageData:'', radius:25})
        if (this.model.selected){
          Image($r(`app.media.makeup_select`))
        }
        if (this.model.state == CellState.Downloading){
          LoadingProgress()
            .color(Color.White)
        }
      }
      .width(40)
      .height(40)
      Blank()
      Text(this.model.name)
        .fontSize(12)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .height('100%')
  }
}