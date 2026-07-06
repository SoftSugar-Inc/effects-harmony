/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { camera } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import Logger from '../utils/Logger';
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import { fileIo } from '@kit.CoreFileKit';

const TAG: string = '[CameraModel]';

class CameraService {
  private cameraDevice: camera.CameraDevice | undefined = undefined;
  private capability: camera.CameraOutputCapability | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private receiver: image.ImageReceiver | undefined = undefined;
  private imageReceiverOutput: camera.PreviewOutput | undefined = undefined;
  private captureSession: camera.VideoSession | undefined = undefined;
  private sceneMode: camera.SceneMode | undefined = undefined;
  private previewProfile: camera.Profile | undefined = undefined;
  captureOutputDidOutputImage?: (image: image.Image) => void|undefined
  private isReleasing: boolean = false;  // 标记是否正在释放资源

  private context:Context|undefined = undefined


  private get cameraManager(): camera.CameraManager {
    return this._cameraManger()
  }

  private get cameraDevices(): Array<camera.CameraDevice> {
    return this._cameraDevices()
  }
  async initCamera(context:Context, cameraPosition: camera.CameraPosition, resolution: camera.Size): Promise<void> {
    // 重新初始化时重置标记
    this.isReleasing = false;
    this.context = context

    let cameraArray = this.cameraDevices
    for (let index = 0; index < cameraArray.length; index++) {
      let cameraDevice = cameraArray[index]
      if (cameraDevice.cameraPosition == cameraPosition) {
        this.cameraDevice = cameraDevice
        break
      }
    }
    if (!this.cameraDevice) {
      this.cameraDevice = cameraArray[0];
    }
    let sceneMode = this.cameraManager.getSupportedSceneModes(this.cameraDevice);
    sceneMode.forEach((value, index, sceneMode) => {
      console.log(TAG, `camera suppord sceneMode mode : ${value} index ${index}`)
    })
    this.sceneMode = sceneMode[1]

    this.capability = this.cameraManager.getSupportedOutputCapability(this.cameraDevice, this.sceneMode);
    let previewProfiles = this.capability.previewProfiles

    for (let i = 0; i < previewProfiles.length; i++) {
      const previewProfile = previewProfiles[i]
      if (previewProfile.size.width == resolution.width && previewProfile.size.height == resolution.height) {
        this.previewProfile = previewProfile
        break
      }
    }


    this.cameraInput = this.getCameraInput(this.cameraDevice, this.cameraManager) as camera.CameraInput;
    await this.cameraInput.open()
    // Photo output stream
    this.receiver = image.createImageReceiver(resolution, 4, 8);
    let imageReceiverId = await this.getImageReceiverSurfaceId(this.receiver)
    this.imageReceiverOutput = this.cameraManager.createPreviewOutput(this.previewProfile, imageReceiverId);
    this.receiver!.on('imageArrival', () => {
      // 检查是否正在释放,立即返回
      if (this.isReleasing) {
        return;
      }
      //Logger.info(TAG, 'imageArrival');
      this.receiver!.readNextImage((err: BusinessError, nextImage: image.Image) => {
        // 双重检查:异步回调执行时再次检查
        if (this.isReleasing) {
          if (nextImage) {
            nextImage.release();
          }
          return;
        }
        if (err || nextImage === undefined) {
          console.error('readNextImage failed');
          return;
        }
        if (this.captureOutputDidOutputImage !== undefined) {
          this.captureOutputDidOutputImage(nextImage)
        } else {

        }
      })
    })


    // Session Init
    this.captureSession = this.getCaptureSession(this.cameraManager) as camera.VideoSession;

    this.beginConfig(this.captureSession)
    this.startSession(this.captureSession, this.cameraInput)
  }



  beforeChange(): Promise<void> {
    return new Promise((exc, ero) => {
      this.receiver?.release().then(() => {
        this.captureSession?.release().then(() => {
          exc()
        }).catch((error: BusinessError) => {
          ero(error)
        })
      }).catch((error: BusinessError) => {
        ero(error)
      })
    })
  }

  stop() {
    // 停止时先标记为正在释放
    this.isReleasing = true;
    if (this.captureSession) {
      this.captureSession.stop();
    }
  }

