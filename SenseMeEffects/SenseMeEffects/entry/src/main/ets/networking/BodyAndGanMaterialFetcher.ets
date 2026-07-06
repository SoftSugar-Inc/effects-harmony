import { image } from '@kit.ImageKit';

/**
 * BodyAndGan素材获取接口
 */
export abstract class BodyAndGanMaterialFetcher {
  /**
   * 任务类型: GAN去皱
   */
  static readonly TASK_TYPE_GAN_WRINKLE: string = 'GAN_WRINKLE';

  /**
   * 任务类型: 身体特效
   */
  static readonly TASK_TYPE_BODY_EFFECT: string = 'BODY_EFFECT';

  /**
   * 创建并查询任务
   * @param imageSource 图片ImageSource
   * @param taskType 任务类型
   * @param bodyEffectFlag 身体特效标志
   * @param inpaintSize 绘制尺寸
   * @returns Promise返回本地文件路径
   */
  abstract createAndQueryTask(
    imageSource: image.ImageSource,
    taskType: string,
    bodyEffectFlag: number,
    inpaintSize?: number
  ): Promise<string | null>;
}
