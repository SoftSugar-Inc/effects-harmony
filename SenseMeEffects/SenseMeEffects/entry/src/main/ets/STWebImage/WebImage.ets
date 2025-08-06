import image from '@ohos.multimedia.image';
import { STWebImageManager } from  './STWebImageManager'
import { STHttpProgress } from './STHttpProgres';
import { STWebImageSetter } from './STWebImageSetter';


@Component
export struct WebImage {
  @State imageData : string | PixelMap | ResourceStr |  undefined = undefined

  private imageUrl : string | undefined = undefined
  private radius : number = 0
  public setter : STWebImageSetter | undefined = undefined
  private webManager : STWebImageManager = STWebImageManager.GetInstance()

  async st_requestOption(imageUrl : string, completion?:Callback<ArrayBuffer|undefined>, progress?:Callback<STHttpProgress>){
    if (this.setter == undefined) {
      this.setter = new STWebImageSetter()
    }
    let ret = await this.webManager.cache.get(imageUrl)
    if (ret) {
      if(completion) completion(ret)
      return
    }
    let sential = this.setter!.cancelWithImageUrl(imageUrl)
    this.setter!.setOptionWithSential(sential, this.webManager, completion, progress)
  }


  aboutToAppear(): void {
    if (this.imageUrl) {
      this.st_requestOption(this.imageUrl, (data:ArrayBuffer | undefined)=>{
        if (data) {
          let options: image.DecodingOptions = {
            editable: true,
            desiredPixelFormat: image.PixelMapFormat.RGBA_8888
          }
          let imageSource: image.ImageSource = image.createImageSource(data)
          if (imageSource){
            imageSource.createPixelMap(options).then((pixelMap: PixelMap) => {
              this.imageData = pixelMap
            })
          }else{
            console.error(`@@@ imageSource is empty`)
          }
        }else{
          console.error(`@@@ data is empty`)
        }
      }, (progress:STHttpProgress) =>{
        console.info(`current progress ${progress.receiveSize/progress.totalSize}}`)
      })
    }else{
      console.error(`there is not imageUrl`)
    }
  }

  
  build() {//UI描述
    Row() {
      Image(this.imageData)
        .width('100%')
        .height('100%')
        .borderRadius(this.radius)
    }
  }
}