import { PixelFormat ,RotateType} from '@softsugar/mars_effects'
import { PageData } from './CameraData'


export class ProcessData {
  pageData:PageData = new PageData()

  buffer: ArrayBuffer = new ArrayBuffer(0)
  format:PixelFormat = PixelFormat.ST_PIX_FMT_NV21
  width:number=0
  height:number=0
  stride:number =0
  rotation:RotateType=RotateType.ROTATE_0
  mirror:boolean=false

  orientation:RotateType=RotateType.ROTATE_0
  outFormat:PixelFormat = PixelFormat.ST_PIX_FMT_NV21

  lastFrameTime:number = 0

  constructor() {

  }
}

