import BeautyGroup from './BeautyGroup';
import BeautyObject from './BeautyObject';
import { BeautyType } from 'libentry.so'
import { common } from '@kit.AbilityKit';
import { ArrayList, HashMap, HashSet, LightWeightMap, util, Vector } from '@kit.ArkTS';
import { ifaa } from '@kit.OnlineAuthenticationKit';

enum Category {
  Beauty,
  Sharpe,
  Plastic2D,
  Adjust
}

export default class BeautyResourceManager {
  private context = getContext(this) as common.UIAbilityContext
  private static instance: BeautyResourceManager
  public dataSource: ArrayList<BeautyGroup> = new ArrayList()
  public defaultEffects: ArrayList<BeautyObject> = new ArrayList()
  public whiteMutexs: ArrayList<BeautyObject> = new ArrayList()
  public smoothMutexs: ArrayList<BeautyObject> = new ArrayList()

  // public selectedBeautys: HashSet<BeautyObject> = new HashSet()

  private constructor() {
  }

  public updateDataSource() {
    this.generateBeautyResource()
  }

  public static getInstance(): BeautyResourceManager {
    if (!BeautyResourceManager.instance) {
      BeautyResourceManager.instance = new BeautyResourceManager()
    }
    return BeautyResourceManager.instance
  }

  public resetMutex(obj: BeautyObject | undefined) {
    if (obj == undefined) {
      return
    }
    if (obj.cleanObject.type == 101) { //美白
      this.whiteMutexs.forEach(element => {
        element.currentStrength = 0.0
      })
    } else if (obj.cleanObject.type == 103) { //磨皮
      this.smoothMutexs.forEach(element => {
        element.currentStrength = 0.0
      })
    }

  }

  private resetAssets() {
    this.dataSource.clear()
    this.defaultEffects.clear()
    this.whiteMutexs.clear()
    this.smoothMutexs.clear()
  }

  private generateBeautyResource() {
    this.resetAssets()
    let baseBeauty = this.generateBaseBeautyResource()
    baseBeauty.beauties.forEach(element => {
      if (element.currentStrength && element.currentStrength > 0) {
        this.defaultEffects.add(element)
      }
      if (element.cleanObject.type == 101) { //美白互斥
        this.whiteMutexs.add(element)
      }
      if (element.subBeauties != undefined && element.subBeauties.length > 0) {
        element.subBeauties.forEach(subElement => {
          if (subElement.cleanObject.type == 101) {
            this.whiteMutexs.add(subElement)
          }
        })
      }

      if (element.cleanObject.type == 103) { //磨皮互斥
        this.smoothMutexs.add(element)
      }
    });

    let reshapeBeauty = this.generateReshapeBeautyResource()
    reshapeBeauty.beauties.forEach(element => {
      if (element.currentStrength && element.currentStrength > 0) {
        this.defaultEffects.add(element)
      }
    })

    let plastic2d = this.generateSharpe2DBeautyResource()
    plastic2d.beauties.forEach(element => {
      if (element.currentStrength && element.currentStrength > 0) {
        this.defaultEffects.add(element)
      }
    })
    let toneBeauty = this.generateToneBeautyResource()
    toneBeauty.beauties.forEach(element => {
      if (element.currentStrength && element.currentStrength > 0) {
        this.defaultEffects.add(element)
      }
    })

    this.dataSource.add(baseBeauty)
    this.dataSource.add(reshapeBeauty)
    this.dataSource.add(plastic2d)
    this.dataSource.add(toneBeauty)
  }

  private getAssetsFromJson(catetory: Category): BeautyObject[] {
    let fileName = ""
    switch (catetory) {
      case Category.Beauty:
        fileName = "beauty.json"
        break;
      case Category.Sharpe:
        fileName = "sharpe.json"
        break;
      case Category.Adjust:
        fileName = "adjust.json"
        break;
    }
    let fileContent = this.context.resourceManager.getRawFileContentSync("beauty" + "/" + fileName)
    let decoder = util.TextDecoder.create();
    let jsonStr = decoder.decodeWithStream(fileContent)
    if (jsonStr.length <= 0) {
      return []
    }
    const jsonArray: BeautyObject[] = JSON.parse(jsonStr)
    let result: BeautyObject[] = []
    for (let index = 0; index < jsonArray.length; index++) {
      const element = jsonArray[index]
      let item = BeautyObject.fromJson(element)
      result.push(item)
    }
    return result
  }
  private getAndroidJsonObjFromJson(): object[] {
    let fileContent = this.context.resourceManager.getRawFileContentSync("beauty/plastic.json")
    let decoder = util.TextDecoder.create();
    let jsonStr = decoder.decodeWithStream(fileContent)
    if (jsonStr.length <= 0) {
      return []
    }
    const jsonArray: object[] = JSON.parse(jsonStr)
    return jsonArray
  }

  // 基础美颜数据
  private generateBaseBeautyResource(): BeautyGroup {

    let beautyGroup = new BeautyGroup('基础美颜',

      this.getAssetsFromJson(Category.Beauty)
    )
    return beautyGroup
  }

  // 美形数据
  private generateReshapeBeautyResource(): BeautyGroup {


    let beautyGroup = new BeautyGroup('美形',

      this.getAssetsFromJson(Category.Sharpe)
    )
    return beautyGroup
  }

  //2d微整形数据
  private generateSharpe2DBeautyResource(): BeautyGroup{

    let jsonArray = this.getAndroidJsonObjFromJson()

    let objs : BeautyObject[]=new Array(jsonArray.length)
    for (let index = 0; index < jsonArray.length; index++) {
      const element = jsonArray[index];
      objs[index] = new BeautyObject(
        element['enum_des'],
        element['select_icon_nor_res'],
        element['select_icon_press_res'],
        element['st_beauty_type'],
        false
      )
      objs[index].currentStrength = element['def_strength'] as number
      objs[index].cleanObject.defaultStrength = element['def_strength'] as number
      objs[index].cleanObject.start_center = element['start_center'] as boolean
      objs[index].cleanObject.other_mutual_beauty_type = element['other_mutual_beauty_type'] as BeautyType[]

      if (element['subBeauties'] != undefined) {
        let subJson =element['subBeauties'] as object[]
        let subObjs: BeautyObject[] = new Array(subJson.length)
        for (let subIndex = 0; subIndex < subObjs.length; subIndex++) {
          const subObj = subJson[subIndex];
            subObjs[subIndex] = new BeautyObject(
              subObj['enum_des'],
              subObj['select_icon_nor_res'],
              subObj['select_icon_press_res'],
              subObj['st_beauty_type'],
            false
          )
          subObjs[subIndex].currentStrength = subObj['def_strength'] as number
          subObjs[subIndex].cleanObject.defaultStrength = subObj['def_strength'] as number
          subObjs[subIndex].cleanObject.start_center = subObj['start_center'] as boolean
          subObjs[subIndex].cleanObject.other_mutual_beauty_type = subObj['other_mutual_beauty_type'] as BeautyType[]
          objs[index].subBeauties = subObjs
        }
      }
    }
    let beautyGroup = new BeautyGroup('微整形',objs)
    return beautyGroup
  }

  // 调整数据
  private generateToneBeautyResource(): BeautyGroup {

    let beautyGroup = new BeautyGroup('调整',

      this.getAssetsFromJson(Category.Adjust)
    )
    return beautyGroup
  }
}