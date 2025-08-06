import { STKVStorage } from './STKVStorage'
import { ArrayList } from '@kit.ArkTS'

export class STDickCache {
  private kv : STKVStorage

  constructor(fileName : string) {
    this.kv = new STKVStorage(fileName)
  }

  async set(key : string, value : ArrayBuffer) : Promise<boolean> {
    if (key == "" || key.length == 0 || value.byteLength == 0 || value == null) return false
    let ret = await this.kv.set(key, value)
    return ret
  }

  async get(key : string) : Promise<ArrayBuffer | undefined>{
    if (key == "" || key.length == 0) return undefined
    return await this.kv.get(key)
  }

  async delete(key: string) : Promise<boolean>{
    if (key == "" || key.length == 0) return false
    return await this.kv.delete(key)
  }

  async clear() : Promise<boolean>{
    return await this.kv.clear()
  }
}