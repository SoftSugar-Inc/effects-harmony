import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import libstmobile from '@softsugar/mars_effects';
import { promptAction } from '@kit.ArkUI'
import { connection } from '@kit.NetworkKit'

import { STMaterialManager } from '../models/STMaterialManager'
import { HomeGrid, HomeType, STDefines } from '../common/STDefines';
import { common } from '@kit.AbilityKit';
import STLicense from '../utils/STLicense';
import { JSON, util } from '@kit.ArkTS';
import DBManager from '../models/DBJson/DBManager';
import { LoadingView } from '../utils/LoadingView';
import PermissionManager from '../utils/Permission';

const context = getContext(this) as common.UIAbilityContext;
const filesDir = context.filesDir
const resourceManager = context.resourceManager

@Entry
@Component
struct Index {
  private controller: SwiperController = new SwiperController();
  private result = false;
  @State bannerImgUri: string[] = []
  @State bannerHtmlUri: string[] = []

  loadingView: LoadingView = new LoadingView();

  //相当于iOS中的viewDidLoad只加载一次
  aboutToAppear(): void {
    let decoder = new util.StringDecoder('utf-8')
    const homeContent = resourceManager.getRawFileContentSync('home/home.json')
    const homeText = decoder.write(homeContent)
    let homeGrids = JSON.parse(homeText) as HomeGrid[]

    STDefines.homeGrids = homeGrids

    this.bannerInit()
    this.checkLic()
  }

  async checkLic(){
    const configContent = resourceManager.getRawFileContentSync('config.json')
    let decoder = new util.StringDecoder('utf-8')
    const configTxt = decoder.write(configContent)
    let config = JSON.parse(configTxt) as object
    if (config["license"]){
      const fileContent = resourceManager.getRawFileContentSync((config["license"]))
      this.result = libstmobile.checkLicenseByBuffer(fileContent.buffer.slice(0))
    }else {
      const licPath = filesDir+"/senseme.lic"
      await STLicense.GetLicenseOnLine(licPath,config["appID"],config["appKey"])
      this.result =  libstmobile.checkLicenseByPath(licPath)
      if (!this.result) {
        promptAction.showDialog({
          message: `网络错误: 无法校验license,demo不可用`,
          offset:{dx:0,dy:200}
        })
        return
      }
    }
    if (!this.result) {
      promptAction.showToast({
        message: `check license error ${this.result}`,
        duration: 2000
      })
      return
    }
    setTimeout(async ()=>{
      await this.GetGroupList()
      if (!DBManager.Instance().getUserInfo()) {
        this.routerPage("ScanFacePage")
      }
      else {
        let user = DBManager.Instance().getUserInfo()
      }
    },500)

  }
  async GetGroupList(){
    try {
      this.loadingView.showLoading({ msg: '加载中...', isModal: true });
      let manager = STMaterialManager.GetInstance()
      await manager.GetGroupList()
      this.loadingView.hide()
    }
    catch (e){
      this.loadingView.hide()
    }

  }



