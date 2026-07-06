import { st_face_shape_t } from "@softsugar/mars_effects"

export default class DBUserInfo{

  faceShape:st_face_shape_t = st_face_shape_t.ST_FACE_SHAPE_UNKNOWN//脸型
  gender: number = -1  //性别  0 女  1 男
  age:number =-1     //年龄
  attractive:number = -1  //颜值
}