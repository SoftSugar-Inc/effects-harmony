export enum HomeType{
  Beauty,
  Filter,
  Makeup,
  Sticker,
  Style,
  Avatar,
  Body,
  /*TryOn,*/
  /*ItsMe,*/
  All
}
export interface HomeParam{
  type : HomeType
  index : number
}

export interface HomeGrid{
  name : string
  type : HomeType
  routerIndex :number
  icon : string
  color :  string
  items: HomeItem[]
}
export interface HomeItem{
  icon : string
  name : string
  index :  number
}
export class STDefines{
  public static homeGrids :HomeGrid[] =[]

  // 换背景 固定素材ID
  public static CHOOSE_BG_STICKER_ID = 1030;
  public static CHOOSE_GREEN_ID = 2935;       // 绿幕
  public static CHOOSE_REED_ID = 2936;        // 红幕
  public static CHOOSE_BLUE_ID = 2937;        // 蓝幕
  public static CHOOSE_GREEN_VIDEO_ID = 3121; // 绿幕视频

  public static IsCanChangeBg(id : number|undefined):boolean{
    return id == STDefines.CHOOSE_BG_STICKER_ID||
           id == STDefines.CHOOSE_GREEN_ID||
      id == STDefines.CHOOSE_REED_ID||
      id == STDefines.CHOOSE_BLUE_ID||
      id == STDefines.CHOOSE_GREEN_VIDEO_ID
  }

  public static MODEL_106 = "M_SenseME_Face_Video_Template_p_4.0.0.model";                // 106
  public static MODEL_NAME_FACE_ATTRIBUTE = "M_SenseME_Attribute_p_1.2.8.1.model";// 性别识别

  public static MODEL_VERIFY = "M_SenseME_Verify_p_3.118.0.1.model";// 人脸比对
}
