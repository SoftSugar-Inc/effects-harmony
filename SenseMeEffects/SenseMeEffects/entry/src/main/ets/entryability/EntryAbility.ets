import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { sensor } from '@kit.SensorServiceKit';
import { RotateType } from 'libentry.so';


export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    sensor.on(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
      let degree: number = -1;
      degree = this.CalDegree(data.x, data.y, data.z); // 计算角度的函数
      if (degree >= 0 && (degree <= 30 || degree >= 330)) {
        globalThis.deviceRotate =  RotateType.ROTATE_270;
      } else if (degree >= 60 && degree <= 120) {
        globalThis.deviceRotate =  RotateType.ROTATE_180;
      } else if (degree >= 150 && degree <= 210) {
        globalThis.deviceRotate =  RotateType.ROTATE_90;
      } else if (degree >= 240 && degree <= 300) {
        globalThis.deviceRotate = RotateType.ROTATE_0;
      }
    });
  }
  CalDegree(x: number, y: number, z: number): number {
    let degree: number = -1;
    // 3 为有效增量角度阈值系数
    if ((x * x + y * y) * 3 < z * z) {
      return degree;
    }
    degree = 90 - (Math.atan2(y, -x) * 180 / Math.PI);
    return degree >= 0 ? degree % 360 : degree % 360 + 360;
  }


  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    })
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }


};
