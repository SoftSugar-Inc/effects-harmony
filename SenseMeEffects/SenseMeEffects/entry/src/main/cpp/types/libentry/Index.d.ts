export const InitializeByBuffer:(buffer: ArrayBuffer) => boolean;
export const InitializeByMode:(mode: EffectsMode) => boolean;
export const checkLicenseByPath:(path: string) => boolean;
export const checkLicenseByBuffer:(buffer: ArrayBuffer) => boolean;
export const addSubModelByPath:(path: string) => boolean;
export const addSubModelByBuffer:(buffer: ArrayBuffer) => boolean;
export const addAnimalSubModelByPath:(path: string) => boolean;
export const addAnimalSubModelByBuffer:(buffer: ArrayBuffer) => boolean;

export const resetHumanAction:() => boolean;
export const setParamByEffectParam:(param:EffectParam, value: number) => boolean;
export const setParamByHumanActionParam:(param:HumanActionParam, value: number) => boolean;
export const addPackageByPath:(path: string) => number;
export const addPackageByBuffer:(buffer: ArrayBuffer) => number;
export const changePackageByPath:(path: string) => number;
export const changePackageByBuffer:(buffer: ArrayBuffer) => number;
export const removePackage:(id: number) => boolean;
export const clearPackages:() => boolean;
export const setPackageBeautyStrength:(id:number, type:EffectBeautyGroup, value: number) => boolean;
export const replayPackage:(id:number) => boolean;

export const getDetectConfig:() => number;
export const getCustomEventConfig:() => number;
export const getTriggerActions:() => number;
export const setBeautyPackageByPath:(type:BeautyType, path: string) => boolean;
export const setBeautyPackageByBuffer:(type:BeautyType, buffer: ArrayBuffer) => boolean;
export const setBeautyMode:(type:BeautyType,mode: number) => boolean;
export const setBeautyStrength:(type:BeautyType,value: number) => boolean;
export const setBeautyParam:(type:BeautyParamType,value: number) => boolean;
export const getOverlappedBeautyInfo:() => EffectBeautyInfo[];
export const process:(srcBuffer: ArrayBuffer, format:PixelFormat,width:number,height:number,stride:number,rotate:RotateType,mirror:boolean,
  time_stamp:number, outBuffer:ArrayBuffer, outFormat:PixelFormat, orientation:RotateType, isOrigin:boolean,immediately:boolean) => boolean;
export const processASync:(srcBuffer: ArrayBuffer, format:PixelFormat,width:number,height:number,stride:number,rotate:RotateType,mirror:boolean,
  time_stamp:number, outBuffer:ArrayBuffer, outFormat:PixelFormat, orientation:RotateType, isOrigin:boolean,immediately:boolean) => Promise<boolean>;
export const makeCurrent:() => boolean;
export const makeEmpty:() => boolean;

export const updateWindowSize:(width:number,height:number) => void;
export const setResizingMode:(mode:RenderingResizingMode) => void;
export const resetPixelReader:() => boolean;


export  const enum BeautyParamType{
  EFFECT_BEAUTY_PARAM_ENABLE_WHITEN_SKIN_MASK
}
export const enum RenderingResizingMode
{
  Stretch,
  AspectFit,
  AspectFill
}
export interface EffectBeautyInfo{
  type : BeautyType       ///< \~chinese 美颜类型 \~english Beauty type
  strength : number       ///< \~chinese 美颜强度 \~english Beauty strength
  name : string           ///< \~chinese 所属的素材包的名字 \~english Name of the material package it belongs to
  mode :number            ///< \~chinese 美颜的模式 \~english Beauty mode
}

