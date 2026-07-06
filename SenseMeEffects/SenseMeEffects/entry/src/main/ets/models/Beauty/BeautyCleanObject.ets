import { hilog } from '@kit.PerformanceAnalysisKit'
import { BeautyType ,st_face_shape_t} from '@softsugar/mars_effects'
import { faceDetector } from '@kit.CoreVisionKit'

export default class BeautyCleanObject {
  uid:string |undefined
  des: string |undefined
  display_des_res_id:string |undefined
  beauty_type: BeautyType |undefined
  select_icon_nor_res: string |undefined
  select_icon_press_res: string|undefined
  def_strength: number |undefined
  skip_set_when_reset:boolean |undefined
  mutex_other_uid_arr:string[] |undefined

  beauty_mode_param: number |undefined
  beauty_mode_value: number |undefined

  beauty_asset_path: string|undefined
  need_open_whiten_skin_mask: boolean |undefined
  same_beauty_type_multi_mode :boolean |undefined

  is_3d_plastic: boolean|undefined
  //特殊
  defaultStrengths: number[]|undefined

  range_negative_to_positive:boolean |undefined
  only_show_in_image_mode:boolean|undefined
  click_event_type:string|undefined

  sub_beauties:BeautyCleanObject[]|undefined
  sub_params :BeautyCleanParam[]| undefined

  is_unsupport_multiBody: boolean |undefined

}

export class BeautyCleanParam {
  uid:string|undefined
  enum_des: string|undefined
  st_beauty_type: BeautyType |undefined
  def_strength : number|undefined
  display_des_res_id:string|undefined
  enum_name:string |undefined
}