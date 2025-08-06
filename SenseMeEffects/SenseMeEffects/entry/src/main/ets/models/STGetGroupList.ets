import { STHttpManager } from '../networking/STHttpManager'
import { LightWeightMap } from '@kit.ArkTS';
import { STResponse } from '../networking/STResponse';
import { STCrypto } from '../common/STCrypto';
import { STSdk } from '../networking/STSdk';
import { STMaterialList } from '../networking/STMaterialList'
import { STGroupResult } from './Sticker/STGroupResult'
import { STAuthorizeData } from '../networking/STAuthorizeData';
import { STEffectModel } from './Sticker/STEffectModel';
import { Callback } from '@ohos.base';
import http from '@ohos.net.http';

const appkey = "c930320e4806494a817e5bb80278defc"
const ivKey = "5e8y6w45ju8w9jq8"

export class STGetGroupList {
  private token: string | undefined
  private sdkKey: string | undefined

  Authorize(completion: Callback<boolean>) {
    let parameters = new LightWeightMap<string, string>()
    parameters.set("appId", "e22024c218fd48638ca9d85514c36e66")
    parameters.set("timestamp", "1651135307220")
    parameters.set("sdkVersion", "300")
    parameters.set("appVersion", "3.1.3")
    parameters.set("uuid", "0A8E90DD-4188-47D0-B041-F9BB364F6621")
    let prepareSignStr = STHttpManager.map2Strting(parameters, false) + appkey
    let signStr = STCrypto.sha1(prepareSignStr)
    parameters.set("sign", signStr)
    STHttpManager.Authorize("http://sensemarsplatform.softsugar.com/access/studio/v1/sdkAuth", (response) => {
      let jsonResponse: STResponse<STAuthorizeData> | undefined = JSON.parse(response.result as string)
      if (jsonResponse) {
        this.token = jsonResponse.data?.token
        let sdkKeyData = jsonResponse.data?.data
        if (sdkKeyData) {
          STCrypto.aesDecrypto(sdkKeyData, appkey, ivKey).then((sdkKeystr) => {
            let stSdk: STSdk | undefined = JSON.parse(sdkKeystr)
            if (stSdk) {
              this.sdkKey = stSdk.sdkKey
              completion(true)
            } else {
              completion(false)
            }
          })
        } else {
          completion(false)
        }
      } else {
        completion(false)
      }
    }, (response) => {
      console.log("failure");
      completion(false)
    }, parameters)
  }

  async AuthorizeSync(): Promise<boolean> {
    let parameters = new LightWeightMap<string, string>()
    parameters.set("appId", "e22024c218fd48638ca9d85514c36e66")
    parameters.set("timestamp", "1651135307220")
    parameters.set("sdkVersion", "300")
    parameters.set("appVersion", "3.1.3")
    parameters.set("uuid", "0A8E90DD-4188-47D0-B041-F9BB364F6621")
    let prepareSignStr = STHttpManager.map2Strting(parameters, false) + appkey
    let signStr = STCrypto.sha1(prepareSignStr)
    parameters.set("sign", signStr)
    let response =
      await STHttpManager.AuthorizeSync("http://sensemarsplatform.softsugar.com/access/studio/v1/sdkAuth", parameters)
    let jsonResponse: STResponse<STAuthorizeData> | undefined = JSON.parse(response.result as string)
    if (jsonResponse) {
      this.token = jsonResponse.data?.token
      let sdkKeyData = jsonResponse.data?.data
      if (sdkKeyData) {
        let sdkKeyStr = await STCrypto.aesDecrypto(sdkKeyData, appkey, ivKey)
        let stSdk: STSdk | undefined = JSON.parse(sdkKeyStr)
        if (stSdk) {
          this.sdkKey = stSdk.sdkKey
          return true
        } else {
          return false
        }
      } else {
        return false
      }
    } else {
      return false
    }
  }

  async fetchGroupList(groupId: number, completion?: Callback<STEffectModel[]>) {
    let parameters = new LightWeightMap<string, string>()
    parameters.set("appId", "e22024c218fd48638ca9d85514c36e66")
    parameters.set("timestamp", Date.now().toString())
    parameters.set("sdkVersion", "xxx")
    parameters.set("appVersion", "xxx")
    parameters.set("uuid", "xxx")
    let list: STMaterialList = { effectsListId: groupId }
    let message = JSON.stringify(list)
    let dataValue = await STCrypto.aesEcrypto(message, appkey, ivKey)
    parameters.set("data", dataValue)
    let prepareSignStr = STHttpManager.map2Strting(parameters, false) + this.sdkKey
    let signStr = STCrypto.sha1(prepareSignStr)
    parameters.set("sign", signStr)
    let header = new LightWeightMap<string, string>()
    header.set("Authorization", this.token)
    STHttpManager.fetcGroupList("http://sensemarsplatform.softsugar.com/api/studio/v1/materials/list", (response) => {
      let jsonResponse: STResponse<STGroupResult> | undefined = JSON.parse(response.result as string)
      if (completion) {
        let models = jsonResponse?.data?.effects as STEffectModel[]
        let rets = Array.from<STEffectModel, STEffectModel>(models, (effect) => {
          return new STEffectModel(effect.name, effect.thumbnail, effect.pkgUrl)
        })
        completion(rets)
      }
    }, (response) => {
      console.log(`fetchGroupList failure ${response.result}`);
      if (completion) {
        completion(null)
      }
    }, parameters, header)
  }

  async fetchGroupListSync(groupId: number): Promise<STEffectModel[]> {
    let parameters = new LightWeightMap<string, string>()
    parameters.set("appId", "e22024c218fd48638ca9d85514c36e66")
    parameters.set("timestamp", Date.now().toString())
    parameters.set("sdkVersion", "xxx")
    parameters.set("appVersion", "xxx")
    parameters.set("uuid", "xxx")
    let list: STMaterialList = { effectsListId: groupId }
    let message = JSON.stringify(list)
    let dataValue = await STCrypto.aesEcrypto(message, appkey, ivKey)
    parameters.set("data", dataValue)
    let prepareSignStr = STHttpManager.map2Strting(parameters, false) + this.sdkKey
    let signStr = STCrypto.sha1(prepareSignStr)
    parameters.set("sign", signStr)
    let header = new LightWeightMap<string, string>()
    header.set("Authorization", this.token)
    let response =
      await STHttpManager.fetchGroupListSync("http://sensemarsplatform.softsugar.com/api/studio/v1/materials/list",
        parameters, header)
    let jsonResponse: STResponse<STGroupResult> | undefined = JSON.parse(response.result as string)
    let models = jsonResponse?.data?.effects as STEffectModel[]
    let rets = Array.from<STEffectModel, STEffectModel>(models, (effect) => {
      return new STEffectModel(effect.name, effect.thumbnail, effect.pkgUrl)
    })
    return rets
  }
}