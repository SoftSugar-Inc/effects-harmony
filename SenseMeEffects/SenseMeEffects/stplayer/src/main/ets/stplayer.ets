import stplayer from 'libstplayer.so'
import { ICallBack } from './callback/ICallBack'
import { IFrameCallBack } from './callback/IFrameCallBack'
import { VideoInfo } from './utils/VideoInfo'
import { PlayerState } from './state/PlayerState'

const TAG : string = "AVPLAYER";

export class STPlayer {
  /**
   * set video source
   * @param path
   * @param callBack
   */
  static setPlayerDataSource(path: string, fd : number, size:number, callBack: ICallBack) {
    stplayer.setPlayerDataSource(path, fd, size).then((res: number) => {
      callBack.callBackResult(res)
    });
  }

  /**
   * startPlay
   * @param callBack
   */
  static startPlay(callBack:IFrameCallBack) {
    let  bufferCallback = (data:ArrayBuffer, width : number, height:number, rotate:number, state:number) => {
      callBack.callBackResult(data, width, height, rotate, state);
    }
    stplayer.startPlay(bufferCallback);
  }

  static pausePlay(){
    stplayer.pausePlay();
  }

  static setPlayerCallback(callback:ICallBack) {
    let stateCallback = (state:PlayerState) => {
      callback.callBackResult(state);
    }
    stplayer.setStateCallback(stateCallback);
  }

  static getVideoInfo() : VideoInfo {
    return stplayer.getVideoInfo();
  }

  static setFrameRate(frameRate:number) {
    stplayer.setFrameRate(frameRate);
  }

  static resumePlay(){
    stplayer.resumePlay();
  }
  /**
   * stopPlay
   */
  static stopPlay(){
    stplayer.stopPlay();
  }
}
