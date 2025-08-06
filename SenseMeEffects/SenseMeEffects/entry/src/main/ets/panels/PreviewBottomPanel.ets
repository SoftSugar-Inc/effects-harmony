import curves from '@ohos.curves'

@Component
export struct PreviewBottomPanel {
  onSnapshotClick?: () => void
  onRecorrOnClick?: () => void
  onRecorrOffClick?: () => void
  onStopRecorrOnClick?: () => void
  onEntranceClick?: (index: number) => void
  @State bRecording: boolean = false
  private timer: number = -1
  private maxTimeInterval: number = 10 /*s*/
  private stepTimeInterval: number = 100 /*ms*/
  @State progressValue: number = 0 /*s*/
  @State translateX: number = 0; // 组件二偏移量
  @State animate: boolean = false;
  type : number = 1
  textTimerController: TextTimerController = new TextTimerController();
  @State format: string = 'mm:ss';
  private recordCtr : boolean = false
  @State timerVisibility: Visibility = Visibility.Hidden
  @Prop @Watch('onPageInActive') isRecording : boolean = false

  build() {
    Column(){
      if (this.type) {
        TextTimer({ controller: this.textTimerController, isCountDown: false, count: 30000 })
          .format(this.format)
          .fontColor(Color.White)
          .fontSize(15)
          .visibility(this.timerVisibility)
      }
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
          ForEach(['homepage_photo', 'homepage_camera', 'homepage_video', 'homepage_video', 'homepage_video'], (item: string, index) => {
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
                }else if (index == 2 && this.onSnapshotClick !== undefined) {

                  Stack() {
                    Image(this.bRecording ? $r(`app.media.preview_recording`) : $r(`app.media.preview_snapshoot`))
                      .width('100%')
                      .aspectRatio(1)

                    Progress({ value: this.progressValue, type: ProgressType.Ring, total: this.maxTimeInterval })
                      .width('100%')
                      .aspectRatio(1)
                      .color(0xD492FF)
                      .visibility(this.bRecording ? Visibility.Visible : Visibility.Hidden)

                    Button()
                      .width('100%')
                      .backgroundColor(Color.Transparent)
                      .aspectRatio(1)// .onClick(this.onSnapshotClick)
                      .onClick(()=>{
                        if(this.bRecording){
                          this.recordCtr = !this.recordCtr
                          if (this.recordCtr) {
                            this.timerVisibility = Visibility.Visible
                            this.textTimerController.start()
                            if(this.onRecorrOnClick) this.onRecorrOnClick()
                          } else {
                            this.timerVisibility = Visibility.Hidden
                            this.textTimerController.reset()
                            if(this.onRecorrOffClick) this.onRecorrOffClick()
                          }
                        }else{
                          if(this.onSnapshotClick) this.onSnapshotClick()
                        }
                      })
                  }
                  .width('100%')
                  .aspectRatio(1)
                  .alignContent(Alignment.Top)

                  Blank()
                    .height(5)

                  if (this.type) {
                    Row({space:20}){
                      Text('拍摄')
                        .fontSize(15)
                        .fontColor(Color.Black)
                      Text('视频')
                        .fontSize(15)
                        .fontColor(Color.Black)
                    }
                    .width(80)
                    .translate({ x: this.translateX })
                    .onClick(() => {
                      animateTo({
                        duration:10000,
                        curve: curves.springMotion()
                      },()=>{
                        this.animate = !this.animate;
                        this.translateX = this.animate ? -30 : 30 ;
                        this.bRecording = this.animate ? true : false
                        if(this.onStopRecorrOnClick && !this.bRecording){
                          this.onStopRecorrOnClick()
                          this.timerVisibility = Visibility.Hidden
                          this.textTimerController.reset()
                        }
                      })
                    })
                    //.backgroundColor(Color.Red)
                  }
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
              .margin(10)
            }
          })
        }.width("100%")
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Transparent)
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  onPageInActive(): void {
    if (!this.isRecording) {
      this.recordCtr = false;
      this.timerVisibility = Visibility.Hidden
      this.textTimerController.reset()
    }
  }

}