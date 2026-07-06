import Logger from './utils/Logger'
import strecorder from 'libstplayer.so'
import { ICallBack } from './callback/ICallBack'
import { IResultCallBack } from './callback/IResultCallBack'
import { IFrameCallBack } from './callback/IFrameCallBack';

export class STRecorder {
  /**
   * set recorder source
   * @param path
   * @param callBack
   */
  static setRecorderDataSource(filePath:string, fd : number, width:number, height:number , format :number, rotate : number, callBack: ICallBack) {
    strecorder.setRecorderDataSource(filePath, fd, width, height, format, rotate).then((res: number) => {
      callBack.callBackResult(res)
    });
  }

  /**
   * startRecord
   * @param callBack
   */
  static startRecord(callBack:ICallBack) {
    strecorder.startRecord().then((res: number) => {
      callBack.callBackResult(res)
    });
  }

  /**
   * push video frame
   * @param video data
   * @param vidoe width
   * @param vidoe height
   * @param timestamp 可选的时间戳参数（微秒）
   */
  static pushVideoFrame(buffer:ArrayBuffer, width:number, height:number, timestamp?:number) : number{
   return strecorder.pushVideoFrame(buffer, width, height, timestamp);
  }

  /**
   * stopRecord
   */
  static stopRecord() : number{
    return strecorder.stopRecord()
  }

  /**
   * set recorder state callback
   * @param callBack 回调函数，接收状态码参数
   */
  static setRecorderStateCallback(callBack: (state: number) => void) {
    strecorder.setRecorderStateCallback(callBack);
  }
}