export const enum EffectBeautyGroup{
  EFFECT_BEAUTY_GROUP_BASE,           ///< \~chinese 基础美颜组 \~english Basic beauty group
  EFFECT_BEAUTY_GROUP_RESHAPE,        ///< \~chinese 美型组 \~english Reshape group
  EFFECT_BEAUTY_GROUP_PLASTIC,        ///< \~chinese 微整形组 \~english Micro Plastic group
  EFFECT_BEAUTY_GROUP_TONE,           ///< \~chinese 图像微调组 \~english Tone adjustment group
  EFFECT_BEAUTY_GROUP_BOKEH,          ///< \~chinese 背景模糊微调组 \~english bokeh group
  EFFECT_BEAUTY_GROUP_MAKEUP,         ///< \~chinese 美妆组 \~english Makeup group
  EFFECT_BEAUTY_GROUP_FILTER,         ///< \~chinese 滤镜组 \~english Filter group
}
export const enum HumanActionParam{
  // \~chinese 人脸参数 \~english Face parameters
  /// \~chinese 设置检测到的最大人脸数目N(默认值32, 最大值32),持续track已检测到的N个人脸直到人脸数小于N再继续做detect.值越大,检测到的人脸数目越多,但相应耗时越长. 如果当前人脸数目达到上限，检测线程将休息 \~english Set the maximum number of detected faces N (default value: 32, maximum value: 32). Continue tracking the detected N faces until the number of faces becomes less than N before continuing detection. The larger the value, the more faces will be detected, but the longer the processing time. If the current number of faces reaches the limit, the detection thread will rest
  ST_HUMAN_ACTION_PARAM_FACELIMIT = 0,
  /// \~chinese 设置tracker每多少帧进行一次detect(默认值有人脸时24,无人脸时24/3=8). 值越大,cpu占用率越低, 但检测出新人脸的时间越长. \~english Set the number of frames between face detections (default value: 24 when a face is present, 8 when no face is present). The larger the value, the lower the CPU usage, but it takes longer to detect new faces
  ST_HUMAN_ACTION_PARAM_FACE_DETECT_INTERVAL = 1,
  /// \~chinese 设置106点、240点是否平滑(默认值0 不平滑),不平滑点会有些抖动，平滑点会有点滞后. \~english Set whether to smooth the 106-point or 240-point facial landmarks (default value: 0 for no smoothing). Non-smoothed landmarks may have some jitter, while smoothed landmarks may be slightly delayed
  ST_HUMAN_ACTION_PARAM_FACE_SMOOTH = 2,
  /// \~chinese 设置head_pose去抖动的阈值[0.0,1.0](默认值0.5),值越大, pose信息的值越稳定,但相应值会有滞后. \~english Set the threshold for head pose smoothing [0.0,1.0] (default value: 0.5). A higher value makes the pose information more stable, but introduces some delay
  ST_HUMAN_ACTION_PARAM_HEADPOSE_THRESHOLD = 3,
  /// \~chinese 设置脸部隔帧检测（对上一帧结果做拷贝），目的是减少耗时。默认每帧检测一次. 最多每10帧检测一次. 开启隔帧检测后, 只能对拷贝出来的检测结果做后处理. \~english Set the interval for face processing (copying the results from the previous frame) to reduce processing time. The default is to process every frame. The maximum interval is every 10 frames. When enabled, only the copied detection results can be post-processed
  ST_HUMAN_ACTION_PARAM_FACE_PROCESS_INTERVAL = 5,
  /// \~chinese 设置人脸106点检测的阈值[0.0,1.0] \~english Set the threshold for face detection [0.0,1.0]
  ST_HUMAN_ACTION_PARAM_FACE_THRESHOLD = 6,
  /// \~chinese /// 设置mesh渲染模式, mesh分为人脸，眼睛，嘴巴，后脑勺，耳朵，脖子，眉毛七个部位，2106模型只包含人脸，眼睛，嘴巴三个部位，3060/2396模型只包含人脸，眼睛，嘴巴，后脑勺，耳朵，脖子六个部位
  /// 参数值类型为st_mobile_mesh_part，默认只渲染人脸st_mobile_mesh_part::ST_MOBILE_MESH_PART_FACE，
  /// 可以设置多个部位，例如：渲染人脸和嘴巴，st_mobile_mesh_part::ST_MOBILE_MESH_PART_FACE + st_mobile_mesh_part::ST_MOBILE_MESH_PART_MOUTH \~english Set the mesh rendering mode. The mesh consists of seven parts: face, eyes, mouth, back of the head, ears, neck, and eyebrows. The 2106 model only includes the face, eyes, and mouth parts, while the 3060/2396 model includes the face, eyes, mouth, back of the head, ears, and neck parts. The parameter value type is st_mobile_mesh_part. By default, only the face part (st_mobile_mesh_part::ST_MOBILE_MESH_PART_FACE) is rendered. Multiple parts can be set, for example: render the face and mouth (st_mobile_mesh_part::ST_MOBILE_MESH_PART_FACE + st_mobile_mesh_part::ST_MOBILE_MESH_PART_MOUTH)
  ST_HUMAN_ACTION_PARAM_MESH_MODE = 20,
  /// \~chinese 设置mesh额头点扩展scale范围起始值（小于终止值，默认是2） \~english Set the starting scale value for expanding the forehead mesh points (default value: 2)
  ST_HUMAN_ACTION_PARAM_MESH_START_SCALE = 21,
  /// \~chinese 设置mesh额头点扩展scale范围终止值（大于起始值，默认是3） \~english Set the ending scale value for expanding the forehead mesh points (default value: 3)
  ST_HUMAN_ACTION_PARAM_MESH_END_SCALE = 22,
  /// \~chinese 设置mesh结果输出坐标系,(0: 屏幕坐标系， 1：世界坐标系） \~english Set the coordinate system for mesh output (0: screen coordinates, 1: world coordinates)
  // ST_HUMAN_ACTION_PARAM_MESH_OUTPUT_FORMAT = 23,

  /// \~chinese 获取mesh模型支持的关键点的数量（2106/3060/2396） \~english Get the number of keypoints supported by the mesh model (2106/3060/2396)
  ST_HUMAN_ACTION_PARAM_MESH_MODEL_VERTEX_NUM = 24,
  /// \~chinese 设置face mesh是否需要内缩282关键点坐标(只对face mesh有效，360度mesh不需要，0：不需要内缩，1：需要内缩) \~english Set whether to narrow the landmark coordinates of the face mesh (valid only for the face mesh). 0: no narrowing, 1: narrowing
  ST_HUMAN_ACTION_PARAM_FACE_MESH_NARROW_LANDMARK = 25,
  // /// \~chinese 设置face mesh是否需要计算边界点(0：不需要计算边界点，1：需要计算边界点） \~english Set whether to calculate boundary points for face mesh (0: do not calculate boundary points, 1: calculate boundary points)
  //ST_HUMAN_ACTION_PARAM_FACE_MESH_CONTOUR = 26,
  // /// \~chinese 设置mesh是否打开透视 1：打开透视， 0：打开正交 (默认打开正交) \~english Set whether the mesh is in perspective view or orthogonal view (1: perspective view, 0: orthogonal view. Default is orthogonal view)
  // ST_HUMAN_ACTION_PARAM_FACE_MESH_PERSPECTIVE = 26,
  /// \~chinese 设置face mesh结果输出坐标系,值使用st_3d_coordinate_type \~english Set the coordinate system for face mesh output, value uses st_3d_coordinate_type
  ST_HUMAN_ACTION_PARAM_FACE_MESH_OUTPUT_FORMAT = 26,
  /// \~chinese 设置head mesh结果输出坐标系, st_3d_coordinate_type，只支持0和1 \~english Set the coordinate system for head mesh output, value uses st_3d_coordinate_type
  ST_HUMAN_ACTION_PARAM_HEAD_MESH_OUTPUT_FORMAT = 27,

  /// \~chinese 设置body mesh结果输出坐标系,值使用st_3d_coordinate_type,只支持0和1 \~english Set the coordinate system for body mesh output, value uses st_3d_coordinate_type
  ST_HUMAN_ACTION_PARAM_BODY_MESH_OUTPUT_FORMAT = 52,

  // \~chinese 手部参数 \~english Hand parameters
  /// \~chinese 设置检测到的最大手数目N(只检测手势时默认值32,检测手骨骼点时默认值1,最大值32),持续track已检测到的N个hand直到手的数目小于N再继续做detect.值越大,检测到的hand数目越多,但相应耗时越长. 如果当前手数目达到上限，检测线程将休息 \~english Set the maximum number of hands detected N (default value 32 if only hand_detect, default value1 if detect hand_skeleton, maximum value 32). Continuously track the detected N hands until the number of hands is less than N, then continue to detect. The larger the value, the more hands detected, but the longer the corresponding time. If the current number of hands reaches the upper limit, the detection thread will rest
  ST_HUMAN_ACTION_PARAM_HAND_LIMIT = 101,
  /// \~chinese 设置手势检测每多少帧进行一次 detect (默认有手时30帧detect一次, 无手时10(30/3)帧detect一次). 值越大,cpu占用率越低, 但检测出新手的时间越长. \~english Set the interval for hand gesture detection (default is 30 frames for detecting hands and 10 (30/3) frames for detecting no hands). The larger the value, the lower the CPU usage, but the longer it takes to detect new hands
  ST_HUMAN_ACTION_PARAM_HAND_DETECT_INTERVAL = 102,
  /// \~chinese 设置手势隔帧检测（对上一帧结果做拷贝），目的是减少耗时。默认每帧检测一次. 最多每10帧检测一次. 开启隔帧检测后, 只能对拷贝出来的检测结果做后处理. \~english Set the interval for hand gesture detection using the previous frame's result as a copy, to reduce processing time. By default, detect every frame. Can detect every 10 frames at most. After enabling interval detection, only post-processing can be done on the copied detection result
  ST_HUMAN_ACTION_PARAM_HAND_PROCESS_INTERVAL = 103,
  /// \~chinese 设置手检测的阈值[0.0,1.0] \~english Set the threshold for hand detection [0.0,1.0]
  ST_HUMAN_ACTION_PARAM_HAND_THRESHOLD = 104,

  /// \~chinese 设置手骨架检测的阈值[0.0,1.0] \~english Set the threshold for hand skeleton detection [0.0,1.0]
  ST_HUMAN_ACTION_PARAM_HAND_SKELETON_THRESHOLD = 110,

  //  \~chinese 肢体参数 \~english Body parameters
  /// \~chinese 设置检测到的最大肢体数目N(默认值1),持续track已检测到的N个肢体直到肢体数小于N再继续做detect.值越大,检测到的body数目越多,但相应耗时越长. 如果当前肢体数目达到上限，检测线程将休息 \~english Set the maximum number of bodies detected N (default value 1). Continuously track the detected N bodies until the number of bodies is less than N, then continue to detect. The larger the value, the more bodies detected, but the longer the corresponding time. If the current number of bodies reaches the upper limit, the detection thread will rest
  ST_HUMAN_ACTION_PARAM_BODY_LIMIT = 200,
  /// \~chinese 设置肢体关键点检测每多少帧进行一次 detect (默认有肢体时30帧detect一次, 无body时10(30/3)帧detect一次). 值越大,cpu占用率越低, 但检测出新body的时间越长. \~english Set the interval for body keypoint detection (default is 30 frames for detecting bodies and 10 (30/3) frames for detecting no bodies). The larger the value, the lower the CPU usage, but the longer it takes to detect new bodies
  ST_HUMAN_ACTION_PARAM_BODY_DETECT_INTERVAL = 201,
  /// \~chinese 设置肢体隔帧检测（对上一帧结果做拷贝），目的是减少耗时。默认每帧检测一次. 最多每10帧检测一次. 开启隔帧检测后, 只能对拷贝出来的检测结果做后处理. \~english Set the parameters for frame skipping in body detection, which copies the results from the previous frame to reduce processing time
  ST_HUMAN_ACTION_PARAM_BODY_PROCESS_INTERVAL = 202,
  /// \~chinese 设置身体检测的阈值[0.0，1.0] \~english Set the threshold for body detection [0.0,1.0]
  ST_HUMAN_ACTION_PARAM_BODY_THRESHOLD = 203,
  /// \~chinese 已废弃 设置是否根据肢体信息检测摄像头运动状态 (0: 不检测; 1: 检测. 默认检测肢体轮廓点时检测摄像头运动状态) \~english (deprecated)
  //ST_HUMAN_ACTION_PARAM_DETECT_CAMERA_MOTION_WITH_BODY = 203,
  /// \~chinese 输入真实身高，单位为米，3D骨架乘以身高（整体缩放），得到真实的物理尺度，仅用于儿童肢体检测 \~english Set the input real height for child body detection
  ST_HUMAN_ACTION_PARAM_BODY_STATURE = 210,

  // \~chinese 人头分割参数 \~english Head segment parameters
  /// \~chinese 设置头部分割检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转) \~english Set whether to rotate the head segment detection result image
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_RESULT_ROTATE = 300,
  /// \~chinese 设置人头分割边界区域上限阈值.开启温度系数时设置无效 \~english Set the upper threshold for head segment detection result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_MAX_THRESHOLD = 301,
  /// \~chinese 设置人头分割边界区域下限阈值 开启温度系数时设置无效 \~english Set the lower threshold for head segment detection result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_MIN_THRESHOLD = 302,
  /// \~chinese 头部分割后处理长边的长度[10,长边长度](默认长边240,短边=长边/原始图像长边*原始图像短边).值越大,头部分割后处理耗时越长,边缘部分效果越好. \~english Set the length of the longer side for post-processing the head segment result. The value should be in the range [10, length of the longer side]
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_MAX_SIZE = 303,
  /// \~chinese 设置最大人头分割个数，默认支持一个人头分割，face_id为人脸id; 若支持多个人头分割，则face id为-1. \~english Sets the maximum number of head segmentations. By default, only one head segmentation is supported, and the face ID is used as the ID for the head segmentation. If multiple head segmentations are supported, the face ID should be set to -1
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_MAX_COUNT = 304,
  /// \~chinese 设置头部分割检测结果边缘模糊程度 取值范围0-1 视频版默认0.5, 图片版默认是1 \~english Set the degree of edge blur for the head segment result. The value should be in the range [0, 1]. The default value is 0.5 for video and 1 for images
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_RESULT_BLUR = 305,
  /// \~chinese 设置头部分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for the head segment result. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, the edge boundaries should be processed by thresholds
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_USE_TEMPERATURE = 306,
  /// \~chinese 边缘移动参数，取值范围再[-2,2],默认值是1 \~english Set the edge shift parameter for the head segment. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_EDGESHIFT = 307,
  /// \~chinese 设置人头实例分割，人头实例分割依赖人脸检测，且只有加载人头实例分割模型设置该参数有效．默认不开启，出单个mask; 开启则多人多mask，数量跟人脸个数对应． \~english Sets the head instance segmentation. Head instance segmentation relies on face detection and is only effective when the head instance segmentation model is loaded. By default, this parameter is disabled, resulting in a single mask. When enabled, multiple masks are generated, and the number of masks corresponds to the number of detected faces
  ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_INSTANCE = 308,

  // \~chinese 背景分割/人像分割参数 \~english Background/figure segmentation parameters
  /// \~chinese 输出的background结果中长边的长度[10,长边长度](默认长边为模型内部处理的长边，若设置会做resize处理输出).值越大,背景分割的耗时越长,边缘部分效果越好.值为0还原为默认值. \~english Set the length of the longer side for the background segmentation result. The value should be in the range [10, length of the longer side]. By default, the longer side is determined by the internal processing of the model. If set, the output will be resized accordingly. A larger value will result in longer processing time and better edge effect on the segmented background. Setting the value to 0 will restore the default value
  ST_HUMAN_ACTION_PARAM_BACKGROUND_MAX_SIZE = 400,
  /// \~chinese 背景分割羽化程度[0,1](默认值0.35),0 完全不羽化,1羽化程度最高,在strenth较小时,羽化程度基本不变.值越大,前景与背景之间的过度边缘部分越宽. \~english Set the degree of feathering for the background segmentation result. The value should be in the range [0, 1], where 0 means no feathering and 1 means the highest degree of feathering. When the strength is low, the degree of feathering remains almost unchanged. A higher value widens the transition edge between the foreground and background
  /// \~chinese 备注：只对1.5.0 人像分割模型有效 \~english Note: This parameter is only effective for the figure segmentation model v1.5.0
  ST_HUMAN_ACTION_PARAM_BACKGROUND_BLUR_STRENGTH = 401,
  /// \~chinese 设置前后背景检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转) \~english Set whether to rotate the grayscale background result image. The options are 0 (do not rotate, keep vertical) and 1 (rotate, align with the input image). By default, rotation is disabled
  ST_HUMAN_ACTION_PARAM_BACKGROUND_RESULT_ROTATE = 402,
  /// \~chinese 设置背景分割边界区域上限阈值. 开启温度系数时设置无效 \~english Set the upper threshold for the boundary region of the background segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_SEGMENT_MAX_THRESHOLD = 403,
  /// \~chinese 设置背景分割边界区域下限阈值 开启温度系数时设置无效 \~english Set the lower threshold for the boundary region of the background segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_SEGMENT_MIN_THRESHOLD = 404,
  //	ST_HUMAN_ACTION_PARAM_SEGMENT_KERNAL_TYPE = 406, \~chinese 已废弃 \~english (deprecated)
  /// \~chinese 设置背景分割检测结果边缘模糊程度 取值范围0-1, 视频版默认是0.5 图片版默认是1 \~english Set the degree of edge blur for the background segmentation result. The value should be in the range [0, 1]. The default value is 0.5 for video and 1 for images
  ST_HUMAN_ACTION_PARAM_BACKGROUND_SEGMENT_RESULT_BLUR = 407,
  /// \~chinese 设置背景分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for the background segmentation result. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, min max threshold should be used for mask postprocess. By default, this parameter is enabled
  ST_HUMAN_ACTION_PARAM_BACKGROUND_SEGMENT_USE_TEMPERATURE = 408,

  ST_HUMAN_ACTION_PARAM_BACKGROUND_SEGMENT_INSTANCE = 409,
  /// \~chinese 边缘移动参数，取值范围再[-2,2],默认值是1 \~english Set the edge shift parameter for the background segmentation. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_BACKGROUND_SEGMENT_EDGESHIFT=399,

  // \~chinese 头发分割参数 \~english Hair segmentation parameters
  /// \~chinese 头发结果中长边的长度[10,长边长度](默认长边240,短边=长边/原始图像长边*原始图像短边).值越大,头发分割的耗时越长,边缘部分效果越好. \~english Set the length of the longer side for the hair segmentation result. The value should be in the range [10, length of the longer side]. A larger value will result in longer processing time but better edge effect on the segmented hair
  ST_HUMAN_ACTION_PARAM_HAIR_MAX_SIZE = 410,
  /// \~chinese 头发分割羽化程度[0,1](默认值0.35),0 完全不羽化,1羽化程度最高,在strenth较小时,羽化程度基本不变.值越大,过度边缘部分越宽. \~english Set the hair segmentation feathering degree [0,1] (default value 0.35), 0 is no feathering at all, 1 is the highest feathering degree, when the strenth is small, the feathering degree is basically unchanged. The larger the value, the wider the excessive edge part
  ST_HUMAN_ACTION_PARAM_HAIR_BLUR_STRENGTH = 411,  // \~chinese 无效,可删除 \~english (deprecated)
  /// \~chinese 设置头发灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认0不旋转) \~english Set whether the direction of the hair grayscale image needs to be rotated (0: no rotation, keep it vertical; 1: rotation, the direction is consistent with the input image. By default, rotation is disabled
  ST_HUMAN_ACTION_PARAM_HAIR_RESULT_ROTATE = 412,
  /// \~chinese 设置头发分割边界区域上限阈值.开启温度系数时设置无效 \~english Set the upper limit threshold of the hair segmentation boundary area. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_HAIR_SEGMENT_MAX_THRESHOLD = 414,
  /// \~chinese 设置头发分割边界区域下限阈值 开启温度系数时设置无效 \~english Set the lower limit threshold of the hair segmentation boundary area. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_HAIR_SEGMENT_MIN_THRESHOLD = 415,
  /// \~chinese 设置头发分割检测结果边缘模糊程度 取值范围0-1 视频版默认是0.5，图片版默认是1 \~english Set the edge blurring degree of the hair segmentation detection result. The value range is 0-1. The video mode defaults to 0.5, and the image mode defaults to 1
  ST_HUMAN_ACTION_PARAM_HAIR_SEGMENT_RESULT_BLUR = 416,
  /// \~chinese 设置头发分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for the hair segmentation result. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, min_threshold, max_threshold should be used for mask postprocess. By default, this parameter is enabled
  ST_HUMAN_ACTION_PARAM_HAIR_SEGMENT_USE_TEMPERATURE = 417,
  /// \~chinese 边缘移动参数，取值范围在[-2,2],默认值是1 \~english Set the edge shift parameter for the hair segmentation. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_HAIR_SEGMENT_EDGESHIFT=418,

  // \~chinese 多类分割参数 \~english Multi-class segmentation parameters
  /// \~chinese 输出的multisegment结果中长边的长度. \~english Set the length of the longer side for the multi-class segmentation result
  ST_HUMAN_ACTION_PARAM_MULTI_SEGMENT_MAX_SIZE = 420,
  /// \~chinese 设置多类分割检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转) \~english Sets whether to rotate the grayscale multi-class segmentation result image. The options are 0 (do not rotate, keep vertical) and 1 (rotate, align with the input image). By default, rotation is disabled
  ST_HUMAN_ACTION_PARAM_MULTI_SEGMENT_RESULT_ROTATE = 421,


  // \~chinese 皮肤分割参数 \~english Skin segmentation parameters
  /// \~chinese 输出的皮肤分割结果中长边的长度. \~english Set the length of the longer side for the skin segmentation result
  ST_HUMAN_ACTION_PARAM_SKIN_SEGMENT_MAX_SIZE = 430,
  /// \~chinese 设置皮肤分割边界区域上限阈值.开启温度系数时设置无效 \~english Set the upper threshold for the boundary region of the skin segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_SKIN_SEGMENT_MAX_THRESHOLD = 431,
  /// \~chinese 设置皮肤分割边界区域下限阈值，开启温度系数时设置无效 \~english Set the lower threshold for the boundary region of the skin segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_SKIN_SEGMENT_MIN_THRESHOLD = 432,
  /// \~chinese 设置皮肤分割检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转) \~english Set whether to rotate the grayscale skin segmentation result image. The options are 0 (do not rotate, keep vertical) and 1 (rotate, align with the input image). By default, rotation is disabled
  ST_HUMAN_ACTION_PARAM_SKIN_SEGMENT_RESULT_ROTATE = 433,
  /// \~chinese 设置皮肤分割检测结果边缘模糊程度 取值范围0-1 默认0.5 \~english Set the degree of edge blur for the skin segmentation result. The value should be in the range [0, 1], and the default value is 0.5
  ST_HUMAN_ACTION_PARAM_SKIN_SEGMENT_RESULT_BLUR = 434,
  /// \~chinese 设置皮肤分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for the skin segmentation result. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, min max threshould should be used for mask postprocess. By default, this parameter is enabled
  ST_HUMAN_ACTION_PARAM_SKIN_SEGMENT_USE_TEMPERATURE = 435,
  /// \~chinese 边缘移动参数，取值范围再[-2,2],默认值是1 \~english Set the edge shift parameter for the skin segmentation. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_SKIN_SEGMENT_EDGESHIFT=436,
  /// \~chinese 设置皮肤实例分割，皮肤实例分割依赖人脸检测，且只有加载皮肤实例模型设置该参数有效．默认不开启，只单个mask; 开启出多人多mask，数量跟人脸个数对应． \~english Set whether to enable skin instance segmentation. Skin instance segmentation relies on face detection, and this parameter is only effective when the skin instance model is loaded. By default, it is disabled, and only a single mask is generated. Enabling it will produce multiple masks corresponding to the number of detected faces
  ST_HUMAN_ACTION_PARAM_SKIN_SEGMENT_INSTANCE = 437,

  // \~chinese 嘴唇分割 \~english Lip segmentation parameters
  /// \~chinese 设置嘴唇分割检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转) \~english Set whether to rotate the grayscale lip segmentation result image. The options are 0 (do not rotate, keep vertical) and 1 (rotate, align with the input image). The default is not to rotate
  ST_HUMAN_ACTION_PARAM_MOUTH_PARSE_RESULT_ROTATE = 450,
  /// \~chinese 设置是否使用嘴唇分割模型的点阈值，如果大于阈值，表示当前嘴无遮挡，不需要额外使用模型来分割，性能更优。 取值范围[0,1],默认值0.8 \~english Set whether to use threshold. If the value is greater than the threshold, it indicates that the lips are not occluded and there is no need to use the model for segmentation, which improves performance. The value range is [0, 1], with a default value of 0.8
  ST_HUMAN_ACTION_PARAM_MOUTH_PARSE_DETECT_THRESHOLD = 451,

  // \~chinese 面部遮挡分割参数 \~english Face occlusion segmentation parameters
  /// \~chinese 设置面部遮挡检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转) \~english Set whether to rotate the grayscale face occlusion segmentation result image. The options are 0 (do not rotate, keep vertical) and 1 (rotate, align with the input image). By default, rotation is disabled
  ST_HUMAN_ACTION_PARAM_FACE_OCCLUSION_SEGMENT_RESULT_ROTATE = 460,
  /// \~chinese 设置面部遮挡分割边界区域上限阈值，开启温度系数时设置无效 \~english Set the upper threshold for the boundary region of the face occlusion segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_FACE_OCCLUSION_SEGMENT_MAX_THRESHOLD = 461,
  /// \~chinese 设置面部遮挡分割边界区域下限阈值，开启温度系数时设置无效 \~english Set the lower threshold for the boundary region of the face occlusion segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_FACE_OCCLUSION_SEGMENT_MIN_THRESHOLD = 462,
  /// \~chinese 面部遮挡分割后处理长边的长度[10,长边长度](默认长边240,短边=长边/原始图像长边*原始图像短边).值越大,面部遮挡分割后处理耗时越长,边缘部分效果越好. \~english Set the length of the longer side for post-processing after face occlusion segmentation. The value should be in the range [10, length of the longer side]. A larger value leads to longer processing time and better edge quality in the segmented region. By default, the longer side is set to 240
  ST_HUMAN_ACTION_PARAM_FACE_OCCLUSION_SEGMENT_MAX_SIZE = 463,
  /// \~chinese 边缘移动参数，取值范围再[-2,2],默认值是1 \~english Set the edge shift parameter for the face occlusion segmentation. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_FACE_OCCLUSION_SEGMENT_EDGESHIFT = 468,


  /// \~chinese 设置面部遮挡分割检测结果边缘模糊程度 默认参数0.5 \~english Set the degree of edge blur for the face occlusion segmentation result. The default value is 0.5
  ST_HUMAN_ACTION_PARAM_FACE_OCCLUSION_SEGMENT_RESULT_BLUR = 464,
  /// \~chinese 设置面部遮挡分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for the face occlusion segmentation result. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, min_threshold, max_threshold should be used for mask postprocess. By default, this parameter is enabled
  ST_HUMAN_ACTION_PARAM_FACE_OCCLUSION_SEGMENT_USE_TEMPERATURE = 467,
  /// \~chinese 设置人脸遮挡实例分割，人脸遮挡实例分割依赖人脸检测，默认不开启，出单个mask; 开启则多人多mask，数量跟人脸个数对应 \~english Set whether to enable face occlusion instance segmentation. Face occlusion instance segmentation relies on face detection. By default, it is disabled, and only a single mask is generated. When enabled, multi occlusion masks will be generated according to the number of detected faces
  ST_HUMAN_ACTION_PARAM_FACE_OCCLUSION_SEGMENT_INSTANCE = 469,

  // \~chinese 通用参数 \~english General parameters
  /// \~chinese 设置预处理图像大小 \~english Set the maximum size of the preprocessed image
  ST_HUMAN_ACTION_PARAM_PREPROCESS_MAX_SIZE = 500, //
  /// \~chinese 摄像头x方向上的视场角，单位为度，3d点会需要 \~english Set the field of view angle in the x-direction of the camera in degrees. This parameter is required for 3D point calculations
  ST_HUMAN_ACTION_PARAM_CAM_FOVX = 211,
  /// \~chinese pose3d结果是否需要保持人头朝上(1: detect输出的结果永远保持人头朝上;  0: detect输出的pos方向和输入图片一致) 默认人头朝上 \~english Set whether the pose3D result should keep the head upright. The options are 1 (the pose3D result always keeps the head upright) and 0 (the pose3D result follows the same direction as the input image). By default, the head is kept upright
  ST_HUMAN_ACTION_PARAM_POS3D_UP = 502,
  /// \~chinese 设置检测结果延迟帧数[0,2],检测接口输出结果为(当前-N)帧的结果, 默认0不延迟.  注意：在该参数修改过程中,当前检测结果会清空重新开始检测 \~english Set the number of frames to delay the detection results. The detection interface outputs results from the (current - N) frame. The default value is 0, which means no delay. Note that modifying this parameter will clear the current results and start the detection process again
  ST_HUMAN_ACTION_PARAM_DELAY_FRAME = 503,
  /// \~chinese 使用GPU做后处理 \~english Set whether to use the GPU for post-processing
  ST_HUMAN_ACTION_PARAM_SEGMENT_POST_PROCESS_USE_GPU=504,
  //  \~chinese 天空分割参数 \~english Sky segmentation parameters
  /// \~chinese 设置目标特征图像 目前已废弃 \~english (Deprecated) Set the target feature image for sky segmentation
  ST_HUMAN_ACTION_PARAM_SKY_TARGET_IMAGE= 509,
  /// \~chinese 输出的sky结果中长边的长度 \~english Set the length of the longer side for the output sky segmentation result
  ST_HUMAN_ACTION_PARAM_SKY_MAX_SIZE = 510,
  /// \~chinese 天空分割检测结果灰度图的方向是否需要旋转 \~english Set whether to rotate the grayscale sky segmentation result image. The options are 0 (do not rotate, keep vertical) and 1 (rotate, align with the input image)
  ST_HUMAN_ACTION_PARAM_SKY_RESULT_ROTATE = 511,
  /// \~chinese 设置天空分割边界区域上限阈值，开启温度系数时设置无效 \~english Set the upper threshold for the boundary region of the sky segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_SKY_SEGMENT_MAX_THRESHOLD = 512,
  /// \~chinese 设置天空分割边界区域下限阈值，开启温度系数时设置无效 \~english Set the lower threshold for the boundary region of the sky segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_SKY_SEGMENT_MIN_THRESHOLD = 513,
  /// \~chinese 设置天空分割检测结果边缘模糊程度 取值范围0-1，视频版默认参数0.5，图片版默认参数1 \~english Set the degree of edge blur for the sky segmentation result. The value should be in the range [0, 1]. For the video mode, the default value is 0.5, and for the image mode, the default value is 1
  ST_HUMAN_ACTION_PARAM_SKY_SEGMENT_RESULT_BLUR = 508,
  /// \~chinese 设置天空分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for the sky segmentation result. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, min max threshold should be used for mask postprocess. By default, this parameter is enabled
  ST_HUMAN_ACTION_PARAM_SKY_SEGMENT_USE_TEMPERATURE = 507,
  /// \~chinese 使用CPU进行refine操作,默认是使用（＞0.5），当输入参数小于等于0.5时不使用 \~english Set whether to use CPU for sky segmentation refinement. The default behavior is to use CPU when the input parameter is greater than 0.5 and not use CPU when it is less than or equal to 0.5
  ST_HUMAN_ACTION_PARAM_SKY_SEGMENT_REFINE_CPU_PROCESS = 514,
  /// \~chinese 边缘移动参数，取值范围再[-2,2],默认值是1 \~english Set the edge shift parameter for sky segmentation. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_SKY_SEGMENT_EDGESHIFT = 516,
  //  \~chinese 深度估计参数 \~english Depth estimation parameters
  /// \~chinese 输出的深度估计结果中长边的长度 \~english Set the length of the longer side for the output depth estimation result
  ST_HUMAN_ACTION_PARAM_DEPTH_ESTIMATION_MAX_SIZE = 515,

  // \~chinese 指甲检测 \~english Nail detection parameters
  /// \~chinese 设置检测到的最大目标数目N,有效范围为[1, 32], 返回的值可能比输入的值要小. 默认值为10. \~english Set the maximum number of detected nail targets. The valid range is [1, 32], but the returned value may be smaller than the input value. The default value is 10
  ST_HUMAN_ACTION_PARAM_NAIL_LIMIT = 602,
  /// \~chinese 设置指甲检测每多少帧进行一次 detect (默认指甲时30帧detect一次, 无指甲时10(30/3)帧detect一次). 值越大,cpu占用率越低, 但检测出新对象的时间越长. \~english Set the interval between nail detection in frames. When there are nails, the default interval is 30 frames, and when there are no nails, the default interval is 10 frames (30/3). A larger value reduces CPU usage but increases the time to detect new objects
  ST_HUMAN_ACTION_PARAM_NAIL_DETECT_INTERVAL = 603,
  /// \~chinese 设置指甲检测的阈值[0.0,1.0] \~english Set the threshold for nail detection. The value should be in the range [0.0, 1.0]
  ST_HUMAN_ACTION_PARAM_NAIL_THRESHOLD = 604,
  /// \~chinese 指甲平滑参数，取值范围[0,-) 默认参数是0.1 目前以废弃 \~english (Deprecated) Set the smooth parameter for nail detection. The valid range is [0, -). The default value is 0.1
  ST_HUMAN_ACTION_PARAM_NAIL_SMOOTH = 605,
  /// 指甲贴合参数,开启后pose矩阵会使美甲边缘更贴合指甲边缘
  ST_HUMAN_ACTION_PARAM_NAIL_USE_SCALE = 606,

  //	\~chinese 脚部参数 \~english Foot detection parameters
  /// \~chinese 设置检测到的最大脚的个数 \~english Set the maximum number of detected feet
  ST_HUMAN_ACTION_PARAM_FOOT_MAX_LIMIT = 700,
  /// \~chinese 设置脚部检测每多少帧进行一次 detect (默认有脚时30帧detect一次, 无脚时10(30/3)帧detect一次). 值越大,cpu占用率越低, 但检测出新对象的时间越长. \~english Set the interval between foot detections in frames. When feet are present, the default interval is 30 frames, and when no feet are present, the default interval is 10 frames (30/3). A larger value reduces CPU usage but increases the time to detect new objects
  ST_HUMAN_ACTION_PARAM_FOOT_DETECT_INTERVAL = 701,
  /// \~chinese 设置检测阈值[0.0,1.0] \~english Set the threshold for foot detection. The value should be in the range [0.0, 1.0]
  ST_HUMAN_ACTION_PARAM_FOOT_THRESHOLD = 702,
  /// \~chinese 是否输出足部关键点,0-不输出,否则输出,默认不输出 \~english set output foot keypoints or not, 0 - not, 1 - output, default is 0.
  ST_HUMAN_ACTION_PARAM_FOOT_OUTPUT_KEYPOINTS = 703,
  /// \~chinese 设置裤腿分割检测结果边缘模糊程度，取值范围0-1，默认参数0.5 \~english Set the degree of edge blur for trouser leg segmentation results. The value should be in the range [0, 1] and the default parameter is 0.5
  ST_HUMAN_ACTION_PARAM_TROUSER_LEG_SEGMENT_BLUR = 750,
  /// \~chinese 设置分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for trouser leg segmentation results. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, min max threshold should be used for mask postprocess. By default, this parameter is enabled
  ST_HUMAN_ACTION_PARAM_TROUSER_LEG_SEGMENT_USE_TEMPERATURE = 751,
  /// 设置裤腿实例分割，裤腿实例分割依赖foot检测，且只有加载裤腿实例分割模型设置该参数有效．默认不开启，出单个mask; 开启则多人多mask，数量跟人脸个数对应．
  ST_HUMAN_ACTION_PARAM_TROUSER_LEG_SEGMENT_INSTANCE = 752,
  /// \~chinese 边缘移动参数，取值范围再[-2,2],默认值是1 \~english Set the edge shift parameter for trouser leg segmentation. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_TROUSER_LEG_SEGMENT_EDGESHIFT = 451,

  // \~chinese 衣物分割 \~english Clothing segmentation parameters
  /// \~chinese 设置衣物分割检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转) \~english Set whether to rotate the grayscale clothing segmentation result image. The options are 0 (do not rotate, keep vertical) and 1 (rotate, align with the input image). The default is not to rotate
  ST_HUMAN_ACTION_PARAM_CLOTH_SEGMENT_RESULT_ROTATE = 800,
  /// \~chinese 设置衣物分割长边的长度 \~english Set the length of the longer side for the output clothing segmentation result
  ST_HUMAN_ACTION_PARAM_CLOTH_SEGMENT_MAX_SIZE = 801,
  /// \~chinese 设置衣物分割检测结果边缘模糊程度 取值范围0-1，视频版默认参数0.5，图片版默认参数1 \~english Set the degree of edge blur for the clothing segmentation result. The value should be in the range [0, 1]. For the video mode, the default value is 0.5, and for the image mode, the default value is 1
  ST_HUMAN_ACTION_PARAM_CLOTH_SEGMENT_RESULT_BLUR = 802,
  /// \~chinese 设置衣物分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for the clothing segmentation result. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, min max threshold should be used for mask postprocess. By default, this parameter is enabled
  ST_HUMAN_ACTION_PARAM_CLOTH_SEGMENT_USE_TEMPERATURE = 803,
  /// \~chinese 设置衣物分割边界区域上限阈值，开启温度系数时设置无效 \~english Set the upper threshold for the boundary region of the clothing segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_CLOTH_SEGMENT_MAX_THRESHOLD = 804,
  /// \~chinese 设置衣物分割边界区域下限阈值，开启温度系数时设置无效 \~english Set the lower threshold for the boundary region of the clothing segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_CLOTH_SEGMENT_MIN_THRESHOLD = 805,
  /// \~chinese 边缘移动参数，取值范围再[-2,2],默认值是1 \~english Set the edge shift parameter for clothing segmentation. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_CLOTH_SEGMENT_EDGESHIFT = 806,

  // \~chinese 手腕检测 \~english Wrist detection parameters
  /// \~chinese 设置检测到的最大目标数目N,有效范围为[1, 4], 返回的值可能比输入的值要小. 默认值为10. \~english Set the maximum number of detected wrists. The valid range is [1, 4], and the returned value may be smaller than the input value. The default value is 10
  ST_HUMAN_ACTION_PARAM_WRIST_LIMIT = 900,
  /// \~chinese 设置手腕检测每多少帧进行一次 detect (默认30帧detect一次, 无手腕10(30/3)帧detect一次). 值越大,cpu占用率越低, 但检测出新对象的时间越长. \~english Set the interval between wrist detections in frames. The default interval is 30 frames for wrist detection and 10 frames (30/3) for no wrist detection. A larger value reduces CPU usage but increases the time to detect new objects
  ST_HUMAN_ACTION_PARAM_WRIST_DETECT_INTERVAL = 901,
  /// \~chinese 设置手腕检测的roi参数，默认全0，设置检测roi区域，需enable roi需调用st_mobile_human_action_set_roi，默认全0，不开启 \~english Set the ROI (Region of Interest) for wrist detection. This parameter enables setting a specific region for detection. To enable ROI, you need to call st_mobile_human_action_set_roi and provide the ROI parameters. The default value is all zeros, indicating no ROI
  ST_HUMAN_ACTION_PARAM_WRIST_ROI=906,
  /// \~chinese 开启手腕检测roi设置，默认不打开 \~english Enable wrist detection ROI. By default, this parameter is disabled
  ST_HUMAN_ACTION_PARAM_WRIST_ENABLE_ROI=907,
  // /// \~chinese 打开roi设置之后，resize的ratio比例，(0,1] \~english Set the resize ratio in the range (0, 1] when ROI is enabled
  //ST_HUMAN_ACTION_PARAM_WRIST_ROI_RATIO=909,
  /// \~chinese 手表佩戴位置相比手腕宽度的比例 ,默认值是1.0 \~english Set the ratio between the position of the watch and the wrist width. The default value is 1.0
  ST_HUMAN_ACTION_PARAM_WRIST_WRIST_RATIO=911,
  /// \~chinese 手表渲染窗口的roi位置,单位是像素,调用st_mobile_human_action_set_roi进行设置，默认是原始图像，无需提前设置enable roi \~english Sets the ROI for the wrist rendering window in pixels. This parameter is used to specify a specific region for rendering. By default, the ROI is set to the original image, and there is no need to set the ROI in advance
  ST_HUMAN_ACTION_PARAM_WRIST_RENDER_ROI = 914,
  /// \~chinese 手表渲染窗口的尺度变化,(0，-] \~english Set the scale factor for the wrist rendering window. The value should be in the range (0, -)
  ST_HUMAN_ACTION_PARAM_WRIST_RENDER_ROI_SCALE = 915,
  /// \~chinese 设置绿幕分割颜色RGB值,默认为绿色,将颜色值（16进制数0xFFFFFF,按R、G、B排列）按float类型传入 \~english Set the RGB color value for green screen segmentation. The default color is green (hexadecimal value 0xFFFFFF, arranged as R, G, B). The color value should be passed as a float type
  ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_COLOR = 1000,
  /// \~chinese 设置绿幕分割使用CPU处理，默认为GPU \~english process green segment on CPU, default is on GPU
  ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_POST_PROCESS_USE_CPU = 1001,
  /// \~chinese 相似度，范围220-90， 默认140，调大可以小相似度 \~english Similarity, ranging from 220 to 90. The default value is 140. Increasing it can decrease the similarity threshold
  ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_SIMILAR = 1002,
  /// \~chinese 平滑度,建议范围 0-10, 默认7, 越大越平滑， 对边缘也有影响 \~english Smoothness. Recommended range 0-10, default 7. Higher values result in smoother output but may affect edges. Adjust as needed
  ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_SMOOTH = 1003,
  /// \~chinese 平滑度二,范围0-10， 默认1，越大越平滑， 对边缘也有影响,若边缘出现黑边异色可以将该值升高，若边缘出现内蚀可以该值适当降低 \~english Smoothness 2. Range 0-10, default 1. Increasing the value enhances smoothness, which also affects the edges. If there are black borders or color artifacts around the edges, you can increase this value. If the edges appear eroded, you can decrease this value to reduce the smoothness
  ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_SMOOTH2 = 1004,
  /// \~chinese 边界效果,范围10-60， 默认60，效果为若边缘出现黑边、异色，可以将该值降低，若边缘出现内蚀，可以适当增大 \~english Range 10-60, default 60. This parameter affects the appearance of the edges. If there are black borders or color artifacts along the edges, you can decrease this value. If the edges appear eroded, you can increase it slightly
  ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_EDGE = 1005,
  /// \~chinese 设置绿幕分割分割mask后处理的最大边长,单位分辨率，越小mask后处理性能越高，0表示按照原图大小处理，默认720分辨率 \~english The maximum edge length for post-processing after green screen segmentation, measured in resolution units. A smaller value leads to improved post-processing performance. A value of 0 indicates processing at the original image size. The default resolution is 720.
  ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_MAX_EDGE_LEN = 1006,
  /// \~chinese 调整绿幕分割色系范围, 范围0-10,默认5, 线性变化，数值越大会越扩充范围设定颜色的偏色范围
  ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_HSV_RANGE = 1007,

  //	\~chinese 手指参数 \~english Finger detection parameters
  /// \~chinese 设置检测到的最大手指的个数 \~english Set the maximum number of detected fingers. The valid range is [1, 32], and the returned value may be smaller than the input value.
  ST_HUMAN_ACTION_PARAM_FINGER_MAX_LIMIT = 1100,
  /// \~chinese 设置手指检测每多少帧进行一次 detect (默认30帧detect一次, 无手指10(30/3)帧detect一次). 值越大,cpu占用率越低, 但检测出新对象的时间越长. \~english Set the interval between finger detections in frames. The default interval is 30 frames for finger detection and 10 frames (30/3) for no finger detection. A larger value reduces CPU usage but increases the time to detect new objects
  ST_HUMAN_ACTION_PARAM_FINGER_DETECT_INTERVAL = 1101,

  // \~chinese 显著性分割参数 \~english Background/figure segmentation parameters
  /// \~chinese 输出的分割结果中长边的长度[10,长边长度](默认长边为模型内部处理的长边，若设置会做resize处理输出).值越大,背景分割的耗时越长,边缘部分效果越好.值为0还原为默认值. \~english Set the length of the longer side for the background segmentation result. The value should be in the range [10, length of the longer side]. By default, the longer side is determined by the internal processing of the model. If set, the output will be resized accordingly. A larger value will result in longer processing time and better edge effect on the segmented background. Setting the value to 0 will restore the default value
  ST_HUMAN_ACTION_PARAM_SALIENTOBJECT_MAX_SIZE = 1201,
  /// \~chinese 分割羽化程度[0,1](默认值0.35),0 完全不羽化,1羽化程度最高,在strenth较小时,羽化程度基本不变.值越大,前景与背景之间的过度边缘部分越宽. \~english Set the degree of feathering for the background segmentation result. The value should be in the range [0, 1], where 0 means no feathering and 1 means the highest degree of feathering. When the strength is low, the degree of feathering remains almost unchanged. A higher value widens the transition edge between the foreground and background
  /// \~chinese 备注：只对1.5.0 人像分割模型有效 \~english Note: This parameter is only effective for the figure segmentation model v1.5.0
  ST_HUMAN_ACTION_PARAM_SALIENTOBJECT_BLUR_STRENGTH = 1202,
  /// \~chinese 检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转) \~english Set whether to rotate the grayscale background result image. The options are 0 (do not rotate, keep vertical) and 1 (rotate, align with the input image). By default, rotation is disabled
  ST_HUMAN_ACTION_PARAM_SALIENTOBJECT_RESULT_ROTATE = 1203,
  /// \~chinese 分割边界区域上限阈值. 开启温度系数时设置无效 \~english Set the upper threshold for the boundary region of the background segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_SALIENTOBJECT_MAX_THRESHOLD = 1204,
  /// \~chinese 分割边界区域下限阈值 开启温度系数时设置无效 \~english Set the lower threshold for the boundary region of the background segmentation result. This setting is invalid when the temperature coefficient is enabled
  ST_HUMAN_ACTION_PARAM_SALIENTOBJECT_MIN_THRESHOLD = 1205,
  //	ST_HUMAN_ACTION_PARAM_SEGMENT_KERNAL_TYPE = 406, \~chinese 已废弃 \~english (deprecated)
  /// \~chinese 分割检测结果边缘模糊程度 取值范围0-1, 视频版默认是0.5 图片版默认是1 \~english Set the degree of edge blur for the background segmentation result. The value should be in the range [0, 1]. The default value is 0.5 for video and 1 for images
  ST_HUMAN_ACTION_PARAM_SALIENTOBJECT_SEGMENT_RESULT_BLUR = 1206,
  /// \~chinese 分割检测结果边缘模糊程度需保证开启温度系数，大于0.5为开启，小于0.5为关闭，关闭状态下使用卡阈值模式得到边界，默认状态为开启 \~english Set whether to use the temperature coefficient for the background segmentation result. The value should be greater than 0.5 to enable it and less than 0.5 to disable it. When disabled, min max threshold should be used for mask postprocess. By default, this parameter is enabled
  ST_HUMAN_ACTION_PARAM_SALIENTOBJECT_SEGMENT_USE_TEMPERATURE = 1207,
  /// \~chinese 边缘移动参数，取值范围再[-2,2],默认值是1 \~english Set the edge shift parameter for the background segmentation. The value should be in the range [-2, 2], and the default value is 1
  ST_HUMAN_ACTION_PARAM_SALIENTOBJECT_SEGMENT_EDGESHIFT = 1209,
}
export const enum EffectParam{
  EFFECT_PARAM_MIN_FRAME_INTERVAL,        ///< \~chinese 贴纸前后两个序列帧切换的最小时间间隔，单位为毫秒。当两个相机帧处理的间隔小于这个值的时候，当前显示的贴纸序列帧会继续显示，直到显示的时间大于该设定值贴纸才会切换到下一阵，相机帧不受影响。 \~english The minimum time interval between two sequential frames of stickers, in milliseconds. When the interval between two camera frame processing is less than this value, the current displayed sticker sequential frame will continue to display until the displayed time is greater than this set value, and then the sticker will switch to the next formation, and the camera frame will not be affected.

  EFFECT_PARAM_MAX_MEMORY_BUDGET_MB,      ///< \~chinese 设置贴纸素材资源所占用的最大内存（MB），当估算内存超过这个值时，将不能再加载新的素材包 \~english Set the maximum memory (MB) occupied by sticker material resources. When the estimated memory exceeds this value, new material packages can no longer be loaded.

  EFFECT_PARAM_QUATERNION_SMOOTH_FRAME,   ///< \~chinese 设置相机姿态平滑参数，表示平滑多少帧, 越大延迟越高，抖动越微弱 \~english Set camera attitude smoothing parameters, indicating how many frames to smooth, the larger the delay, the weaker the jitter.

  EFFECT_PARAM_USE_INPUT_TIMESTAMP,       ///< \~chinese 设置贴纸是否使用外部时间戳更新 \~english Set whether the sticker uses an external timestamp update

  EFFECT_PARAM_PREFER_MEMORY_CACHE,       ///< \~chinese 倾向于空间换时间，传0的话，则尽可能清理内部缓存，保持内存最小。目前主要影响3D共享资源 \~english Prefer space for time. If 0 is passed, it will clean up the internal cache as much as possible to keep the memory at a minimum. Currently, it mainly affects 3D shared resources.

  EFFECT_PARAM_DISABLE_BEAUTY_OVERLAP,    ///< \~chinese 传入大于0的值，禁用美颜Overlap逻辑（贴纸中的美颜会覆盖前面通过API或者贴纸生效的美颜效果，贴纸成组覆盖，API单个覆盖），默认启用Overlap \~english Enter a value greater than 0 to disable the beauty overlap logic (the beauty in the sticker will cover the beauty effect that has taken effect through the API or the sticker, the stickers are overlapped in groups, and the API is overlapped individually), overlap is enabled by default

  EFFECT_PARAM_DISABLE_MODULE_REORDER,    ///< \~chinese 传入大于0的值，强制按素材包添加顺序显示贴纸、美妆效果，后添加的在上层显示，该选项只会影响设置之后添加的素材。默认（0）会对v3.1之前的素材包重排module的渲染顺序。重新排序是为了在与美妆、风格素材包叠加时达到最佳效果 \~english Input a value greater than 0 to render modules strictly by add package order. stickers and makeups added late would render on top of others. This option will only affect materials added after setting. default value (0) will reorder the rendering order of modules from packages version less than v3.1. The reorder is to achieve the best effect when overlaying with beauty makeup and style material packages.

  EFFECT_PARAM_3D_POSE_SOLUTION,          ///< \~chinese 3DPose计算方案，传入0使用106旧模型方案，传1使用基于282模型优化的Pose方案，默认值为1 \~english 3DPose calculation solution, input 0 to use the old 106 model solution, input 1 to use the Pose solution optimized based on the 282 model, the default value is 1.

  EFFECT_PARAM_RENDER_DELAY_FRAME,        ///< \~chinese 设置未来帧帧数，默认值是0, 需要是大于等于0的值，0表示不开未来帧 \~english Set the number of future frames, the default value is 0, it needs to be a value greater than or equal to 0, 0 indicates that future frames are not opened.

  EFFECT_PARAM_GREEN_COLOR_BALANCE,       ///< \~chinese 设置去绿程度，0表示不去绿，1表示最大程度去绿，默认值为1 \~english Set the degree of green removal, 0 indicates no green removal, 1 indicates the maximum degree of green removal, the default value is 1.

  EFFECT_PARAM_GREEN_SPILL_BY_ALPHA,      ///< \~chinese 设置去绿色彩平衡, 和去绿程度配套使用, 平衡因去绿导致的主体颜色变化, 范围[0.0, 1.0], 默认0.5(不进行平衡) \~english Set green removal color balance, used in conjunction with green removal intensity to balance the color change caused by green removal. Range [0.0, 1.0], default 0.5 (no balance).

  EFFECT_PARAM_EXPLICIT_OUT_TEX_BLIT,     ///< \~chinese 设置Render接口的输出纹理是否做一次显示拷贝，在传入的输入纹理与D3D纹理绑定共享时需要传1弃用，默认0不做。 \~english set whether do an explicit texture copy for render output texture.  When output texture is bound with a D3D texture, this option needs turn on with 1, default is 0 (disabled).

  EFFECT_PARAM_GREEN_SEGMENT_COLOR,       /// \~chinese 设置绿幕分割颜色RGB值,默认为绿色,将颜色值（16进制数0xFFFFFF,按R、G、B排列）按float类型传入 \~english Set the RGB color value for green screen segmentation. The default color is green (hexadecimal value 0xFFFFFF, arranged as R, G, B). The color value should be passed as a float type

  EFFECT_PARAM_PLASTIC_FACE_OCCLUSION,    ///< \~chinese 微整形效果遮挡，目前支持白牙、亮眼，默认值为0, 表示没有效果遮挡，1表示开启效果遮挡 \~english MicroPlastic effect occlusion, and currently supports teeth whitening and eye brightening. default value is 0, means no effect occlusion, 1 means open effect occlusion.

  EFFECT_PARAM_MAKEUP_PERFORMANCE_HINT,   ///< \~chinese 设置美妆性能/效果优先级倾向，性能优先适用于多人脸的场景，引擎内部会根据设置调整渲染策略, 0表示效果优先， 1表示性能优先，默认值为0 \~english Configure the priority preference for makeup performance/effects. Performance priority is suitable for scenarios with multiple faces, and the engine internally will adjust the rendering strategy according to the setting. A value of 0 indicates a preference for effects, while a value of 1 indicates a preference for performance. The default value is 0.

  EFFECT_PARAM_DISABLE_TRIGER_OVERLAP,    ///< \~chinese 传入大于0的值，禁用贴纸触发逻辑对Overlap的影响（贴纸中的美颜触发会覆盖前面通过API或者贴纸生效的美颜效果），默认触发逻辑会对Overlap的影响 \~english Pass a value greater than 0 to disable the effect of sticker trigger logic on Overlap (beautification triggered by stickers will override the beautification effects applied earlier through API or stickers). By default, the trigger logic will affect Overlap.

}

