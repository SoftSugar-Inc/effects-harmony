import { STGetGroupList } from './STGetGroupList';
import { STEffectModel } from './Sticker/STEffectModel';
import { STGroupResult } from './Sticker/STGroupResult';
import { common } from '@kit.AbilityKit';
import { HashMap, util } from '@kit.ArkTS';
import { STNetFileOperation } from './STNetFileOperation'
import { request } from '@kit.BasicServicesKit'
import fs from '@ohos.file.fs';

const context = getContext(this) as common.UIAbilityContext
const folder  = context.filesDir + '/material'
const TAG: string = 'STMaterialManager'

export class STMaterialManager{
  private downloadTasks : Map<string, request.agent.Task> = new Map()

  private _stickers : Map<number, STGroupResult> | undefined = undefined
  stickers(){
    return this._stickers
  }
  private _makeUps : Map<number, STGroupResult>  | undefined = undefined
  makeUps(){
    return this._makeUps
  }
  private _tryOns : Map<number, STGroupResult> | undefined = undefined
  tryOns(){
    return this._tryOns
  }
  private _tryOnMakeUps : Map<number, STGroupResult> | undefined = undefined
  tryOnMakeUps(){
    return this._tryOnMakeUps
  }

  private static instance : STMaterialManager

  private constructor() {
    if(!this.isDirectoryExists(folder)) {
      fs.mkdirSync(folder)
    }
  }

  isDirectoryExists(path: string): boolean {
    try {
      const stats = fs.statSync(path);
      return stats.isDirectory();
    } catch (error) {
      console.error('Directory does not exist or an error occurred:', error);
      return false;
    }
  }

  static GetInstance(){
    if (!STMaterialManager.instance) {
      STMaterialManager.instance = new STMaterialManager()
    }
    return STMaterialManager.instance
  }

  static GetJsonContent(json:string) : string{
    let fileContent = context.resourceManager.getRawFileContentSync("Items" + "/" + json)
    let decoder = util.TextDecoder.create();
    let jsonStr = decoder.decodeWithStream(fileContent)
    return jsonStr
  }

  GetJsonFromRawFile(jsonName : string) : STGroupResult[]{
    let jsonStr = STMaterialManager.GetJsonContent(jsonName)
    if (jsonStr.length <= 0) {
      return []
    }
    const jsonArray: STGroupResult[] = JSON.parse(jsonStr)
    return jsonArray
  }

  GetPrepareGroupList(json : string) : Map<number, STGroupResult>{
    let items = this.GetJsonFromRawFile(json)
    return Array.from(items, (tm) =>{
      return new STGroupResult(tm.effectsListId, tm.listName, tm.type)
    }).reduce((acc : Map<number, STGroupResult>, obj : STGroupResult) => {
      acc.set(obj.effectsListId!, obj)
      return acc
    }, new Map<number, STGroupResult>())
  }

  async GetGroupList() {
    //makeup
    this._makeUps = this.GetPrepareGroupList("makeup.json")
    //sticker
    this._stickers = this.GetPrepareGroupList("sticker.json")
    //tryon
    this._tryOns  = this.GetPrepareGroupList("tryOn.json")
    //tryOnMakeUp
    this._tryOnMakeUps  = this.GetPrepareGroupList("tryOnMakeUp.json")
    //get materials
    let groups = Array.from([this._tryOns, this._makeUps, this._tryOnMakeUps, this._stickers])
    let handle = new STGetGroupList()
    let ret = await handle.AuthorizeSync()
    if (ret) {
      let files = fs.listFileSync(folder)
      for (let i = 0; i < groups.length; i++) {
        const element = groups[i];
        for (const key of element!.keys()) {
          let result = element!.get(key)!
          result.effects = Array.from(await handle.fetchGroupListSync(key))
          result.effects.forEach((material, index)=>{
            let splitUrl = material.pkgUrl!.split('//')[1].split('/')
            splitUrl = splitUrl[splitUrl.length-1].split('?')
            const fileName = splitUrl[0]
            const filePath = `${folder}/${fileName}`
            if (files.includes(fileName)) {
              material.downloaded = true
              material.pkgLocalPath = filePath
            }
          })
        }
      }
    }
  }


  async downloadMaterial(model:STEffectModel, success:(filePath:string)=>void, failure:(message:string)=>void){
    let url = model.pkgUrl
    if (url == undefined || url.length <= 0) {
      failure('url is empty')
      return
    }
    if (model.pkgLocalPath != null && model.pkgLocalPath.length > 0) {
      success(model.pkgLocalPath)
      return
    }
    if (this.downloadTasks.get(url)) {
      console.info(TAG, `${url} is downloading`)
      return
    }
    let operation = new STNetFileOperation()
    let downloadTask = await operation.download(folder, url, (filePath)=>{
      console.info(`${url} download success`)
      success(filePath)
      this.downloadTasks.delete(url!)
    }, (message)=>{
      console.error(`${url} download failure ${message}}`)
      failure(message)
      this.downloadTasks.delete(url!)
    })
    if (downloadTask) {
      this.downloadTasks.set(url, downloadTask)
    }
  }
}