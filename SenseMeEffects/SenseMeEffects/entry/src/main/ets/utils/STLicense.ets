import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';
import { JSON } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';

export default class STLicense{
  private static readonly SERVER_URL = "http://sensemarsplatform.softsugar.com"
  private static readonly AUTH_API = "/access/studio/v1/sdkAuth"

/*  private static readonly APP_ID = ""
  private static readonly APP_KEY = ""*/
  private static readonly APP_VERSION ="1.0.0"
  private static readonly SDK_VERSION ="300"

  public static async GetLicenseOnLine(licPath:string,appId:string, appKey:string):Promise<boolean>{
    try {
      if (fileIo.accessSync(licPath)) {
        return true
      }
      let paramString =`appId=${appId}&appVersion=${STLicense.APP_VERSION}&sdkVersion=${STLicense.SDK_VERSION}`
      let mdString =`${paramString}&${appKey}`

      let result = await STLicense.doMd(mdString)
      let url =`${STLicense.SERVER_URL}${STLicense.AUTH_API}?${paramString}&sign=${result}`

      console.log("Response: " + url);
      const session = rcp.createSession();
      let response = await session.post(url, "")
      let obj = response.toJSON()
      if (obj) {
        let licUrl:string = obj["data"]["license"]
        const download = rcp.createSession();

        const downloadResponse= await download.downloadToFile(licUrl,{
          kind:'file',
          file:licPath
        })
        console.info(`downloadResponse : ${downloadResponse}`);
        download.close()
        return true;
      }
      console.info(`Response : ${response}`);
      session.close()
      return false
    }
    catch (e){
        return false
    }
  }

  static async doMd(message:string) {
    let mdAlgName = 'SHA1'; // 摘要算法名
    let md = cryptoFramework.createMd(mdAlgName);
    await md.update({ data: new Uint8Array(buffer.from(message, 'utf-8').buffer) });
    let mdResult = await md.digest();
    const hex = Array.from(mdResult.data)
      .map(byte => byte.toString(16).padStart(2, '0'))
      .join('');
    return hex
  }
}

