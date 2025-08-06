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
   * @param path
   */
  static pushVideoFrame(buffer:ArrayBuffer, width:number, height:number) : number{
   return strecorder.pushVideoFrame(buffer, width, height);
  }

  /**
   * stopRecord
   */
  static stopRecord() : number{
    return strecorder.stopRecord()
  }
}
