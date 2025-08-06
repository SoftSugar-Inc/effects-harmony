import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import libstmobile from 'libentry.so';
import { promptAction } from '@kit.ArkUI'
import BeautyResourceManager from '../models/Beauty/BeautyResourceManager';
import {
  XTHUDLoading,
  XTHUDManager
} from '@jxt/xt_hud'
import { STMaterialManager } from '../models/STMaterialManager'
import { STDefines } from '../common/STDefines';


@Entry
@Component
struct Index {
  private controller: SwiperController = new SwiperController();
  private result = false;
  @State btnEnable : boolean = true

  //相当于iOS中的viewDidLoad只加载一次
  aboutToAppear(): void {
    //this.mhm_test()
    let context = getContext()
    let resourceManager = context.resourceManager
    let licenseContent = resourceManager.getRawFileContentSync('license/license.lic')
    const buffer = licenseContent.buffer.slice(0);
    this.result = libstmobile.checkLicenseByBuffer(buffer)
    if (!this.result) {
      promptAction.showToast({
        message: `check license error ${this.result}`,
        duration: 2000
      })
    }else{
      setTimeout(() => {
        this.GetGroupList()
      }, 500)
    }
  }

  async GetGroupList(){
    XTHUDManager.showLoading('加载中...')
    let manager = STMaterialManager.GetInstance()
    await manager.GetGroupList()
    XTHUDManager.hideLoading()
  }

  aboutToDisappear(){
    console.info(`aboutToDisappear`)
  }

  //viewDidAppear
  onPageShow(): void {
    console.info(`onPageShow`)
  }

  //viewDidDisappear
  onPageHide(): void {
    console.info(`onPageHide`)
    this.btnEnable = true
  }


  build() {
    Column() {
      //add loading
      XTHUDLoading()

      Swiper(this.controller) {
        ForEach(['app.media.harmony_filter'], (item: string, index) => {
          Image($r(item))
            .width('100%')
            .height('100%')
        })
      }
      .backgroundColor(Color.White)
      .width('100%')
      .aspectRatio(4 / 3)

      GridRow({
        columns: 4,
        gutter: { x: 5, y: 10 },
        breakpoints: {
          value: ["400vp", "600vp", "800vp"],
          reference: BreakpointsReference.WindowSize
        },
        direction: GridRowDirection.Row
      }) {
        ForEach(STDefines.effectStringResource, (item: string) => {
          GridCol({
            span: {
              xs: 1,
              sm: 2,
              md: 3,
              lg: 4
            },
            offset: 0,
            order: 0
          }) {
            Column() {
              Image($r(`app.media.${item}`))
                .width('80%')
                .aspectRatio(1)
              Text($r(`app.string.${item}`))
                .margin({ top: 5 })
            }
            .width("100%")
            .justifyContent(FlexAlign.Center)
            .margin(10)
            .enabled(this.btnEnable)
            .onClick(() => {
              this.btnEnable = false
              if (!this.result) {
                promptAction.showToast({
                  message: `check license error ${this.result}`,
                  duration: 2000
                })
              } else {
                router.pushUrl({
                  url: "pages/CameraPreview", // 目标url
                  params : { mode: item }
                }, router.RouterMode.Standard, (err) => {
                  if (err) {
                    console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                    return;
                  }
                  console.info('Invoke pushUrl succeeded.');
                });
              }
            })
          }
        })
      }.width("100%")

      Blank()

      Row() {
        GridRow({
          columns: 3,
          gutter: { x: 5, y: 10 },
          breakpoints: {
            value: ["400vp", "600vp", "800vp"],
            reference: BreakpointsReference.WindowSize
          },
          direction: GridRowDirection.Row
        }) {
          ForEach(['homepage_photo', 'homepage_camera', 'homepage_video'], (item: string, index) => {
            GridCol({
              span: {
                xs: 1,
                sm: 2,
                md: 3,
                lg: 4
              },
              offset: 0,
              order: 0
            }) {
              Column() {
                if (index == 1) {
                  Image($r(`app.media.${item}`))
                    .width('80%')
                    .aspectRatio(1)
                    .enabled(this.btnEnable)
                    .onClick(() => {
                      this.btnEnable = false
                      if (!this.result) {
                        promptAction.showToast({
                          message: `check license error ${this.result}`,
                          duration: 2000
                        })
                      } else {
                        router.pushUrl({
                          url: "pages/CameraPreview", // 目标url
                          params : {mode : ""}
                        }, router.RouterMode.Standard, (err) => {
                          if (err) {
                            console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                            return;
                          }
                          console.info('Invoke pushUrl succeeded.');
                        });
                      }
                    })
                } else {
                  Row() {
                    Image($r(`app.media.${item}`))
                      .width('40%')
                      .aspectRatio(1)
                      .onClick(() => {
                        if (!this.result) {
                          promptAction.showToast({
                            message: `check license error ${this.result}`,
                            duration: 2000
                          })
                        } else {
                          this.callFilePickerSelectImage(index)
                        }
                      })
                  }
                  .width('80%')
                  .aspectRatio(1)
                  .justifyContent(FlexAlign.Center)
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
      Column(){
        Text($r('app.string.version'))
      }
    }
    .width('100%')
    .height('100%')
  }


  /**
   * 拉起picker选择图片/视频
   */
  async callFilePickerSelectImage(type: number): Promise<void> { // async 用于申明一个 function 是异步的
    let array: string[];
    try {
      // 设置photoPicker的参数
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType =
        type == 0 ? picker.PhotoViewMIMETypes.IMAGE_TYPE : picker.PhotoViewMIMETypes.VIDEO_TYPE // 过滤选择媒体文件类型
      PhotoSelectOptions.maxSelectNumber = 1; // 选择媒体文件的最大数目
      let mediaFlag = false;
      let photoPicker = new picker.PhotoViewPicker(); // 使用图库选择器对象前，需要先创建PhotoViewPicker实例
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        if (PhotoSelectResult !== null && PhotoSelectResult !==
          undefined) { // 接口采用callback异步返回形式，返回PhotoSelectResult对象，故进行下一步操作前要先判断是否已经成功返回PhotoSelectResult对象了

          // PhotoSelectResult为返回的结果集。
          // 其中包含Array<string>类型的photoUris，为返回图库选择后的媒体文件的uri数组；还包含boolean类型的isOriginalPhoto，指示返回图库选择后的媒体文件是否为原图。
          // 声明变量array，其取值为PhotoSelectResult中的数组。
          array = PhotoSelectResult['photoUris'];
          array.forEach((value) => {
            mediaFlag = true;
            console.log(`select image/video uri: ${value}}`)
          })
        }
        if (mediaFlag) {
          this.gotoMediaPage(array[0], type);
        }
      })
        .catch((err: BusinessError) => {
          console.log('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
        });
    } catch (err) {
      console.log('PhotoViewPicker failed with err: ' + err);
    }
  }

  async gotoMediaPage(uri: string, type: number) {
    if (!this.result) {
      promptAction.showToast({
        message: `check license error ${this.result}`,
        duration: 2000
      })
    } else {
      router.pushUrl({
        url: type == 0 ? 'pages/Photo' : 'pages/Video',
        params: {
          uri: uri
        }
      }, router.RouterMode.Standard);
    }
  }


}