export const enum EffectsMode{
  PREVIEW = 0,
  PHOTO,
  VIDEO
}

/**
 * Beauty Type
 */
export const enum BeautyType{
  EFFECT_BEAUTY_UNKNOWN                           = -1,
  EFFECT_BEAUTY_BACK                              = -2,

  // \~chinese 基础美颜 base
  // \~english Basic beauty
  EFFECT_BEAUTY_BASE_WHITTEN                      = 101,  ///< \~chinese 美白，[0,1.0], 默认值0.30, 0.0不做美白 \~english Whitening, [0,1.0], default value 0.30, 0.0 means no whitening
  EFFECT_BEAUTY_BASE_REDDEN                       = 102,  ///< \~chinese 红润, [0,1.0], 默认值0.36, 0.0不做红润 \~english Redden, [0,1.0], default value 0.36, 0.0 means no reddening
  EFFECT_BEAUTY_BASE_FACE_SMOOTH                  = 103,  ///< \~chinese 磨皮, [0,1.0], 默认值0.74, 0.0不做磨皮 \~english Face smoothing, [0,1.0], default value 0.74, 0.0 means no face smoothing
  EFFECT_BEAUTY_BASE_SKIN_SMOOTH                  = 104,  ///< \~chinese 身体皮肤祛皱, [0,1.0],默认值0.0, 0.0不做身体皮肤祛皱 \~english Body skin wrinkle removal, [0, 1.0], default value 0.0, 0.0 disables wrinkle removal

  // \~chinese 美形 reshape
  // \~english Beauty reshaping
  EFFECT_BEAUTY_RESHAPE_SHRINK_FACE               = 201,  ///< \~chinese 瘦脸, [0,1.0], 默认值0.11, 0.0不做瘦脸效果 \~english Face slimming, [0,1.0], default value 0.11, 0.0 means no face slimming effect
  EFFECT_BEAUTY_RESHAPE_ENLARGE_EYE               = 202,  ///< \~chinese 大眼, [0,1.0], 默认值0.13, 0.0不做大眼效果 \~english Eye enlargement, [0,1.0], default value 0.13, 0.0 means no eye enlargement effect
  EFFECT_BEAUTY_RESHAPE_SHRINK_JAW                = 203,  ///< \~chinese 小脸, [0,1.0], 默认值0.10, 0.0不做小脸效果 \~english Jaw slimming, [0,1.0], default value 0.10, 0.0 means no jaw slimming effect
  EFFECT_BEAUTY_RESHAPE_NARROW_FACE               = 204,  ///< \~chinese 窄脸, [0,1.0], 默认值0.0, 0.0不做窄脸 \~english Narrow face, [0,1.0], default value 0.0, 0.0 means no narrow face effect
  EFFECT_BEAUTY_RESHAPE_ROUND_EYE                 = 205,  ///< \~chinese 圆眼, [0,1.0], 默认值0.0, 0.0不做圆眼 \~english Round eyes, [0,1.0], default value 0.0, 0.0 means no round eyes effect

  // \~chinese 微整形 plastic
  // \~english Micro Plastic group
  EFFECT_BEAUTY_PLASTIC_THINNER_HEAD              = 301,  ///< \~chinese 小头, [0, 1.0], 默认值0.0, 0.0不做小头效果 \~english Smaller head, [0, 1.0], default value 0.0, 0.0 means no smaller head effect
  EFFECT_BEAUTY_PLASTIC_THIN_FACE                 = 302,  ///< \~chinese 瘦脸型，[0,1.0], 默认值0.0, 0.0不做瘦脸型效果 \~english Thinner face shape, [0,1.0], default value 0.0, 0.0 means no thinner face shape effect
  EFFECT_BEAUTY_PLASTIC_CHIN_LENGTH               = 303,  ///< \~chinese 下巴，[-1, 1], 默认值为0.0，[-1, 0]为短下巴，[0, 1]为长下巴 \~english Chin length, [-1, 1], default value is 0.0, [-1, 0] means shorter chin, [0, 1] means longer chin
  EFFECT_BEAUTY_PLASTIC_HAIRLINE_HEIGHT           = 304,  ///< \~chinese 额头，[-1, 1], 默认值为0.0，[-1, 0]为低发际线，[0, 1]为高发际线 \~english Hairline height, [-1, 1], default value is 0.0, [-1, 0] means lower hairline, [0, 1] means higher hairline
  EFFECT_BEAUTY_PLASTIC_APPLE_MUSLE               = 305,  ///< \~chinese 苹果肌，[0, 1.0]，默认值为0.0，0.0不做苹果肌 \~english Apple muscle, [0, 1.0], default value is 0.0, 0.0 means no apple muscle effect
  EFFECT_BEAUTY_PLASTIC_NARROW_NOSE               = 306,  ///< \~chinese 瘦鼻翼，[0, 1.0], 默认值为0.0，0.0不做瘦鼻 \~english Narrow nose wings, [0, 1.0], default value is 0.0, 0.0 means no narrow nose wings effect
  EFFECT_BEAUTY_PLASTIC_NOSE_LENGTH               = 307,  ///< \~chinese 长鼻，[-1, 1], 默认值为0.0, [-1, 0]为短鼻，[0, 1]为长鼻 \~english Longer nose, [-1, 1], default value is 0.0, [-1, 0] means shorter nose, [0, 1] means longer nose
  EFFECT_BEAUTY_PLASTIC_PROFILE_RHINOPLASTY       = 308,  ///< \~chinese 侧脸隆鼻，[0, 1.0]，默认值为0.0，0.0不做侧脸隆鼻效果 \~english Profile rhinoplasty, [0, 1.0], default value is 0.0, 0.0 means no profile rhinoplasty effect
  EFFECT_BEAUTY_PLASTIC_MOUTH_SIZE                = 309,  ///< \~chinese 嘴型，[-1, 1]，默认值为0.0，[-1, 0]为放大嘴巴，[0, 1]为缩小嘴巴 \~english Mouth shape, [-1, 1], default value is 0.0, [-1, 0] means larger mouth, [0, 1] means smaller mouth
  EFFECT_BEAUTY_PLASTIC_PHILTRUM_LENGTH           = 310,  ///< \~chinese 缩人中，[-1, 1], 默认值为0.0，[-1, 0]为长人中，[0, 1]为短人中 \~english Philtrum length, [-1, 1], default value is 0.0, [-1, 0] means longer philtrum, [0, 1] means shorter philtrum
  EFFECT_BEAUTY_PLASTIC_EYE_DISTANCE              = 311,  ///< \~chinese 眼距，[-1, 1]，默认值为0.0，[-1, 0]为减小眼距，[0, 1]为增加眼距 \~english Eye distance, [-1, 1], default value is 0.0, [-1, 0] means reducing eye distance, [0, 1] means increasing eye distance
  EFFECT_BEAUTY_PLASTIC_EYE_ANGLE                 = 312,  ///< \~chinese 眼睛角度，[-1, 1]，默认值为0.0，[-1, 0]为左眼逆时针旋转，[0, 1]为左眼顺时针旋转，右眼与左眼相对 \~english Eye angle, [-1, 1], default value is 0.0, [-1, 0] means rotating left eye counterclockwise, [0, 1] means rotating left eye clockwise, relative to right eye
  EFFECT_BEAUTY_PLASTIC_OPEN_CANTHUS              = 313,  ///< \~chinese 开眼角，[0, 1.0]，默认值为0.0， 0.0不做开眼角 \~english Eye opening, [0, 1.0], default value is 0.0, 0.0 means no eye opening effect
  EFFECT_BEAUTY_PLASTIC_BRIGHT_EYE                = 314,  ///< \~chinese 亮眼，[0, 1.0]，默认值为0.0，0.0不做亮眼 \~english Brighten eyes, [0, 1.0], default value is 0.0, 0.0 means no eye brightening effect
  EFFECT_BEAUTY_PLASTIC_REMOVE_DARK_CIRCLES       = 315,  ///< \~chinese 祛黑眼圈，[0, 1.0]，默认值为0.0，0.0不做去黑眼圈 \~english Remove dark circles, [0, 1.0], default value is 0.0, 0.0 means no dark circles removal effect
  EFFECT_BEAUTY_PLASTIC_REMOVE_NASOLABIAL_FOLDS   = 316,  ///< \~chinese 祛法令纹，[0, 1.0]，默认值为0.0，0.0不做去法令纹 \~english Remove nasolabial folds, [0, 1.0], default value is 0.0, 0.0 means no nasolabial folds removal effect
  EFFECT_BEAUTY_PLASTIC_WHITE_TEETH               = 317,  ///< \~chinese 白牙，[0, 1.0]，默认值为0.0，0.0不做白牙 \~english White teeth, [0, 1.0], default value is 0.0, 0.0 means no teeth whitening effect
  EFFECT_BEAUTY_PLASTIC_SHRINK_CHEEKBONE          = 318,  ///< \~chinese 瘦颧骨， [0, 1.0], 默认值0.0， 0.0不做瘦颧骨 \~english Shrink cheekbones, [0, 1.0], default value is 0.0, 0.0 means no cheekbone shrinking effect
  EFFECT_BEAUTY_PLASTIC_OPEN_EXTERNAL_CANTHUS     = 319,  ///< \~chinese 开外眼角比例，[0, 1.0]，默认值为0.0， 0.0不做开外眼角 \~english Open external canthus, [0, 1.0], default value is 0.0, 0.0 means no opening of the outer canthus effect
  EFFECT_BEAUTY_PLASTIC_SHRINK_JAWBONE            = 320,  ///< \~chinese 瘦下颔，[0, 1.0], 默认值0.0， 0.0不做瘦下颔 \~english Shrink jawbone, [0, 1.0], default value is 0.0, 0.0 means no jawbone shrinking effect
  EFFECT_BEAUTY_PLASTIC_SHRINK_ROUND_FACE         = 321,  ///< \~chinese 圆脸瘦脸，[0, 1.0], 默认值0.0， 0.0不做瘦脸 \~english Shrink round face, [0, 1.0], default value is 0.0, 0.0 means no face slimming effect for round face
  EFFECT_BEAUTY_PLASTIC_SHRINK_LONG_FACE          = 322,  ///< \~chinese 长脸瘦脸，[0, 1.0], 默认值0.0， 0.0不做瘦脸 \~english Shrink long face, [0, 1.0], default value is 0.0, 0.0 means no face slimming effect for long face
  EFFECT_BEAUTY_PLASTIC_SHRINK_GODDESS_FACE       = 323,  ///< \~chinese 女神瘦脸，[0, 1.0], 默认值0.0， 0.0不做瘦脸 \~english Shrink goddess face, [0, 1.0], default value is 0.0, 0.0 means no face slimming effect for goddess face
  EFFECT_BEAUTY_PLASTIC_SHRINK_NATURAL_FACE       = 324,  ///< \~chinese 自然瘦脸，[0, 1.0], 默认值0.0， 0.0不做瘦脸 \~english Shrink natural face, [0, 1.0], default value is 0.0, 0.0 means no face slimming effect for natural face
  EFFECT_BEAUTY_PLASTIC_SHRINK_WHOLE_HEAD         = 325,  ///< \~chinese 整体缩放小头，[0, 1.0], 默认值0.0, 0.0不做整体缩放小头效果 \~english Shrink the whole head, [0, 1.0], default value is 0.0, 0.0 means no shrinking of the whole head effect
  EFFECT_BEAUTY_PLASTIC_EYE_HEIGHT                = 326,  ///< \~chinese 眼睛位置比例，[-1, 1]，默认值0.0, [-1, 0]向下移动眼睛，[0, 1]向上移动眼睛 \~english Eye position ratio, [-1, 1], default value is 0.0, [-1, 0] means moving eyes downward, [0, 1] means moving eyes upward
  EFFECT_BEAUTY_PLASTIC_MOUTH_CORNER              = 327,  ///< \~chinese 嘴角上移比例，[0, 1.0]，默认值0.0, 0.0不做嘴角调整 \~english Mouth corner lifting ratio, [0, 1.0], default value is 0.0, 0.0 means no mouth corner adjustment
  EFFECT_BEAUTY_PLASTIC_HAIRLINE                  = 328,  ///< \~chinese 新发际线高低比例，[-1, 1]，默认值0.0, [-1, 0]为低发际线，[0, 1]为高发际线 \~english Hairline height ratio, [-1, 1], default value is 0.0, [-1, 0] means lower hairline, [0, 1] means higher hairline
  EFFECT_BEAUTY_PLASTIC_FULLER_LIPS               = 329,  ///< \~chinese 丰唇，[-1, 1]，默认值0.0，[-1, 0]为嘴唇变薄，[0, 1]为丰唇 \~english Lip fullness adjustment, [-1, 1], default value is 0.0; [-1, 0] reduces lip fullness, [0, 1] increases lip fullness
  EFFECT_BEAUTY_PLASTIC_MOUTH_WIDTH               = 330,  ///< \~chinese 嘴巴宽度，[-1, 1]，默认值0.0，[-1, 0]为嘴巴变宽，[0, 1]为嘴巴变窄 \~english Mouth width adjustment, [-1, 1], default value is 0.0; [-1, 0] increases width, [0, 1] decreases width
  EFFECT_BEAUTY_PLASTIC_BROW_HEIGHT               = 331,  ///< \~chinese 眉毛高度，[-1, 1]，默认值0.0，[-1, 0]为眉毛上移，[0, 1]为眉毛下移 \~english Eyebrow height adjustment, [-1, 1], default value is 0.0; [-1, 0] raises brows, [0, 1] lowers brows
  EFFECT_BEAUTY_PLASTIC_BROW_THICKNESS            = 332,  ///< \~chinese 眉毛粗细，[-1, 1]，默认值0.0，[-1, 0]为眉毛变细，[0, 1]为眉毛增粗 \~english Eyebrow thickness adjustment, [-1, 1], default value is 0.0; [-1, 0] makes brows thinner, [0, 1] makes brows thicker
  EFFECT_BEAUTY_PLASTIC_BROW_DISTANCE             = 333,  ///< \~chinese 眉毛间距，[-1, 1]，默认值0.0，[-1, 0]为眉毛间距变大，[0, 1]为眉毛间距变小 \~english Eyebrow distance adjustment, [-1, 1], default value is 0.0; [-1, 0] increases distance between brows, [0, 1] decreases it
  EFFECT_BEAUTY_PLASTIC_FACE_V_SHAPE              = 334,  ///< \~chinese V脸，从下颌角到下巴的V脸效果，[0, 1.0]，默认值0.0, 0.0不做V脸 \~english V-shaped face effect (jawline to chin), [0, 1.0], default value is 0.0; 0.0 applies no V-shape effect
  EFFECT_BEAUTY_PLASTIC_FACE_FULL_V_SHAPE         = 335,  ///< \~chinese V脸，整脸的V脸效果，[0, 1.0]，默认值0.0, 0.0不做V脸 \~english Full V-shaped face effect, [0, 1.0], default value is 0.0; 0.0 applies no V-shape effect
  EFFECT_BEAUTY_PLASTIC_NOSE_TIP                  = 336,  ///< \~chinese 瘦鼻头，[0, 1.0]，默认值0.0, 0.0不做瘦鼻头 \~english Nose tip refinement, [0, 1.0], default value is 0.0; 0.0 applies no nose tip refinement
  EFFECT_BEAUTY_PLASTIC_NOSE_BRIDGE               = 337,  ///< \~chinese 鼻梁调整，[0, 1.0]，默认值0.0, 0.0不做鼻梁调整 \~english Nose bridge adjustment, [0, 1.0], default value is 0.0; 0.0 applies no nose bridge adjustment
  EFFECT_BEAUTY_PLASTIC_ENLARGE_PUPIL             = 338,  ///< \~chinese 放大瞳孔，[0, 1.0]，默认值0.0, 0.0不做瞳孔放大 \~english Pupil enlargement, [0, 1.0], default value is 0.0; 0.0 applies no pupil enlargement


  // \~chinese 调整 tone
  // \~english Tone adjustment
  EFFECT_BEAUTY_TONE_CONTRAST                     = 601,  ///< \~chinese 对比度, [0,1.0], 默认值0.05, 0.0不做对比度处理 \~english Contrast, [0,1.0], default value 0.05, 0.0 means no contrast adjustment
  EFFECT_BEAUTY_TONE_SATURATION                   = 602,  ///< \~chinese 饱和度, [0,1.0], 默认值0.10, 0.0不做饱和度处理 \~english Saturation, [0,1.0], default value 0.10, 0.0 means no saturation adjustment
  EFFECT_BEAUTY_TONE_SHARPEN                      = 603,  ///< \~chinese 锐化, [0, 1.0], 默认值0.0, 0.0不做锐化 \~english Sharpening, [0, 1.0], default value 0.0, 0.0 means no sharpening
  EFFECT_BEAUTY_TONE_CLEAR                        = 604,  ///< \~chinese 清晰度, 清晰强度, [0,1.0], 默认值0.0, 0.0不做清晰 \~english Clarity, clarity strength, [0,1.0], default value 0.0, 0.0 means no clarity adjustment
  EFFECT_BEAUTY_TONE_BOKEH                        = 605,  ///< \~chinese 背景虚化强度, [0,1.0], 默认值0.0, 0.0不做背景虚化 \~english Bokeh intensity, [0,1.0], default value 0.0, 0.0 means no bokeh effect
  EFFECT_BEAUTY_TONE_DENOISING                    = 606,  ///< \~chinese 去噪，[0, 1.0], 默认值0.0, 0.0不做去噪处理 \~english denoising intensity, [0, 1.0], default value 0.0 means off
  EFFECT_BEAUTY_TONE_COLOR_TONE                   = 607,  ///< \~chinese 色调，[-1.0, 1.0], 默认值0.0, 0.0不做色调处理 \~english Color tone adjustment, [-1.0, 1.0], default value 0.0 means off
  EFFECT_BEAUTY_TONE_COLOR_TEMPERATURE            = 608,  ///< \~chinese 色温，[-1.0, 1.0], 默认值0.0, 0.0不做色温处理 \~english Color tempareture adjustment, [-1.0, 1.0], default value 0.0 means off

  // \~chinese 美妆 makeup
  // \~english Makeup group
  EFFECT_BEAUTY_MAKEUP_HAIR_DYE                   = 401,  ///< \~chinese 染发 \~english Hair dye
  EFFECT_BEAUTY_MAKEUP_LIP                        = 402,  ///< \~chinese 口红 \~english Lipstick
  EFFECT_BEAUTY_MAKEUP_CHEEK                      = 403,  ///< \~chinese 腮红 \~english Blush
  EFFECT_BEAUTY_MAKEUP_NOSE                       = 404,  ///< \~chinese 修容 \~english Nose contouring
  EFFECT_BEAUTY_MAKEUP_EYE_BROW                   = 405,  ///< \~chinese 眉毛 \~english Eyebrow
  EFFECT_BEAUTY_MAKEUP_EYE_SHADOW                 = 406,  ///< \~chinese 眼影 \~english Eyeshadow
  EFFECT_BEAUTY_MAKEUP_EYE_LINE                   = 407,  ///< \~chinese 眼线 \~english Eyeliner
  EFFECT_BEAUTY_MAKEUP_EYE_LASH                   = 408,  ///< \~chinese 眼睫毛 \~english Eyelash
  EFFECT_BEAUTY_MAKEUP_EYE_BALL                   = 409,  ///< \~chinese 美瞳 \~english Eye color
  EFFECT_BEAUTY_MAKEUP_PACKED                     = 410,  ///< \~chinese 打包的美妆素材，可能包含一到多个单独的美妆模块，与其他单独美妆可以同时存在 \~english Packed makeup material, may contain one or more individual makeup modules, can coexist with other individual makeups
  EFFECT_BEAUTY_MAKEUP_EYE_PAINTING               = 411,  ///< \~chinese 眼妆 \~english Eye painting

  // \~chinese 滤镜 filter
  // \~english Filter group
  EFFECT_BEAUTY_FILTER                            = 501,  ///< \~chinese 滤镜 \~english Filter

  // \~chinese 试妆 tryon
  // \~english Makeup tryon
  EFFECT_BEAUTY_TRYON_HAIR_COLOR                  = 701,  ///< \~chinese 染发，可设置的参数包括：颜色，强度，明暗度，高光 \~english Hair dye, configurable parameters include: color, intensity, brightness, highlight
  EFFECT_BEAUTY_TRYON_LIPSTICK                    = 702,  ///< \~chinese 口红，可设置的参数包括：颜色，强度，高光(特定材质：水润、闪烁、金属)，质地类型 \~english Lipstick, configurable parameters include: color, intensity, highlight (specific textures: moisturizing, shimmering, metallic), texture type
  EFFECT_BEAUTY_TRYON_LIPLINE                     = 703,  ///< \~chinese 唇线，可设置的参数包括：颜色，强度，唇线线宽 \~english Lip line, configurable parameters include: color, intensity, lip line width
  EFFECT_BEAUTY_TRYON_BLUSH                       = 704,  ///< \~chinese 腮红，可设置的参数包括：颜色，强度 \~english Blush, configurable parameters include: color, intensity
  EFFECT_BEAUTY_TRYON_BROW                        = 705,  ///< \~chinese 眉毛，可设置的参数包括：颜色，强度 \~english Eyebrow, configurable parameters include: color, intensity
  EFFECT_BEAUTY_TRYON_FOUNDATION                  = 706,  ///< \~chinese 粉底，可设置的参数包括：颜色，强度 \~english Foundation, configurable parameters include: color, intensity
  EFFECT_BEAUTY_TRYON_CONTOUR                     = 707,  ///< \~chinese 修容，可设置的参数包括：强度（整体），区域信息（区域id，颜色，强度） \~english Contouring, configurable parameters include: intensity (overall), area information (area id, color, intensity)
  EFFECT_BEAUTY_TRYON_EYESHADOW                   = 708,  ///< \~chinese 眼影，可设置的参数包括：强度（整体），区域信息（区域id，颜色，强度） \~english Eyeshadow, configurable parameters include: intensity (overall), area information (area id, color, intensity)
  EFFECT_BEAUTY_TRYON_EYELINER                    = 709,  ///< \~chinese 眼线，可设置的参数包括：强度（整体），区域信息（区域id，颜色，强度） \~english Eyeliner, configurable parameters include: intensity (overall), area information (area id, color, intensity)
  EFFECT_BEAUTY_TRYON_EYELASH                     = 710,  ///< \~chinese 眼睫毛，可设置的参数包括：颜色，强度 \~english Eyelash, configurable parameters include: color, intensity
  EFFECT_BEAUTY_TRYON_STAMPLINER                  = 711,  ///< \~chinese 眼印，可设置的参数包括：颜色，强度 \~english Eye stamp, configurable parameters include: color, intensity

  // \~chinese 3D 微整形
  // \~english 3D micro plastic
  EFFECT_BEAUTY_3D_MICRO_PLASTIC                  = 801,

}

