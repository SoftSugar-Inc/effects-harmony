import curves from '@ohos.curves'
import List from '@ohos.util.List'
import { HomeType } from '../common/STDefines'
import { StylePanel } from './StylePanle'
import emitter from '@ohos.events.emitter'
import { EventBus, EventType } from '../utils/EventBus'

export enum PanelState{
  Video = 0,
  Photo = 1,
  Preview = 2
}
enum BottomTab{
  Video = 0,
  Photo = 1,
  Style = 2
}
@Component
export struct PreviewBottomPanel {
  onRecordOnClick?: () => void
  onSnapshotClick?: () => void
  onEntranceClick?: (index: number) => void
  @Prop panelState: PanelState
  @State bottomTab: BottomTab = BottomTab.Photo

  @State translateX: number = 0// 组件二偏移量
  @State animate: boolean = false;

  aboutToAppear(): void {
/*    this.translateX =  (this.panelState == 2)? 0: 20
    this.bottomTab = (this.panelState == PanelState.Video)? BottomTab.Video: BottomTab.Photo*/
    if (this.panelState == PanelState.Preview &&globalThis.homeParam && globalThis.homeParam.type == HomeType.Style){
        this.onTabChange(BottomTab.Style)
    }
    else {
      this.onTabChange(this.panelState == PanelState.Video?BottomTab.Video : BottomTab.Photo)
    }

    EventBus.listenEvent(EventType.OnXComponentClick,()=>{
      if (this.bottomTab == BottomTab.Style) {
        this.onTabChange(this.panelState == PanelState.Video ?BottomTab.Video : BottomTab.Photo)
      }
    })

  }

  aboutToDisappear(): void {
    EventBus.unListenEvent(EventType.OnXComponentClick)
  }


  build() {
    Stack(){

      Column(){
        Stack(){
          StylePanel({panelState :this.panelState})
            .width('100%')
            .visibility(this.bottomTab == BottomTab.Style?Visibility.Visible:Visibility.Hidden)
          Row() {
            GridRow({
              columns: 5,
              // gutter: { x: 5, y: 10 },
              breakpoints: {
                value: ["400vp", "600vp", "800vp"],
                reference: BreakpointsReference.WindowSize
              },
              direction: GridRowDirection.Row
            }) {
              ForEach(['特效', '美妆', '按钮', '滤镜', '美颜'], (item: string, index) => {
                GridCol({ span: { xs: 1, sm: 1, md: 1, lg: 1 }, offset: 0, order: 0 }) {
                  Column() {
                    if (index == 0){
                      Column() {
                        Image($r(`app.media.texiao`))
                          .width('40%')
                          .aspectRatio(1)
                        Blank()
                          .height(5)
                        Text('特效')
                          .fontColor(Color.White)
                          .fontSize(12)
                      }
                      .width('100%')
                      .aspectRatio(1)
                      .justifyContent(FlexAlign.Center)
                      .onClick(() => {
                        if (this.onEntranceClick !== undefined) {
                          this.onEntranceClick(index)
                        }
                      })
                    }else if(index == 1){
                      Column() {
                        Image($r(`app.media.meizhuang`))
                          .width('40%')
                          .aspectRatio(1)
                        Blank()
                          .height(5)
                        Text('美妆')
                          .fontColor(Color.White)
                          .fontSize(12)
                      }
                      .width('100%')
                      .aspectRatio(1)
                      .justifyContent(FlexAlign.Center)
                      .onClick(() => {
                        if (this.onEntranceClick !== undefined) {
                          this.onEntranceClick(index)
                        }
                      })
                    }else if (index == 2 && this.panelState == PanelState.Preview) {
                      Image($r(this.bottomTab == BottomTab.Video ? `app.media.preview_recording`:`app.media.preview_snapshoot`))
                        .onClick(()=>{
                          if(this.bottomTab == BottomTab.Video){
                            if(this.onRecordOnClick) this.onRecordOnClick()
                          }else{
                            if(this.onSnapshotClick) this.onSnapshotClick()
                          }
                        })
                        .width('100%')
                        .aspectRatio(1)
                        .padding(10)
                      Blank()
                        .height(5)

                    } else if (index == 3) {
                      Column() {
                        Image($r(`app.media.filter_entance_icon`))
                          .width('40%')
                          .aspectRatio(1)
                        Blank()
                          .height(5)
                        Text('滤镜')
                          .fontColor(Color.White)
                          .fontSize(12)
                      }
                      .width('100%')
                      .aspectRatio(1)
                      .justifyContent(FlexAlign.Center)
                      .onClick(() => {
                        if (this.onEntranceClick !== undefined) {
                          this.onEntranceClick(index)
                        }
                      })
                    } else if (index == 4) {
                      Column() {
                        Image($r(`app.media.beauty_entrance_icon`))
                          .width('40%')
                          .aspectRatio(1)
                        Blank()
                          .height(5)
                        Text('美颜')
                          .fontColor(Color.White)
                          .fontSize(12)
                      }
                      .width('100%')
                      .aspectRatio(1)
                      .justifyContent(FlexAlign.Center)
                      .onClick(() => {
                        if (this.onEntranceClick !== undefined) {
                          this.onEntranceClick(index)
                        }
                      })
                    }
                  }
                  .width("100%")
                  .justifyContent(FlexAlign.Center)
                }
              })
            }.width("100%")
          }
          .width('100%')
          .height(112)
          .backgroundColor(Color.Transparent)
          .visibility(this.bottomTab == BottomTab.Style?Visibility.Hidden:Visibility.Visible)
        }
        .alignContent(Alignment.BottomEnd)
        .height(216)
        .width('100%')

        Column(){
          Row({space:10}){
            ForEach(['视频','照片','风格'], (item: string, index) => {
              if (this.panelState == 2 || index== this.panelState || index == 2){
                ListItem() {
                  Column({space:5}){
                    Text(item)// .margin({ top: 5 })
                      .fontColor(this.bottomTab == index ? '#555555' : '#999999')
                      .width(28)
                      .height(14)
                      .textAlign(TextAlign.Center)
                      .fontSize(14)
                    Row().size({width:4,height:4}).backgroundColor(Color.Black).borderRadius(2).visibility(this.bottomTab == index?Visibility.Visible:Visibility.Hidden)
                  }
                }
                .onClick(()=>{
                  this.onTabChange(index)
                })
              }
            })
          }
          .translate({ x: this.translateX })
          .animation({
            duration:10000,
            curve: curves.springMotion()
          })
          .justifyContent(FlexAlign.Center)
          .width(120)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(42)
        .backgroundColor(Color.White)
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .height('100%')
    .width('100%')

  }

  onTabChange(index : number){
    if (this.panelState == PanelState.Preview) {
      this.translateX = (1 - index) * 40;
    }
    else {
      this.translateX = (index == 2) ?- 20 : 20
    }
    this.bottomTab = index

    if (this.bottomTab == BottomTab.Style) {
      EventBus.emitEvent(EventType.OnBeautyModeChange,{data:{'beautyMode': ''}})
    }
  }

}