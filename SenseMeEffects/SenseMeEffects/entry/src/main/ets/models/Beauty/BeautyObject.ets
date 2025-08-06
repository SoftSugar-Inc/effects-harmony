import { BeautyType } from 'libentry.so'
import BeautyCleanObject from './BeautyCleanObject'

@Observed
export default class BeautyObject {
  cleanObject: BeautyCleanObject
  currentStrength: number | undefined
  subBeauties: BeautyObject[] | undefined


  constructor(name: string, defaultIcon: string, highlightIcon: string, type: BeautyType = BeautyType.EFFECT_BEAUTY_UNKNOWN,need_open_whiten_skin_mask:boolean) {
    this.cleanObject = new BeautyCleanObject(name, defaultIcon, highlightIcon, type, need_open_whiten_skin_mask)
    this.currentStrength = this.cleanObject.defaultStrength
  }

  static fromJson(json: BeautyObject): BeautyObject {
    let result = new BeautyObject(json.cleanObject.name, json.cleanObject.defaultIcon, json.cleanObject.highlightIcon,
      json.cleanObject.type, json.cleanObject.need_open_whiten_skin_mask)
    result.cleanObject.defaultStrength = json.cleanObject.defaultStrength
    result.cleanObject.maxStrength = json.cleanObject.maxStrength
    result.cleanObject.minStrength = json.cleanObject.minStrength
    result.cleanObject.mode = json.cleanObject.mode
    result.cleanObject.path = json.cleanObject.path

    result.currentStrength = json.cleanObject.defaultStrength
    if (json.subBeauties) {
      let subBeauties: BeautyObject[] = []
      for (let index = 0; index < json.subBeauties.length; index++) {
        const element = json.subBeauties[index];
        let item = BeautyObject.fromJson(element)
        subBeauties.push(item)
      }
      result.subBeauties = subBeauties
    }
    return result
  }
}