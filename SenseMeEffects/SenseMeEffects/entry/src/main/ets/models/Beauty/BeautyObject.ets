import { BeautyType } from '@softsugar/mars_effects'
import { st_face_shape_t } from '@softsugar/mars_effects'
import BeautyCleanObject, { BeautyCleanParam } from './BeautyCleanObject'

@Observed
export default class BeautyObject {
  cleanObject: BeautyCleanObject
  currentStrength: number = 0
  subBeauties: BeautyObject[] | undefined
  subParams : BeautyParam[] | undefined

  constructor(jsonObj:BeautyCleanObject) {
    this.cleanObject = jsonObj
  }


  getDefaultStrength(faceShape:st_face_shape_t|undefined):number{
    if (!this.cleanObject.defaultStrengths || this.cleanObject.defaultStrengths.length <= 0||!faceShape) return this.cleanObject.def_strength??0
    let index = (faceShape as number) - 1
    if (index < this.cleanObject.defaultStrengths.length) {
      return this.cleanObject.defaultStrengths[index]
    }else {
      return this.cleanObject.defaultStrengths[0]
    }
  }

}

@Observed
export class BeautyParam{
  currentStrength: number = 0
  cleanObject:BeautyCleanParam
  constructor(jsonObj:BeautyCleanParam) {
    this.cleanObject = jsonObj
  }
}