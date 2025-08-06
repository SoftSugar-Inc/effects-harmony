export interface HumanAction {
  face_count: number;
}

export enum DetectType{
  //HumanAction
  ST_MOBILE_EYE_BLINK                 = 0x00000002, ///< \~chinese 眨眼 \~english Blink eye
  ST_MOBILE_MOUTH_AH                  = 0x00000004,  ///< \~chinese 嘴巴大张 \~english Open wide
  ST_MOBILE_HEAD_YAW                  = 0x00000008,  ///< \~chinese 摇头 \~english Shake head
  ST_MOBILE_HEAD_PITCH                = 0x00000010,  ///< \~chinese 点头 \~english Nod head
  ST_MOBILE_BROW_JUMP                 = 0x00000020,  ///< \~chinese 眉毛挑动, 该检测耗时较长，请在需要时开启 \~english Raise eyebrow. This detection is time-consuming, please enable it only when necessary）
  ST_MOBILE_FACE_LIPS_UPWARD          = 0x00000040,  ///< \~chinese 嘴角上扬 \~english Upward lips
  ST_MOBILE_FACE_LIPS_POUTED          = 0x00000080,  ///< \~chinese 嘟嘴 \~english Pouted lips
  ST_MOBILE_HAND_DETECT               = 0x00000100,  ///< \~chinese 检测手 \~english Detect hands

  ST_HAND_ACTION_TYPE_OK				       = 0x00000200,              ///< \~chinese OK手势 \~english OK hand gesture
  ST_HAND_ACTION_TYPE_SCISSOR			     = 0x00000400,              ///< \~chinese 剪刀手 \~english Scissor hand gesture
  ST_HAND_ACTION_TYPE_GOOD			       = 0x00000800,              ///< \~chinese 大拇哥 \~english Thumbs up hand gesture
  ST_HAND_ACTION_TYPE_PALM			       = 0x00001000,              ///< \~chinese 手掌 \~english Palm gesture
  ST_HAND_ACTION_TYPE_PISTOL			     = 0x00002000,              ///< \~chinese 手枪手势 \~english Pistol hand gesture
  ST_HAND_ACTION_TYPE_LOVE			       = 0x00004000,              ///< \~chinese 爱心手势 \~english Heart hand gesture
  ST_HAND_ACTION_TYPE_HOLDUP		       = 0x00008000,              ///< \~chinese 托手手势 \~english Hold up hand gesture
  ST_HAND_ACTION_TYPE_FIST			       = 0x00200000,              ///< \~chinese 拳头手势 \~english Fist hand Agesture
  ST_HAND_ACTION_TYPE_CONGRATULATE     = 0x00020000 ,             ///< \~chinese 恭贺A（抱拳）\~english Fist-palm A salute
  ST_HAND_ACTION_TYPE_FINGER_HEART	   = 0x00040000,              ///< \~chinese 单手比爱心 \~english Finger heart gesture
  ST_HAND_ACTION_TYPE_FINGER_INDEX	   = 0x00100000,              ///< \~chinese 食指指尖 \~english Finger point gesture
  ST_HAND_ACTION_TYPE_666				       = 0x00400000,              ///< \~chinese 666 \~english 666 hand gesture
  ST_HAND_ACTION_TYPE_BLESS			       = 0x00800000,              ///< \~chinese 双手合十 \~english Bless hand gesture
  ST_HAND_ACTION_TYPE_ILOVEYOU		     = 0x010000000000,          ///< \~chinese 手势ILoveYou \~english I love you hand gesture
  ST_HAND_ACTION_TYPE_THREE			       = 0x10000000000000,        ///< \~chinese 三根手指 \~english Three fingers
  ST_HAND_ACTION_TYPE_FOUR			       = 0x20000000000000,        ///< \~chinese 四根手指 \~english Four fingers
  ST_HAND_ACTION_TYPE_THUMBS_DOWN	     = 0x01,                    ///< \~chinese 差评 \~english Thumbs down gesture
  ST_HAND_ACTION_TYPE_LOVEB			       = 0x02,                    ///< \~chinese 比心B \~english Heart hand B gesture
  ST_HAND_ACTION_TYPE_LOVEC			       = 0x04,                    ///< \~chinese 比心C \~english Heart hand C gesture
  ST_HAND_ACTION_TYPE_SEVEN			       = 0x08,                    ///< \~chinese 七（卷心菜） \~english Seven gesture
  ST_HAND_ACTION_TYPE_FACE_PALMING	   = 0x10,                    ///< \~chinese 捧脸 \~english Face plaming gesture
  ST_HAND_ACTION_TYPE_PRAY			       = 0x20,                    ///< \~chinese 祈祷 \~english Pray gesture
  ST_HAND_ACTION_TYPE_NINE			       = 0x40,                    ///< \~chinese 九 \~english Nine gesture
  ST_HAND_ACTION_TYPE_CONGRATULATE_B   = 0x80,                    ///< \~chinese 恭贺B（抱拳）\~english Fist-palm B salute
  ST_HAND_ACTION_TYPE_SSH			         = 0x400000000000,          ///< \~chinese 手势嘘,依赖于手势检测和106点检测 \~english Shush hand. This detection relies on gesture detection and face 106-point detection
  ST_HAND_ACTION_TYPE_OTHER			       = 0                       ///< \~chinese 其他手势 \~english Other gesture
}

