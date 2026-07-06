import http from '@ohos.net.http';
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { STCrypto } from '../common/STCrypto';
import { WrinkleResponse, WrinkleData } from './WrinkleResponse';
import { BodyAndGanMaterialFetcher } from './BodyAndGanMaterialFetcher';

const TAG: string = 'BodyAndGanMaterial';

/**
 * BodyAndGan素材获取实现类
 * 参考Android版本BodyAndGanMaterialFetcherImpl改造
 */
export class BodyAndGanMaterialFetcherImpl extends BodyAndGanMaterialFetcher {
  private static readonly TEST_BASE_URL: string = 'https://aigc-test.softsugar.com/api/effects/bodyandgan';
  private static readonly PROD_BASE_URL: string = 'https://aigc.softsugar.com/api/effects/bodyandgan';
  private static readonly TEST_TOKEN_URL: string = 'https://aigc-test.softsugar.com/api/uc/v1/access/api/token';
  private static readonly PROD_TOKEN_URL: string = 'https://aigc.softsugar.com/api/uc/v1/access/api/token';

  private static readonly CONNECT_TIMEOUT: number = 120000; // 120秒
  private static readonly READ_TIMEOUT: number = 120000;
  private static readonly WRITE_TIMEOUT: number = 120000;

  private static readonly APP_ID: string = 'b268e561e6d54ed592cdf3842304ee24';
  private static readonly APP_KEY: string = 'c4546ebf66e14eed95214dc14e0d1837';
  private static readonly GRANT_TYPE: string = 'sign';
  private static readonly FUNCTION: string = 'wrinkle';
  private static readonly PARAMS_SCHEMA_VERSION: number = 1;

  private cachedToken: string | null = null;
  private cachedTokenAtMs: number = 0;

  constructor() {
    super();
  }

  /**
   * 创建并查询任务
   */
  async createAndQueryTask(
    imageSource: image.ImageSource,
    taskType: string,
    bodyEffectFlag: number,
    inpaintSize?: number
  ): Promise<string | null> {
    const taskStartTime = Date.now();
    console.info(TAG, `开始执行, taskType=${taskType}`);
    
    try {
      if (!imageSource) {
        throw new Error('ImageSource cannot be null');
      }

      const base64Image = await this.encodeImageSourceToBase64(imageSource);
      const requestParamsJson = await this.createRequestParamsJson(base64Image, taskType, bodyEffectFlag, inpaintSize);
      const requestJson = this.createTaskCreateRequestJson(requestParamsJson, taskType);

      const token = await this.fetchToken();
      if (!token) {
        throw new Error('token获取失败');
      }

      const createResp = await this.createTask(requestJson, token);
      const taskId = createResp.data?.taskId;
      if (!taskId || taskId.trim().length === 0) {
        throw new Error('创建任务成功但未返回taskId');
      }
      console.info(TAG, `任务创建成功, taskId=${taskId}`);

      const queryResp = await this.pollQueryTask(taskId, token);
      if (queryResp && queryResp.data && queryResp.data.resultUri && queryResp.data.resultUri.trim().length > 0) {
        const localPath = await this.downloadToLocal(queryResp.data.resultUri);
        console.info(TAG, `任务完成, 总耗时=${Date.now() - taskStartTime}ms, uri=${queryResp.data.resultUri}, localPath=${localPath}`);
        return localPath;
      }

      return null;
    } catch (err) {
      console.error(TAG, `任务失败, 耗时=${Date.now() - taskStartTime}ms, error=${err}`);
      const errorMsg = (err instanceof Error && err.message.includes('token'))
        ? 'token获取失败'
        : '请求失败';
      promptAction.showToast({ message: errorMsg });
      return null;
    }
  }

  /**
   * 轮询查询任务状态
   */
  private async pollQueryTask(taskId: string, token: string): Promise<WrinkleResponse> {
    const timeout = 120000; // 120秒超时
    const interval = 500; // 500ms轮询间隔
    const startTime = Date.now();
    
    while (Date.now() - startTime < timeout) {
      const queryResp = await this.queryTask(taskId, token);
      const status = queryResp.data?.status ?? -1;

      if (status === 5) {
        console.info(TAG, `轮询完成, 耗时=${Date.now() - startTime}ms`);
        return queryResp;
      }
      if (status === 3) {
        throw new Error('任务已取消');
      }
      if (status === 9) {
        throw new Error('任务异常');
      }

      await this.sleep(interval);
    }

    console.error(TAG, `轮询超时, taskId=${taskId}`);
    throw new Error('查询任务超时（超过120秒）');
  }

