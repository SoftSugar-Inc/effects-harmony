import { BeautyPanel } from '../panels/BeautyPanel'

@Entry
@Component
struct DevPage {
  build() {
    Column() {
      BeautyPanel()
        .borderWidth(1)
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {

  }
}