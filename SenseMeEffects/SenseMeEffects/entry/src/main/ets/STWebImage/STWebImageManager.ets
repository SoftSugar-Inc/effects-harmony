import { STImageCache } from './STImageCache'
import { STWebImageOperation, STWebImageOption } from './STWebImageOperation'
import { Callback } from '@kit.BasicServicesKit'
import { STHttpProgress } from './STHttpProgres';
import taskpool from '@ohos.taskpool';
import { STWebImageSetter } from './STWebImageSetter';

export class STWebImageManager {
  private static instance : STWebImageManager
  public readonly  cache : STImageCache

  private constructor() {
    this.cache = STImageCache.GetInstance()
  }

  static GetInstance(){
    if (!STWebImageManager.instance) {
      STWebImageManager.instance = new STWebImageManager()
    }
    return STWebImageManager.instance
  }

  requestWithUrl(imageUrl : string, completion?:Callback<ArrayBuffer | undefined>, progress?:Callback<STHttpProgress>){
    let imageOperation = new STWebImageOperation(imageUrl, STWebImageOption.STWebImageOptionIgnoreNode, this.cache)
    imageOperation.startRequestOperation(imageUrl, completion, progress)
    return imageOperation
  }
}
