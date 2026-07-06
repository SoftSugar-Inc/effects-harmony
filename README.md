# SenseAR Effects特效引擎Harmony SDK集成Demo

SDK名称：SenseAR Effects 特效引擎 SDK - Harmony  
SDK功能介绍：本项目是商汤科技提供的[特效引擎 SDK](https://sensear.softsugar.com/) Harmony 集成演示工程，旨在帮助开发者快速了解如何在 Harmony 项目中集成与使用我们的特效引擎 SDK。您可以通过运行本 Demo，直观体验 SDK 提供的各类人脸特效、贴纸、美颜、滤镜等功能。  
SDK包名：@softsugar/mars_effects  
版本号：v9.9.0  
隐私政策：[SenseAR Effects SDK隐私政策](https://effectsstudio-manual.softsugar.com/questions6/)  
合规使用说明：开发者应在遵守适用法律法规、隐私政策及商汤科技相关授权协议的前提下集成和使用本 SDK，并在业务场景中依法履行用户告知、授权同意、个人信息保护等合规义务。  
har包的MD5值：13506993a88b8b12e91fc15d486c6431  
开发者：商汤科技

---

## 功能亮点

- 人脸检测与跟踪
- 美颜效果（磨皮、美白、瘦脸等）
- AR 贴纸/道具实时叠加
- 实时滤镜效果
- 视频流处理与渲染
- 高性能渲染支持（基于 OpenGL ES）

---

## 环境要求

- DevEco Studio 5.0 及以上
- OpenHarmony api12 及以上
- 真机运行（部分功能依赖相机）

---

## 运行Demo

- clone工程到本地
- 将从商汤商务渠道获取的license文件放入工程（路径为"resources/rawfile/license/license.lic"）
- 将工程的Bundle Identifier修改为与上述license绑定的Bundle Identifier
- 完成工程编译及App在测试机的安装，运行Demo

> 请[**提交免费试用申请**](https://sensear.softsugar.com/)，或**联系商务**（Tel: 181-1640-5190）获取测试license。

---

## SDK 集成说明

本项目已经完成对SDK的集成，您无需单独引入SDK依赖。

如果您需要在自己的项目中引入SDK，请参考如下步骤：

1. 导入SDK
   参照Harmony工程构建native模板，在entry/src放入sdk的cpp文件夹

2. 导入检测模型与素材文件
   一般放至rawfile目录下，程序初始化时先通过鸿蒙 resourceManager读取，再拷贝至app沙盒目录下，sdk通过沙盒路径加载检测模型

3. 修改构建配置
   
   在build-profiles.json5中添加以下字段
   
   ```json
   "buildOption": {
       "externalNativeOptions": {
       "path": "./src/main/cpp/CMakeLists.txt",
       "arguments": "",
       "cppFlags": ""
       }
   }
   ```

4. 添加so库依赖
   在0h-package.json5中添加以下字段
   
   ```json
   "dependencies": {
       "libentry.so": "file:./src/main/cpp/types/libentry"
   },
   ```

5. 添加Xcomponent组件
   
   sdk内部会将画面渲染到Xcomponent组件上，ArkTS只需构建布局，参考如下:
   
   ```ts
   build(){
      Stack(){
       XComponent({
           id: Common.XCOMPONENT_ID,
           type: XComponentType.TEXTURE,
           libraryname: Common.LIBRARY_NAME,
       })
       .onLoad(()=>{
       this.onXcomponentLoad()
       })
       .width('100%')
       .aspectRatio(this.photoAspectRatio)
      }
   }
   ```
   
   注意事项：XComponent的libraryname需要与前边构建的sdk so库一致，默认值为entry(libentry.so)

> [详细接入文档](./SenseMeEffects/st_mobile_sdk/docs/SenseAR集成文档.md)

---

## 反馈

- 如果您在使用过程中有遇到什么问题，欢迎提交 [**issue**](https://github.com/SoftSugar-Inc/effects-harmony/issues)。
- 我们真诚地感谢您的贡献，欢迎通过 GitHub 的 fork 和 pull request 流程来提交代码。代码风格请参考[**Introduction to ArkTS**]([文档中心](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/introduction-to-arkts))
