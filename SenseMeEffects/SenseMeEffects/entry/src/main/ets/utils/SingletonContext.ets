// 共享模块sharedModule.ets
import { sendableContextManager } from '@kit.AbilityKit';
// 声明当前模块为共享模块，只能导出可Sendable数据
'use shared'

// 共享模块，SingletonA全局唯一
@Sendable
class SingletonContext {
  private sendableContext: sendableContextManager.SendableContext =
    sendableContextManager.convertFromContext(getContext());

  // 返回sendableContext对象
  public getContext() {
    return this.sendableContext
  }

  public isReleased:boolean = false
}

export let singletonContext = new SingletonContext();