import http from '@ohos.net.http';
import { BusinessError, Callback } from '@ohos.base';
import { LightWeightMap } from '@kit.ArkTS';

export class STHttpManager {
  static map2Strting(data: LightWeightMap<string, string>, needEncodeURL : boolean): string {
    let keys : string[] = []
    for (const key of data.keys()) {
      keys.push(key)
    }
    return keys
        .sort()
        .map(key => key + '=' + (needEncodeURL ? encodeURIComponent(data.get(key)) : data.get(key)))
        .join('&');
  }

  static Authorize(url:string, success:Callback<http.HttpResponse>, failure:Callback<http.HttpResponse>, parameters:LightWeightMap<string, string>) {
    let httpRequest = http.createHttp()
    let str = STHttpManager.map2Strting(parameters, false)
    httpRequest.request(url, {
      method: http.RequestMethod.POST,
      extraData:str,
    }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        success(data)
        httpRequest.destroy()
      } else {
        failure(data)
        httpRequest.destroy();
      }
    })
  }

  static async AuthorizeSync(url:string, parameters:LightWeightMap<string, string>) : Promise<http.HttpResponse>{
    let httpRequest = http.createHttp()
    let str = STHttpManager.map2Strting(parameters, false)
    let response = await httpRequest.request(url, {
      method: http.RequestMethod.POST,
      extraData:str,
    })
    httpRequest.destroy()
    return response
  }

  static fetcGroupList(url:string, success:Callback<http.HttpResponse>, failure:Callback<http.HttpResponse>, parameters:LightWeightMap<string, string>, header:LightWeightMap<string, string>){
    let httpRequest = http.createHttp()
    let str = STHttpManager.map2Strting(parameters, true)
    httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: {
        "Authorization" : header.get("Authorization"),
        'Content-Type' : "application/x-www-form-urlencoded"
      },
      extraData:str,
    }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        success(data)
        httpRequest.destroy()
      } else {
        failure(data)
        httpRequest.destroy();
      }
    })
  }

  static async fetchGroupListSync(url:string,
                                  parameters:LightWeightMap<string, string>,
                                  header:LightWeightMap<string, string>) : Promise<http.HttpResponse>{
    let httpRequest = http.createHttp()
    let str = STHttpManager.map2Strting(parameters, true)
    let response = await httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: {
        "Authorization": header.get("Authorization"),
        'Content-Type': "application/x-www-form-urlencoded"
      },
      extraData:str
    })
    httpRequest.destroy()
    return response
  }
}