  async routerPage(pageName:string, param?:object|undefined){
    try {
      let hasNet = this.judgeHasNet()
      console.info(`[NetworkCheck] hasDefaultNet = ${hasNet}`)
      if (!hasNet) {
        promptAction.showToast({
          message: `当前无网络连接，请检查网络设置`,
          duration: 3000
        })
        return
      }
    } catch (err) {
      console.error(`[NetworkCheck] hasDefaultNet error: ${JSON.stringify(err)}`)
      promptAction.showToast({
        message: `网络检测异常，请检查网络设置`,
        duration: 3000
      })
      return
    }

    let permission = await PermissionManager.requestAllPermissions()

    if (!permission) {
      promptAction.showToast({
        message: `请先在设置里打开相关相机、相册等权限`,
        duration: 2000
      })
      return
    }

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

  aboutToDisappear(){
    console.info(`aboutToDisappear`)
  }

  //viewDidAppear
  onPageShow(): void {
    console.info(`onPageShow`)
    globalThis.homeParam = undefined
  }

  //viewDidDisappear
  onPageHide(): void {
    console.info(`onPageHide`)
  }

  bannerInit(){
    const bannerDir = resourceManager.getRawFileListSync(`html`)
    this.bannerImgUri = new Array()
    this.bannerHtmlUri = new Array()
    for (let i = 0; i< bannerDir.length;i++){
      let dirName = bannerDir[i]
      let files = resourceManager.getRawFileListSync(`html/`+ dirName)
      files.forEach(file=>{
        if (file.startsWith('Banner')) {
          this.bannerImgUri[i] = `html/${dirName}/${file}`
        }
        else if(file.endsWith('html')){
          this.bannerHtmlUri[i] = `html/${dirName}/${file}`
        }
      })
    }
  }
  onBannerClick(index : number){
    let homeType = 0
    let homeIndex = 0
    switch (index)
    {
      case 0:
        homeType = HomeType.Beauty
        homeIndex  = 3
        break
      case 1: homeType = HomeType.Style
        break
      case 2: homeType = HomeType.Filter
        break
      //2d微整形
      case 3:
        homeType = HomeType.Beauty
        homeIndex  = 2
        break
    }
    globalThis.homeParam = { type: homeType, index: homeIndex}
    this.routerPage("HtmlPage", Object({html : this.bannerHtmlUri[index]}))
  }


  build() {
    Column() {

      Swiper(this.controller) {
        ForEach(this.bannerImgUri, (item: string, index) => {
          Image($rawfile(item))
            .width('100%')
            .height('100%')
            .onClick(()=>{
              this.onBannerClick(index)
            })
        })
      }
      .backgroundColor(Color.White)
      .width('100%')
      .aspectRatio(4 / 3)

      GridRow({
        columns: 4,
        gutter: { x: 10, y: 10 },
        breakpoints: {
          value: ["400vp", "600vp", "800vp"],
          reference: BreakpointsReference.WindowSize
        },
        direction: GridRowDirection.Row
      }) {
        ForEach(STDefines.homeGrids, (grid: HomeGrid, index :number) => {
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
              Image($r(`app.media.${grid.icon}`))
                .width('80%')
                .aspectRatio(1)
              Text(grid.name)
                .margin({ top: 5 })
                .fontSize(12)
            }
            .width("100%")
            .justifyContent(FlexAlign.Center)
            .margin(10)
            .onClick(() => {
              if (!this.result) {
                promptAction.showToast({
                  message: `check license error ${this.result}`,
                  duration: 2000
                })
              } else {
                if (index < HomeType.All){
                  globalThis.homeParam = { type: index, index: grid.routerIndex}
                  this.routerPage("CameraPreview")
                }else {
                  this.routerPage("HomeAll")
                }
              }
            })
          }
        })
      }.width("90%")

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
                    .onClick(() => {
                      if (!this.result) {
                        promptAction.showToast({
                          message: `check license error ${this.result}`,
                          duration: 2000
                        })
                      } else {
                        this.routerPage("CameraPreview", Object({mode : "", index: HomeType.All }))
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
      this.routerPage( type == 0 ? 'Photo' : 'Video', Object({
        uri: uri
      }))
    }
  }

  judgeHasNet(): boolean {
    try { // Get current network connection
      let netHandle = connection.getDefaultNetSync();

      // 0-100 Reserved connections for the system
      if (!netHandle || netHandle.netId < 100) {
        return false;
      }

      // Get the properties of the connection
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let cap = netCapability.networkCap;
      if (!cap) {
        return false;
      }

      for (let em of cap) {
        if (connection.NetCap.NET_CAPABILITY_VALIDATED === em) {
          return true;
        }
      }
    } catch (e) {
      let err = e as BusinessError;
      console.info('get netInfo error ：' + JSON.stringify(err));
    }
    return false;
  }
}

