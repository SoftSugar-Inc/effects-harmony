import http from '@ohos.net.http';
import { STImageCache } from './STImageCache';
import { STHttpProgress } from './STHttpProgres';
import { Callback } from '@ohos.base';
import { CacheType } from './STImageCache';
import { taskpool, url } from '@kit.ArkTS';


export enum STWebImageOption {
  STWebImageOptionIgnoreNode = 0,
  STWebImageOptionImageAction = 1 << 1,
  STWebImageOptionIgnoreDiskCache = 1 << 2,
  STWebImageOptionRefrashImageCache = 1 << 3,
  STWebImageOptionUseNSURLCache = 1 << 4
}


@Concurrent
async function requestImage(imageUrl: string){
  let httpRequest = http.createHttp()
  let ret = await httpRequest.request(imageUrl)
  return ret ? (ret.result as ArrayBuffer) : undefined
}


export class STWebImageOperation {
  private imageUrl : string
  private options : STWebImageOption
  private  cache : STImageCache

  constructor(imageUrl : string, options : STWebImageOption, cache : STImageCache) {
    this.imageUrl = imageUrl
    this.options = options
    this.cache = cache
  }

  async getImageFromWeb(progress?:Callback<STHttpProgress>) : Promise<ArrayBuffer | undefined>{
    let httpRequest = http.createHttp()
    if (progress != undefined) {
      httpRequest.on("dataReceiveProgress", (data) => {
        let pro = new STHttpProgress()
        pro.receiveSize = data.receiveSize
        pro.totalSize = data.totalSize
        progress(pro)
      })
    }
    let ret = await httpRequest.request(this.imageUrl)
    if (http.ResponseCode.OK != ret.responseCode) {
      console.error(`@@@ ${this.imageUrl} request ${ret.responseCode}`)
    }
    return ret ? (ret.result as ArrayBuffer) : undefined
  }


  async startRequestOperation(imageUrl: string, completion?:Callback<ArrayBuffer | undefined>, progress?:Callback<STHttpProgress>) {
    this.imageUrl = imageUrl
    if (this.cache
      && !(this.options & STWebImageOption.STWebImageOptionRefrashImageCache)
      && !(this.options & STWebImageOption.STWebImageOptionUseNSURLCache)) {
      let ret = await this.cache.getWithType(imageUrl, CacheType.CacheTypeMemory)
      if (ret) {
        if (completion) completion(ret)
        return
      }
      if (!(this.options & STWebImageOption.STWebImageOptionIgnoreDiskCache)) {
        let ret = await this.cache.getWithType(imageUrl, CacheType.CacheTypeDick)
        if (ret) {
          await this.cache.setWithType(imageUrl, ret, CacheType.CacheTypeMemory)
          if (completion) completion(ret)
          return
        }
      }
    }
    let ret = await this.getImageFromWeb(progress)
    if (ret != undefined) {
      if (this.cache
        || (this.options & STWebImageOption.STWebImageOptionRefrashImageCache)) {
        let type = this.options & STWebImageOption.STWebImageOptionIgnoreDiskCache ? CacheType.CacheTypeMemory :
        CacheType.CacheTypeAll
        await this.cache.setWithType(imageUrl, ret, type)
        if(completion) completion(ret)
      }
    }else{
      if(completion) completion(ret)
    }
    // let httpRequest = http.createHttp()
    // if (progress != undefined) {
    //   httpRequest.on("dataReceiveProgress", (data) => {
    //     let pro = new STHttpProgress()
    //     pro.receiveSize = data.receiveSize
    //     pro.totalSize = data.totalSize
    //     progress(pro)
    //   })
    // }
    // httpRequest.request(this.imageUrl, (err, ret) =>{
    //   if (err) {
    //     console.error(`networking error`)
    //   }else{
    //     let remoteData = (ret.result as ArrayBuffer)
    //     console.log(MYTAG, `set data with type ${remoteData} ${remoteData.byteLength}`)
    //     this.cache.setWithType(imageUrl, new Uint8Array(remoteData), CacheType.CacheTypeAll)
    //     if (completion) {completion(remoteData as Uint8Array)
    //     }
    //   }
    // })
  }
}