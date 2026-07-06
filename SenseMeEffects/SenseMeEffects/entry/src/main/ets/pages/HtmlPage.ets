import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct HtmlPage {
  controller: webview.WebviewController = new webview.WebviewController();
  @State uri: string = (router.getParams() as Map<string, string>)['html']
  build() {
    Scroll(){
      Column({space: 50}) {
        Web({
          src: $rawfile(this.uri),
          controller: this.controller
        }).width('100%')
          .height('80%')
          .javaScriptAccess(true) // 启用JavaScript
        Image($r('app.media.ic_try_btn'))
          .size({width:120,height:40})
          .borderRadius(20)
          .onClick(()=>{
            this.routerPage("CameraPreview")
          })
      }
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  routerPage(pageName:string, param?:object|undefined){
    router.pushUrl({
      url: "pages/"+pageName, // 目标url
      params:param
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Invoke pushUrl succeeded.');
    });
  }
}
