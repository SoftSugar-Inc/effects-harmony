import { BeautyPanel } from '../panels/BeautyPanel'
import { router } from '@kit.ArkUI';
import { HomeGrid, HomeItem, HomeType, STDefines } from '../common/STDefines';

@Entry
@Component
struct HomeAll {

  private onSelect(typeIndex:number, selectIndex:number){
    globalThis.homeParam = { type: typeIndex, index: selectIndex}
    router.pushUrl({
      url: "pages/CameraPreview", // 目标url
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Invoke pushUrl succeeded.');
    });
  }

  build() {
    Column() {
      Stack(){
        Text("全部效果"){
        }
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .width('100%')
        Image($r('app.media.ic_back'))
          .focusable(true)
          .focusOnTouch(true)
          .width(25)
          .height(25)
          .position({left:10, top:12.5})
          .onClick(() => {
            router.back();
          })
      }
      .height(50)
      .width('100%')
      Scroll(){
        List({space:5}){
          ForEach(STDefines.homeGrids,(grid:HomeGrid, index:number)=>{
            if (grid.items.length > 0){
              ListItem(){
                Column(){
                  Row(){
                    Row()
                      .margin({left:10})
                      .width(4)
                      .height('100%')
                      .backgroundColor(grid.color)
                    Text(grid.name)
                      .fontSize(14)
                      .fontColor(Color.Black)
                      .margin({left:5})
                  }
                  .width('100%')
                  .height(30)
                  GridRow({
                    columns: 5,
                    breakpoints: {
                      value: ["400vp", "600vp", "800vp"],
                      reference: BreakpointsReference.WindowSize
                    },
                    direction: GridRowDirection.Row,
                    gutter: { x: 10, y: 10 }}){
                    ForEach(grid.items,(item: HomeItem, itemIndex:number)=>{
                      GridCol(){
                        Column({space:5}){
                          Image($r(`app.media.${item.icon}`))
                          Text(item.name)
                            .fontSize(12)
                            .fontColor(Color.Black)
                        }
                        .onClick(()=>{
                          this.onSelect(grid.type, item.index)
                        })
                        .width('100%')
                      }
                    })
                  }
                  .width('90%')
                  .margin({top:10,bottom:10})
                }
              }
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .padding({bottom:50})
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {

  }
}