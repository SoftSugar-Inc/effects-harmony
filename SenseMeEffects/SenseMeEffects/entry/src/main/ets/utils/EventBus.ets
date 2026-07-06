
import { emitter } from '@kit.BasicServicesKit';

export class EventBus {
  static emitEvent(id:EventType, data: emitter.EventData|undefined = undefined) {
    emitter.emit({ eventId: id }, data);
  }


  static listenSingleEvent(id:EventType, callback: (data: emitter.EventData) => void) {
    if (emitter.getListenerCount(id) > 0) {
      emitter.off(id)
    }
    emitter.on({ eventId: id }, callback);
  }

  static listenEvent(id:EventType, callback: (data: emitter.EventData) => void) {
    emitter.on({ eventId: id }, callback);
  }

  static unListenEvent(eventId:number){
    emitter.off(eventId)
  }

  static renderTimer: number = -1
  static emitProcess(){
    // 防抖：快速触发时先缓存，只触发最后一次
    if (EventBus.renderTimer !== -1) {
      clearTimeout(EventBus.renderTimer)
    }
    EventBus.renderTimer = setTimeout(() => {
      EventBus.emitEvent(EventType.ProcessRender)
      EventBus.renderTimer = -1
    }, 10)
  }
}
export enum  EventType{
  None = 0,
  //初始化完毕
  OnModelLoaded =1000,
  //触发渲染
  ProcessRender = 1001,
  //渲染区域点击事件
  OnXComponentClick = 1002,
  //美体-背景锁定切换
  BodyBeautyLock = 1003,
  //美体-mesh
  BodyBeautyMesh = 1004,

  //弹窗
  ShowMessage = 1005,

  //视频状态
  VideoStateChange,

  //多人切换
  MultiBodyChange,
  // 选中的人脸改变（用于更新UI）
  SelectedFaceChanged,
  //Beauty类型切换
  OnBeautyModeChange,

  ResetBeauty,

  //OverLap
  SetOverLapFilter,
  ReSetOverLapFilter ,
  SetOverLapMakeup ,
  ReSetOverLapMakeup ,

}