import { taskpool } from '@kit.ArkTS'
import { STWebImageManager } from './STWebImageManager'
import { image } from '@kit.ImageKit'
import { STAtomicCounter } from './STAtomicCounter'
import { STHttpProgress } from './STHttpProgres';

export class STWebImageSetter {
  private  _sential : number = 0
  private  _imageUrl : string = ''
  private  _counter : STAtomicCounter = new STAtomicCounter(0)

  cancelWithImageUrl(imageUrl : string) : number{
    this._imageUrl = imageUrl
    return this._sential
  }

  setOptionWithSential(sential : number, manager : STWebImageManager, completion?:Callback<ArrayBuffer | undefined>, progress?:Callback<STHttpProgress>) {
    if(sential != this._sential) {
      if(completion) completion(null)
      return
    }
    manager.requestWithUrl(this._imageUrl, (data)=>{
      if(completion) completion(data)
    },(pro)=>{
      if(progress) progress(pro)
    })
    sential = this._counter.getValue()
    this._sential = sential
    return sential
  }

}