/**
 * Rotate Type
 */
export const enum RotateType{
  ROTATE_0 = 0,
  ROTATE_90,
  ROTATE_180,
  ROTATE_270,
}
export const enum PixelFormat{
  ST_PIX_FMT_GRAY8 = 0,   ///< Y    1        8bpp ( \~chinese 单通道8bit灰度像素 \~english Single-channel 8-bit grayscale pixel)
  ST_PIX_FMT_YUV420P = 1, ///< YUV  4:2:0   12bpp ( \~chinese 3通道, 一个亮度通道, 另两个为U分量和V分量通道, 所有通道都是连续的. 只支持I420 \~english 3 channels, one luminance channel, and the other two are U and V component channels, all channels are contiguous. Only supports I420)
  ST_PIX_FMT_NV12 = 2,    ///< YUV  4:2:0   12bpp ( \~chinese 2通道, 一个通道是连续的亮度通道, 另一通道为UV分量交错 \~english 2 channels, one channel is a contiguous luminance channel, and the other channel is interleaved UV components)
  ST_PIX_FMT_NV21 = 3,    ///< YUV  4:2:0   12bpp ( \~chinese 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 \~english 2 channels, one channel is a contiguous luminance channel, and the other channel is interleaved VU components)
  ST_PIX_FMT_BGRA8888 = 4,///< BGRA 8:8:8:8 32bpp ( \~chinese 4通道32bit BGRA 像素 \~english 4-channel 32-bit BGRA pixel)
  ST_PIX_FMT_BGR888 = 5,  ///< BGR  8:8:8   24bpp ( \~chinese 3通道24bit BGR 像素 \~english 3-channel 24-bit BGR pixel)
  ST_PIX_FMT_RGBA8888 = 6,///< RGBA 8:8:8:8 32bpp ( \~chinese 4通道32bit RGBA 像素 \~english 4-channel 32-bit RGBA pixel)
  ST_PIX_FMT_RGB888 = 7,  ///< RGB  8:8:8   24bpp ( \~chinese 3通道24bit RGB 像素 \~english 3-channel 24-bit RGB pixel)
  ST_PIX_FMT_FLOAT = 8    ///< Y    1       32bpp ( \~chinese 1通道 32bit float 像素 \~english Single-channel 32-bit float pixel)
}

