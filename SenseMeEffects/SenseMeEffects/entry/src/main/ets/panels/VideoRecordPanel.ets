import { Singleton } from "../workers/Singleton"

@Component
export struct VideoRecordPanel{

  @State isRecording:boolean = false

  onRecordStopClick?: () => void
  onRecordSaveClick?: () => void
  onRecordDeleteClick?: () => void

  private maxTimeInterval: number = 10 /*s*/
  @State progressValue: number = 0 /*ms*/
  @State translateX: number = 0// 组件二偏移量
  @State animate: boolean = false;
  textTimerController: TextTimerController = new TextTimerController();
  @State format: string = 'ss:SS';
  private gradientColor: LinearGradient = new LinearGradient([{ color:"#D492FF", offset: 0 },
    { color: Color.Orange, offset: 1.0 }])

  aboutToAppear(): void {
    this.isRecording = true
    this.textTimerController.reset()
    Singleton.videoTimer = -1
    setTimeout(()=>{
      this.textTimerController.start()
    },300)
  }

  onStopRecord(){
    this.isRecording = false
    this.textTimerController.pause()
    if(this.onRecordStopClick) this.onRecordStopClick()
  }

  build() {
    Column(){
      Row({space:40}){
        if (!this.isRecording){
          Column({space:5}){
            Image($r('app.media.ic_camera_delete')).width(40)
            Text('回删').fontColor(Color.White).fontSize(14)
          }
          .width(40)
          .height(60)
          .onClick(()=>{
            this.onRecordDeleteClick?.()
          })
        }
        Column({space:10}){
          Stack() {
            Progress({ value: this.progressValue, type: ProgressType.Ring, total: this.maxTimeInterval * 100})
              .width('100%')
              .aspectRatio(1)
              .color(this.gradientColor)
              .style({ strokeWidth: 5 })
              .backgroundColor(Color.White)

            Image($r(this.isRecording? `app.media.ic_recording_re`:`app.media.ic_after_recording`))
              .onClick(()=>{
                if (this.isRecording) {
                  this.onStopRecord()
                }
              })
              .width(60)
              .aspectRatio(1)
              .padding(10)
          }
          TextTimer({ controller: this.textTimerController, isCountDown: false})
            .format(this.format)
            .fontColor(Color.Black)
            .fontSize(20)
            .onTimer((utc: number, elapsedTime: number) => {
              Singleton.videoTimer = elapsedTime*1000*10
              this.progressValue = elapsedTime
              if (elapsedTime/100 > this.maxTimeInterval) {
                this.onStopRecord()
              }
            })
        }
        .width(80)
        .height(80)
        if (!this.isRecording){
          Column({space:5}){
            Image($r('app.media.ic_camera_ok')).width(40)
            Text('确认').fontColor(Color.White).fontSize(14)
          }
          .width(40)
          .height(60)
          .onClick(()=>{
            this.onRecordSaveClick?.()
          })
        }
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(100)
      .padding({bottom : 100})
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
  }
}