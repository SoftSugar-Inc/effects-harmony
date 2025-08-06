import { hilog } from '@kit.PerformanceAnalysisKit'
import { BeautyType } from 'libentry.so'

export default class BeautyCleanObject {
  name: string
  type: BeautyType

  defaultStrength: number | undefined
  maxStrength: number = 100
  minStrength: number = -100

  mode: number = 0
  path: string = ""

  defaultIcon: string
  highlightIcon: string
  need_open_whiten_skin_mask: boolean = false
  start_center:boolean =false
  other_mutual_beauty_type:BeautyType[]|undefined

  constructor(name: string, defaultIcon: string, highlightIcon: string, type: BeautyType = BeautyType.EFFECT_BEAUTY_UNKNOWN,need_open_whiten_skin_mask:boolean) {
    this.name = name
    this.defaultIcon = defaultIcon
    this.highlightIcon = highlightIcon
    this.type = type
    this.need_open_whiten_skin_mask = need_open_whiten_skin_mask
  }
}