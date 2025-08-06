/*
import { STEffectModel } from '../models/Sticker/STEffectModel'

@Component
export struct STSlider {
  @ObjectLink curItem : STEffectModel
  sliderCallback?: (value: STEffectModel) => void

  build() {
    Column(){
      Slider({
        value:(this.curItem&&this.curItem.selected)?this.curItem.strength:0,
        step: 1,
        min: 0,
        max: 100,
        style: SliderStyle.OutSet
      })
        .width('100%')
        .showTips(true)
        .showSteps(true)
        .onChange((value: number, mode: SliderChangeMode) => {
          if (this.sliderCallback !== undefined) {
            this.curItem.strength = value
            this.sliderCallback(this.curItem)
          }
        })
        .visibility((this.curItem && this.curItem.selected)?Visibility.Visible:Visibility.Hidden)
    }
  }
}*/
