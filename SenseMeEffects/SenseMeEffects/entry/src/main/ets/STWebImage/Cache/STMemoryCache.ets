import { HashMap } from '@kit.ArkTS'

export class STMemoryCache<K, V>{
  private capacity : number
  //Thread safe
  private cache : HashMap<K, V>

  private _count : number  = 0
  get count() : number {
    return this._count
  }

  constructor(capacity : number) {
    this.capacity = capacity
    this.cache = new HashMap()
  }

  get(key: K) : V | undefined {
    if (!this.cache.hasKey(key)) {
      return undefined
    }
    const value = this.cache.get(key)
    return value
  }

  set(key : K, value: V) {
    if (!this.cache.hasKey(key)) {
      this.cache.set(key, value)
      this._count++
    }else{
      this.cache.set(key, value)
    }
  }

  delete(key : K) {
    if (this.cache.hasKey(key)) {
      this.cache.remove(key)
      this._count--
    }
  }

  clear(){
    if (this.count <= 0) return
    this.cache.clear()
    this._count = 0
  }


  //TODO
  /**
   * trimToCount
   * trimToCost
   * TrimToAge
   */

}