  /**
   * 查询任务状态
   */
  async queryTask(taskId: string, token: string): Promise<WrinkleResponse> {
    if (!taskId || taskId.trim().length === 0) {
      throw new Error('taskId cannot be null or empty');
    }

    const baseUrl = BodyAndGanMaterialFetcherImpl.TEST_BASE_URL;
    const url = `${baseUrl}/v1/tasks/${taskId}?token=${encodeURIComponent(token)}`;

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: BodyAndGanMaterialFetcherImpl.CONNECT_TIMEOUT,
        readTimeout: BodyAndGanMaterialFetcherImpl.READ_TIMEOUT
      });

      if (response.responseCode !== 200) {
        throw new Error(`Query task failed: ${response.responseCode}`);
      }

      const respStr = response.result as string;
      const json = JSON.parse(respStr) as Record<string, Object>;

      const wrinkleResponse = new WrinkleResponse();
      wrinkleResponse.code = json['code'] as number ?? -1;
      wrinkleResponse.message = json['message'] as string ?? '';

      const dataObj = json['data'] as Record<string, Object> | undefined;
      if (dataObj) {
        const data = new WrinkleData();
        data.taskId = dataObj['taskId'] as string ?? '';
        data.status = dataObj['status'] as number ?? -1;
        data.resultUri = dataObj['resultUri'] as string ?? '';
        data.algoType = dataObj['algoType'] as string ?? '';
        wrinkleResponse.data = data;
      }

      if (wrinkleResponse.code !== 0) {
        throw new Error(wrinkleResponse.message || '任务查询失败');
      }

      return wrinkleResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 创建任务
   */
  private async createTask(requestJson: Record<string, Object>, token: string): Promise<WrinkleResponse> {
    const baseUrl = BodyAndGanMaterialFetcherImpl.TEST_BASE_URL;
    const url = `${baseUrl}/v1/tasks?token=${encodeURIComponent(token)}`;

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json; charset=utf-8'
        },
        extraData: requestJson,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: BodyAndGanMaterialFetcherImpl.CONNECT_TIMEOUT,
        readTimeout: BodyAndGanMaterialFetcherImpl.READ_TIMEOUT
      });

      if (response.responseCode !== 200) {
        console.error(TAG, `Create task failed: ${response.responseCode}, body: ${response.result}`);
        throw new Error(`Create task failed: ${response.responseCode}`);
      }

      const respStr = response.result as string;
      const json = JSON.parse(respStr) as Record<string, Object>;

      const wrinkleResponse = new WrinkleResponse();
      wrinkleResponse.code = json['code'] as number ?? -1;
      wrinkleResponse.message = json['message'] as string ?? '';

      const dataObj = json['data'] as Record<string, Object> | undefined;
      if (dataObj) {
        const data = new WrinkleData();
        data.taskId = dataObj['taskId'] as string ?? '';
        data.status = dataObj['status'] as number ?? -1;
        wrinkleResponse.data = data;
      }

      if (wrinkleResponse.code !== 0) {
        throw new Error(wrinkleResponse.message || '任务创建失败');
      }

      return wrinkleResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 获取Token
   */
  async fetchToken(): Promise<string | null> {
    // 先检查缓存的token
    const cachedToken = this.getCachedToken();
    if (cachedToken) {
      return cachedToken;
    }

    const timestamp = Date.now().toString();
    const sign = await this.generateSignature(BodyAndGanMaterialFetcherImpl.APP_ID, timestamp,
      BodyAndGanMaterialFetcherImpl.APP_KEY);

    const tokenReqJson: Record<string, string> = {
      'appId': BodyAndGanMaterialFetcherImpl.APP_ID,
      'timestamp': timestamp,
      'sign': sign,
      'grantType': BodyAndGanMaterialFetcherImpl.GRANT_TYPE
    };

    const tokenUrl = BodyAndGanMaterialFetcherImpl.TEST_TOKEN_URL;

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(tokenUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json; charset=utf-8'
        },
        extraData: tokenReqJson,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: BodyAndGanMaterialFetcherImpl.CONNECT_TIMEOUT,
        readTimeout: BodyAndGanMaterialFetcherImpl.READ_TIMEOUT
      });

      if (response.responseCode !== 200) {
        throw new Error(`Fetch token failed: ${response.responseCode}`);
      }

      const respStr = response.result as string;
      const json = JSON.parse(respStr) as Record<string, Object>;
      const data = json['data'] as Record<string, string> | undefined;
      const token = data ? data['accessToken'] : '';

      if (!token || token.length === 0) {
        throw new Error('token获取失败');
      }

      this.cacheToken(token);
      return token;
    } catch (err) {
      console.error(TAG, `Token获取失败: ${err}`);
      return null;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 从resultUri下载文件到本地
   */
  private async downloadToLocal(downloadUrl: string): Promise<string> {
    if (!downloadUrl || downloadUrl.trim().length === 0) {
      throw new Error('resultUri is empty');
    }

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(downloadUrl, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: BodyAndGanMaterialFetcherImpl.CONNECT_TIMEOUT,
        readTimeout: BodyAndGanMaterialFetcherImpl.READ_TIMEOUT
      });

      if (response.responseCode !== 200) {
        throw new Error(`Download failed: ${response.responseCode}`);
      }

      const context = getContext(this) as common.UIAbilityContext;
      const cacheDir = context.cacheDir;

      const time = this.formatDate(new Date(), 'yyyyMMddHHmmss');
      const fileName = `wrinkle_result_${time}.zip`;
      const filePath = `${cacheDir}/${fileName}`;

      const arrayBuffer = response.result as ArrayBuffer;
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, arrayBuffer);
      fs.closeSync(file);

      console.info(TAG, `下载完成, filePath=${filePath}, fileLength:${arrayBuffer.byteLength}`);
      return filePath;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 获取缓存的Token
   */
  private getCachedToken(): string | null {
    const token = this.cachedToken;
    if (!token || token.length === 0) {
      return null;
    }
    const ageMs = Date.now() - this.cachedTokenAtMs;
    return ageMs < 5 * 60 * 1000 ? token : null; // 5分钟有效
  }

  /**
   * 缓存Token
   */
  private cacheToken(token: string): void {
    this.cachedToken = token;
    this.cachedTokenAtMs = Date.now();
  }

  /**
   * 创建请求参数JSON（异步版本）
   */
  private async createRequestParamsJson(
    base64Image: string,
    taskType: string,
    bodyEffectFlag: number,
    inpaintSize?: number
  ): Promise<Record<string, Object>> {
    const timestamp = Math.floor(Date.now() / 1000).toString();
    const appId = BodyAndGanMaterialFetcherImpl.APP_ID;
    const appKey = BodyAndGanMaterialFetcherImpl.APP_KEY;

    // 异步生成签名
    const sign = await this.generateSignature(appId, timestamp, appKey);

    // 兼容 bodyandgan 常见字段。
    const jsonObject: Record<string, Object> = {
      'appId': appId,
      'timestamp': timestamp,
      'sign': sign,
      'grantType': BodyAndGanMaterialFetcherImpl.GRANT_TYPE,
      'image': base64Image,
      'imageBase64': base64Image,
      'function': BodyAndGanMaterialFetcherImpl.FUNCTION,
      'functionId': BodyAndGanMaterialFetcherImpl.FUNCTION
    };

    if (BodyAndGanMaterialFetcher.TASK_TYPE_BODY_EFFECT === taskType) {
      jsonObject['flag'] = bodyEffectFlag;
      if (inpaintSize !== undefined && inpaintSize !== null) {
        jsonObject['inpaint_size'] = inpaintSize;
      }
    }

    return jsonObject;
  }

  /**
   * 创建任务请求JSON
   */
  private createTaskCreateRequestJson(
    requestParamsJson: Record<string, Object>,
    taskType: string
  ): Record<string, Object> {
    const finalTaskType = (!taskType || taskType.trim().length === 0)
      ? BodyAndGanMaterialFetcher.TASK_TYPE_GAN_WRINKLE
      : taskType;

    return {
      'taskType': finalTaskType,
      'requestParams': JSON.stringify(requestParamsJson),
      'paramsSchemaVersion': BodyAndGanMaterialFetcherImpl.PARAMS_SCHEMA_VERSION
    };
  }

  /**
   * 将ImageSource编码为Base64字符串
   */
  private async encodeImageSourceToBase64(imageSource: image.ImageSource): Promise<string> {
    const imagePackerApi = image.createImagePacker();
    const packOpts: image.PackingOption = {
      format: 'image/jpeg',
      quality: 50,
      bufferSize: 10 * 1024 * 1024
    };
    const arrayBuffer = await imagePackerApi.packing(imageSource, packOpts);
    const base64Helper = new util.Base64Helper();
    const uint8Array = new Uint8Array(arrayBuffer);
    return base64Helper.encodeToStringSync(uint8Array);
  }


  /**
   * 生成签名（异步版本）
   */
  private async generateSignature(appId: string, timestamp: string, appKey: string): Promise<string> {
    const raw = appId + timestamp + appKey;
    return await STCrypto.doMd(raw);
  }

  /**
   * 格式化日期
   */
  private formatDate(date: Date, format: string): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    const second = date.getSeconds().toString().padStart(2, '0');

    return format
      .replace('yyyy', year.toString())
      .replace('MM', month)
      .replace('dd', day)
      .replace('HH', hour)
      .replace('mm', minute)
      .replace('ss', second);
  }

  /**
   * 休眠指定毫秒
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