  async releaseCamera(): Promise<void> {
    // 立即设置标记,阻止新的回调执行
    this.isReleasing = true;
    
    // 立即清空回调,防止后续调用
    this.captureOutputDidOutputImage = undefined;
    
    try {
      await this.imageReceiverOutput?.release();
      this.receiver!.off('imageArrival')
      await this.receiver?.release();
      await this.captureSession?.release();
      await this.cameraInput?.close();

    } catch (error) {
      let err = error as BusinessError;
      console.error(`releaseCamera fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.imageReceiverOutput = undefined;
      this.receiver = undefined;
      this.captureSession = undefined;
      this.cameraInput = undefined;
      this.captureOutputDidOutputImage = undefined;
    }
    console.info('releaseCamera success');
  }

  getCameraDevices(cameraManager: camera.CameraManager): Array<camera.CameraDevice> {
    let cameraArray: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    if (cameraArray != undefined && cameraArray.length > 0) {
      return cameraArray;
    } else {
      Logger.error(TAG, `getSupportedCameras faild`);
      return [];
    }
  }

  getCameraInput(cameraDevice: camera.CameraDevice, cameraManager: camera.CameraManager): camera.CameraInput | undefined {
    let cameraInput: camera.CameraInput | undefined = undefined;
    cameraInput = cameraManager.createCameraInput(cameraDevice);

    cameraInput.on('error', cameraDevice, (e) => {
      console.log(TAG, `create input error ${JSON.stringify(e)}`)
    });
    return cameraInput;
  }

  async getImageReceiverSurfaceId(receiver: image.ImageReceiver | undefined = undefined): Promise<string | undefined> {
    let photoSurfaceId: string | undefined = undefined;
    if (receiver !== undefined) {
      photoSurfaceId = await receiver.getReceivingSurfaceId();
      Logger.info(TAG, `getReceivingSurfaceId success`);
    }
    return photoSurfaceId;
  }

  getCaptureSession(cameraManager: camera.CameraManager): camera.Session | undefined {
    let captureSession: camera.Session | undefined = undefined;
    try {
      captureSession = cameraManager.createSession(this.sceneMode);
    } catch (error) {
      Logger.error(TAG, `Failed to create the CaptureSession instance. error: ${JSON.stringify(error as BusinessError)}`);
    }
    return captureSession;
  }

  beginConfig(captureSession: camera.Session): void {
    try {
      captureSession.beginConfig();
    } catch (error) {
      Logger.error(TAG, `Failed to beginConfig. error: ${JSON.stringify(error as BusinessError)}`);
    }
  }

  async startSession(captureSession: camera.VideoSession, cameraInput: camera.CameraInput | undefined): Promise<void> {
    captureSession.addInput(cameraInput)

    captureSession.addOutput(this.imageReceiverOutput)
    await captureSession.commitConfig()

    // 设置视频防抖
    if (this.setVideoStabilizationMode(captureSession)) {
      // 设置色彩空间
      this.setColorSpaceBeforeCommitConfig(captureSession, 0);
    }

    await captureSession.start()
  }

  // 查询是否支持视频防抖。HDR录像需要支持视频防抖。
  isVideoStabilizationModeSupported(session: camera.VideoSession, mode: camera.VideoStabilizationMode): boolean {
  let isSupported: boolean = false;
  try {
    isSupported = session.isVideoStabilizationModeSupported(mode);
  } catch (error) {
    // 失败返回错误码error.code并处理
    let err = error as BusinessError;
    Logger.error(`The isVideoStabilizationModeSupported call failed. error code: ${err.code}`);
  }
  return isSupported;
}

  // 设置视频防抖。
  setVideoStabilizationMode(session: camera.VideoSession): boolean {
  let mode: camera.VideoStabilizationMode = camera.VideoStabilizationMode.AUTO;
  // 查询是否支持视频防抖
  let isSupported: boolean = this.isVideoStabilizationModeSupported(session, mode);
  if (isSupported) {
    Logger.info(TAG, `setVideoStabilizationMode: ${mode}`);
    // 设置视频防抖
    session.setVideoStabilizationMode(mode);
    let activeVideoStabilizationMode = session.getActiveVideoStabilizationMode();
    Logger.info(TAG, `activeVideoStabilizationMode: ${activeVideoStabilizationMode}`);
  } else {
    Logger.info(TAG, `videoStabilizationMode: ${mode} is not support`);
  }
  return isSupported;
}

  // 查询支持的色彩空间。
  getSupportedColorSpaces(session: camera.VideoSession): colorSpaceManager.ColorSpace[] {
  let colorSpaces: colorSpaceManager.ColorSpace[] = [];
  try {
    colorSpaces = session.getSupportedColorSpaces();
  } catch (error) {
    let err = error as BusinessError;
    Logger.error(TAG, `The getSupportedColorSpaces call failed. error code: ${err.code}`);
  }
  return colorSpaces;
}

  // 设置色彩空间。
  setColorSpaceBeforeCommitConfig(session: camera.VideoSession, isHdr: number): void {
  let colorSpace: colorSpaceManager.ColorSpace =
    isHdr ? colorSpaceManager.ColorSpace.BT2020_HLG_LIMIT : colorSpaceManager.ColorSpace.BT709_LIMIT;
  let colorSpaces: colorSpaceManager.ColorSpace[] = this.getSupportedColorSpaces(session);
  let isSupportedColorSpaces = colorSpaces.indexOf(colorSpace) >= 0;
  if (isSupportedColorSpaces) {
    Logger.info(TAG, `setColorSpace: ${colorSpace}`);
    session.setColorSpace(colorSpace);
    let activeColorSpace: colorSpaceManager.ColorSpace = session.getActiveColorSpace();
    Logger.info(TAG, `activeColorSpace: ${activeColorSpace}`);
  } else {
    Logger.info(TAG, `colorSpace: ${colorSpace} is not support`);
  }
}

  private _cameraManger = (() => {
    let manager: camera.CameraManager
    return () => {
      if (!manager) {
        manager = camera.getCameraManager(this.context)
      }
      return manager
    }
  })()
  private _cameraDevices = (() => {
    let devices: Array<camera.CameraDevice>
    return () => {
      if (!devices) {
        devices = this.cameraManager.getSupportedCameras()
      }
      return devices
    }
  })()

}

export default new CameraService()