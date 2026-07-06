import libstmobile ,{ BeautyType,EffectBeautyGroup }from '@softsugar/mars_effects'
import BeautyObject from '../models/Beauty/BeautyObject';
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager';
import { EventBus, EventType } from './EventBus';

let instance:UIInstance
export class UIInstance {
  static GetInstance(): UIInstance {
    if (instance == undefined) {
      instance = new UIInstance();
    }
    return instance;
  }
  private constructor() {
  }
  private overlapMap = new Map<BeautyObject,number>()
  public setOverLap(){
    let infoList = libstmobile.getOverlappedBeautyInfo()
    if (infoList.length > 0) {
      infoList.forEach(element => {
        console.log('~~~~~~~~~~~overlap', element.type)
        //滤镜
        if (element.type == BeautyType.EFFECT_BEAUTY_FILTER){
          EventBus.emitEvent(EventType.SetOverLapFilter)
        }
        //makeup
        else if (element.type >= BeautyType.EFFECT_BEAUTY_MAKEUP_HAIR_DYE && element.type <= BeautyType.EFFECT_BEAUTY_MAKEUP_AEGYO_SAL){
          EventBus.emitEvent(EventType.SetOverLapMakeup,{data:{'type':element.type}})
          console.log('~~~~~~~~~~~overlap  makeup', element.type)
        }
        //美颜
        else {
          let data =  BeautyResourceManager.getInstance().dataSource
          for (let i = 0; i < data.length;i++){
            let group = data[i]
            for (let j = 0; j < group.beauties.length;j++){
              let beauty = group.beauties[j]
              if (!beauty.subBeauties || beauty.subBeauties.length<=0) {
                if (beauty.cleanObject.beauty_type == element.type&&(element.mode == 0 || beauty.cleanObject.beauty_mode_param == element.mode) ) {
                  if (!this.overlapMap.has(beauty)) {
                    this.overlapMap.set(beauty,beauty.currentStrength)
                  }
                  beauty.currentStrength = element.strength
                }
              }
            }
          }
        }
      });
    }
  }

  public resetOverLap(){
    this.overlapMap.forEach((value,key)=>{
      key.currentStrength = value
    })

    EventBus.emitEvent(EventType.ReSetOverLapFilter)
    EventBus.emitEvent(EventType.ReSetOverLapMakeup)
    this.overlapMap.clear()
  }
}