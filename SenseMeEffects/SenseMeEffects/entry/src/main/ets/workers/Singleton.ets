// Singleton.ets
import { ArkTSUtils, collections } from '@kit.ArkTS';
import { sendableContextManager } from '@kit.AbilityKit';
// 声明当前模块为共享模块，只能导出可Sendable数据
'use shared'
@Sendable
export class Singleton {
  lock_: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock()
  private static instance: Singleton;

  private constructor() {
  }

  static getInstance(): Singleton {
    if (!Singleton.instance) {
      Singleton.instance = new Singleton()
    }
    return Singleton.instance;
  }

  public static flag:boolean =  false

  public static videoTimer:number = -1

  public context: sendableContextManager.SendableContext|null = null
}