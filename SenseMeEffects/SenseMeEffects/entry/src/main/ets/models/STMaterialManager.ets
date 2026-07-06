import { STGetGroupList } from './STGetGroupList';
import { STEffectModel } from './Sticker/STEffectModel';
import { STGroupResult } from './Sticker/STGroupResult';
import { common } from '@kit.AbilityKit';
import { HashMap, util } from '@kit.ArkTS';
import { STNetFileOperation } from './STNetFileOperation'
import { BusinessError, request } from '@kit.BasicServicesKit'
import fs from '@ohos.file.fs';
import { fileUri } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit';



// TryOn 美妆配置数据模型
export class TryOnMakeupConfig {
  uid: string = ''
  des: string = ''
  display_des_res_id: string = ''
  asset_path: string = ''
  select_icon_nor_res_id: string = ''
  select_icon_press_res_id: string = ''
  group_id: number = 0
  beauty_type: number = 0
  effects: STEffectModel[] = []
}
const context = getContext(this) as common.UIAbilityContext
const resourceManager = context.resourceManager
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
  // TryOn 美妆配置项（包含图标等信息）
  private _tryOnMakeupItems: TryOnMakeupConfig[] = []
  tryOnMakeupItems(): TryOnMakeupConfig[] {
    return this._tryOnMakeupItems
  }
  // TryOn 美妆素材组
  private _tryOnMakeupGroups: Map<number, STGroupResult> | undefined = undefined
  tryOnMakeupGroups(): Map<number, STGroupResult> | undefined {
    return this._tryOnMakeupGroups
  }

  private _styles : Map<number, STGroupResult> | undefined = undefined
  styles(){
    return this._styles
  }


  private static instance : STMaterialManager
  private static isGetGroupList = false

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
      return new STGroupResult(tm.effectsListId, tm.listName, tm.type, tm.localPackages)
    }).reduce((acc : Map<number, STGroupResult>, obj : STGroupResult) => {
      acc.set(obj.effectsListId!, obj)
      return acc
    }, new Map<number, STGroupResult>())
  }

  // 加载 TryOn 美妆配置
  private loadTryOnMakeupConfig(): void {
    try {
      const fileContent = resourceManager.getRawFileContentSync('tryon/menu_tryon_makeup.json')
      const decoder = util.TextDecoder.create()
      const jsonStr = decoder.decodeWithStream(fileContent)
      const jsonArray: Record<string, Object>[] = JSON.parse(jsonStr)

      this._tryOnMakeupItems = jsonArray.map((item): TryOnMakeupConfig => {
        const config = new TryOnMakeupConfig()
        config.uid = item['uid'] as string
        config.des = item['des'] as string
        config.display_des_res_id = item['display_des_res_id'] as string
        config.asset_path = item['asset_path'] as string
        config.select_icon_nor_res_id = item['select_icon_nor_res_id'] as string
        config.select_icon_press_res_id = item['select_icon_press_res_id'] as string
        config.group_id = parseInt(item['group_id'] as string)
        config.beauty_type = item['beauty_type'] as number
        return config
      })

      // 创建素材组映射
      this._tryOnMakeupGroups = new Map<number, STGroupResult>()
      this._tryOnMakeupItems.forEach((item) => {
        this._tryOnMakeupGroups!.set(item.group_id, new STGroupResult(item.group_id, item.des, item.beauty_type))
      })
    } catch (e) {
      console.error('loadTryOnMakeupConfig error:', e)
    }
  }

  async GetGroupList() {
    if( STMaterialManager.isGetGroupList) return
    //makeup
    this._makeUps = this.GetPrepareGroupList("makeup.json")
    //sticker
    this._stickers = this.GetPrepareGroupList("sticker.json")
    //styles
    this._styles  = this.GetPrepareGroupList("style.json")
    //tryOnMakeup - 加载配置和素材组
    this.loadTryOnMakeupConfig()

    //get materials
    let groups = Array.from([this._makeUps, this._stickers, this._styles, this._tryOnMakeupGroups])
    let handle = new STGetGroupList()
    let ret = await handle.AuthorizeSync()
    if (ret) {
      let files = fs.listFileSync(folder)
      for (let i = 0; i < groups.length; i++) {
        const element = groups[i];
        for (const key of element!.keys()) {
          let result = element!.get(key)!
          result.effects = Array.from(await handle.fetchGroupListSync(key))
          result.effects.forEach((material, index) => {
            let splitUrl = material.pkgUrl!.split('//')[1].split('/')
            splitUrl = splitUrl[splitUrl.length-1].split('?')
            const fileName = splitUrl[0]
            const filePath = `${folder}/${fileName}`
            if (files.includes(fileName)) {
              material.downloaded = true
              material.pkgLocalPath = filePath
            }
          })

          if (result.localPackages && result.localPackages.length > 0) {
            let localArr:STEffectModel[] = new Array(result.localPackages.length)
            for (let i = 0; i<result.localPackages.length;i++){
              let path = result.localPackages[i]
              let zipName = path.substring(path.lastIndexOf('/')+ 1)
              let name = zipName.substring(0, zipName.lastIndexOf('.'))

              let targetPath =`${folder}/${zipName}`
              if (!fs.accessSync(targetPath)) {
                const fileContent = resourceManager.getRawFileContentSync(path)
                const fileArrayBuffer = fileContent.buffer.slice(0)
                let destFile = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
                fs.writeSync(destFile.fd, fileArrayBuffer)
                fs.closeSync(destFile)
              }

              let iconPath =path.replace('.zip','.png')
              let iconTargetPath =targetPath.replace('.zip','.png')
              if (!fs.accessSync(iconTargetPath)) {
                const iconContent = resourceManager.getRawFileContentSync(iconPath)
                const iconArrayBuffer = iconContent.buffer.slice(0)
                let destFile = fs.openSync(iconTargetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
                fs.writeSync(destFile.fd, iconArrayBuffer)
                fs.closeSync(destFile)
              }

              localArr[i] = new STEffectModel(name, fileUri.getUriFromPath(iconTargetPath), "", 10000 + i)
              localArr[i].downloaded = true
              localArr[i].pkgLocalPath = targetPath
            }
            result.effects = [...localArr, ...result.effects];

          }
          STMaterialManager.isGetGroupList = true
        }
      }
    }
  }

  async downloadMaterial(model:STEffectModel, success:(filePath:string)=>void, failure:(message:string)=>void){
    if (model.pkgLocalPath != null && model.pkgLocalPath.length > 0) {
      success(model.pkgLocalPath)
      return
    }
    let url = model.pkgUrl
    if (url == undefined || url.length <= 0) {
      failure('url is empty')
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

  getBodyBeautyMaterial(format: string, imageSource: image.ImageSource, materialType:number, success:(filePath:string)=>void, failed:(msg:string)=>void){
    this.imageSourceToBase64(format, imageSource).then((base64image)=>{
      let handle = new STGetGroupList()
      handle.getBodyBeautyMaterial(base64image, materialType).then((result)=>{
        console.log("getBodyBeautyMaterial: ", result)
        let jsonObj : Record<string,string> = JSON.parse(result)
        if (jsonObj['zip_file']) {
          let path =  this.saveZipFileToLocal(materialType.toString(), jsonObj['zip_file'])
          success(path)
        }
        else {
          failed(result)
        }
      }).catch((e:BusinessError)=>{
        failed(e.message)
      })

    }).catch((e:BusinessError)=>{
      failed(e.message)
    })
  }

  saveZipFileToLocal(name:string, zipBase64:string):string{
    let base64 = new util.Base64Helper
    let buffer =  base64.decodeSync(zipBase64)
    let targetPath =`${folder}/${name}_bodyMaterail.zip`
    if (fs.accessSync(targetPath)) {
      fs.unlinkSync(targetPath)
    }
    let destFile = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
    fs.writeSync(destFile.fd, buffer.buffer.slice(0))
    fs.closeSync(destFile)
    return targetPath
  }

  /**
   * 图片转base64格式
   *
   * @param format 待转化的图片类型（image/png、image/jpg、image/webp）
   * @param imageSource
   * @returns
   */
  imageSourceToBase64(format: string, imageSource: image.ImageSource): Promise<string> {
    return new Promise((resolve, reject) => {
      image.createImagePacker().packing(imageSource, { format: format, quality: 100, bufferSize: 10 * 1024 * 1024 })
        .then((value: ArrayBuffer) => {

          let base64 = new util.Base64Helper
          let arrayStr = base64.encodeToStringSync(new Uint8Array(value))
          resolve(arrayStr)
        })
        .catch((err: BusinessError) => {
          reject(err)
        })
    })
  }

}