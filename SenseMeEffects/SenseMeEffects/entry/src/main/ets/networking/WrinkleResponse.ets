/**
 * BodyAndGan接口响应实体类
 */
export class WrinkleResponse {
  code: number = -1;
  message: string = '';
  data: WrinkleData | null = null;
}

/**
 * 任务数据实体类
 */
export class WrinkleData {
  taskId: string = '';
  status: number = -1;
  resultUri: string = '';
  algoType: string = '';
  localPath: string = '';
}
