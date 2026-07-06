import { WebImage } from '../STWebImage/WebImage'
import { STEffectModel } from '../models/Sticker/STEffectModel'
import { CellState } from '../models/STMaterial'

@Component
export struct StickerCell {
  @ObjectLink model : STEffectModel

  build(){
    Stack({alignContent:Alignment.BottomEnd}){
      //条件渲染
      if (this.model.selected){
        Image($r(`app.media.select_icon`))
          .objectFit(ImageFit.Fill)
      }
/*      WebImage({imageUrl:this.model.thumbnail, imageData:''})
        .padding(2)
        .borderRadius(5)*/
        Image(this.model.thumbnail)
        .padding(2)
        .borderRadius(5)
      if (this.model.state == CellState.Downloading){
        LoadingProgress()
          .color(Color.White)
      }
     /* if (!this.model.downloaded){
        if (this.model.state != CellState.Downloading) {
          Image($r(`app.media.download_icon`))
            .width('30%')
            .height('30%')
        }
      }*/
    }
  }
}