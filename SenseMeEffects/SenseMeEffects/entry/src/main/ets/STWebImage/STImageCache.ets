import { TAG } from '@ohos/hypium/src/main/Constant'
import { STDickCache } from './Cache/STDickCache'
import { STMemoryCache } from './Cache/STMemoryCache'

export enum CacheType{
  CacheTypeNone  = 0,
  CacheTypeMemory = 1 << 0,
  CacheTypeDick = 1 << 1,
  CacheTypeAll = CacheTypeMemory | CacheTypeDick
}

let MYTAG : string = "STImageCache"

export class STImageCache {
  private  static  instance : STImageCache
  private  dickCache : STDickCache
  private  memoryCache : STMemoryCache<string, ArrayBuffer>

  private constructor() {
    this.dickCache = new STDickCache("STImageDB")
    this.memoryCache = new STMemoryCache<string, ArrayBuffer>(10)
  }

  public static GetInstance(){
    if (!STImageCache.instance) {
      STImageCache.instance = new STImageCache()
    }
    return STImageCache.instance
  }

  async set(key : string, value : ArrayBuffer) {
    await this.setWithType(key, value, CacheType.CacheTypeAll)
  }

  async setWithType(key : string, value : ArrayBuffer, type : CacheType){
    if (key == null || key.trim().length == 0 || value == null || value.byteLength == 0 ) return
    if (type & CacheType.CacheTypeMemory) {
      this.memoryCache.set(key, value)
    }
    if (type & CacheType.CacheTypeDick) {
      await this.dickCache.set(key, value)
    }
  }

  async get(key : string) : Promise<ArrayBuffer | undefined>{
    return await this.getWithType(key, CacheType.CacheTypeAll)
  }

  async getWithType(key : string, type: CacheType) : Promise<ArrayBuffer | undefined>{
    if (key == null || key.trim().length == 0) return undefined
    if (type & CacheType.CacheTypeMemory) {
      let data = this.memoryCache.get(key)
      if (data) {
        return data as ArrayBuffer
      }
    }
    if (type & CacheType.CacheTypeDick) {
      let value = await this.dickCache.get(key)
      if (value) {
        this.memoryCache.set(key, value)
        return value as ArrayBuffer
      }
      return undefined
    }
    return undefined

  }

}