import BeautyGroup from './BeautyGroup';
import BeautyObject, { BeautyParam } from './BeautyObject';
import { common } from '@kit.AbilityKit';
import { ArrayList, HashMap, HashSet, LightWeightMap, util, Vector } from '@kit.ArkTS';
import { ifaa } from '@kit.OnlineAuthenticationKit';
import BeautyCleanObject from './BeautyCleanObject';

enum Category {
  Beauty,
  Reshape,
  Plastic2D,
  SkinDetail,
  Body,
  Plastic3D,
  Adjust,
  Bokeh,
}

export default class BeautyResourceManager {
  private context = getContext(this) as common.UIAbilityContext
  private static instance: BeautyResourceManager
  public dataSource: ArrayList<BeautyGroup> = new ArrayList()
  public defaultEffects: HashMap<string, BeautyObject> = new HashMap()

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


  private resetAssets() {
    this.dataSource.clear()
    this.defaultEffects.clear()
  }

  private generateBeautyResource() {
    this.resetAssets()
    let baseBeauty = this.generateBaseBeautyResource()
    let reshapeBeauty = this.generateReshapeBeautyResource()
    let plastic2d = this.generateSharpe2DBeautyResource()
    let plastic3d = this.generateSharpe3DBeautyResource()
    let toneBeauty = this.generateToneBeautyResource()
    let bokehBeauty = this.generateBokehResource()
  /*
    let skinDetail = this.generateSkinDetailResource()
    skinDetail.beauties.forEach(element => {
      if (element.currentStrength && element.currentStrength > 0) {
        this.defaultEffects.add(element)
      }
    })
  */

    let body = this.generateBodyDetailResource()

    this.dataSource.add(baseBeauty)
    this.dataSource.add(reshapeBeauty)
    this.dataSource.add(plastic2d)
    //this.dataSource.add(skinDetail)
    this.dataSource.add(body)
    this.dataSource.add(plastic3d)
    this.dataSource.add(toneBeauty)
    this.dataSource.add(bokehBeauty)

    this.dataSource.forEach((group)=>{
      group.beauties.forEach(element=>{
        this.defaultEffects.set(element.cleanObject.uid, element)
        if (element.subBeauties) {
          element.subBeauties.forEach(subElement=>{
            this.defaultEffects.set(subElement.cleanObject.uid, subElement)
          })
        }
      })
    })
  }

  private getAssetsFromJson(catetory: Category): BeautyObject[] {
    let fileName = ""
    switch (catetory) {
      case Category.Beauty:
        fileName = "beauty.json"
        break;
      case Category.Reshape:
        fileName = "reshape.json"
        break;
      case Category.Adjust:
        fileName = "adjust.json"
        break;
      case Category.Plastic2D:
        fileName = "plastic.json"
        break;
      case Category.Plastic3D:
        fileName = "plastic_3d.json"
        break;
      case Category.SkinDetail:
        fileName = "skin.json"
        break;
      case Category.Bokeh:
        fileName = "bokeh.json"
        break;
      case Category.Body:
        fileName = "body.json"
        break;
    }
    let fileContent = this.context.resourceManager.getRawFileContentSync("beauty" + "/" + fileName)
    let decoder = util.TextDecoder.create();
    let jsonStr = decoder.decodeWithStream(fileContent)
    if (jsonStr.length <= 0) {
      return []
    }
    const jsonArray: BeautyCleanObject[] = JSON.parse(jsonStr)
    let result: BeautyObject[] = []
    for (let index = 0; index < jsonArray.length; index++) {
      const element = jsonArray[index]
      let item = new BeautyObject(element)
      if (element.sub_beauties && element.sub_beauties.length > 0) {
        item.subBeauties = new Array()
        for (let i = 0; i < element.sub_beauties.length; i++) {
          item.subBeauties[i] = new BeautyObject(element.sub_beauties[i])
        }
      }

      if (element.sub_params && element.sub_params.length > 0) {
        item.subParams = new Array()
        for (let i = 0; i < element.sub_params.length; i++) {
          item.subParams[i] = new BeautyParam(element.sub_params[i])
        }
      }
      result.push(item)
    }
    return result
  }
  private getAndroidJsonObjFromJson(catetory: Category): object[] {
    let fileName = ""
    switch (catetory) {

    }
    let fileContent = this.context.resourceManager.getRawFileContentSync("beauty" + "/" + fileName)
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

      this.getAssetsFromJson(Category.Reshape),true
    )
    return beautyGroup
  }

  //2d微整形数据
  private generateSharpe2DBeautyResource(): BeautyGroup{

    let beautyGroup = new BeautyGroup('微整形',this.getAssetsFromJson(Category.Plastic2D),true)
    return beautyGroup
  }

  //3d微整形数据
  private generateSharpe3DBeautyResource(): BeautyGroup{


    let beautyGroup = new BeautyGroup('3d微整形',this.getAssetsFromJson(Category.Plastic3D))
    return beautyGroup
  }

  // 皮肤细节
  private generateSkinDetailResource(): BeautyGroup {


    let beautyGroup = new BeautyGroup('肤质',this.getAssetsFromJson(Category.SkinDetail))
    return beautyGroup
  }

  // 美体
  private generateBodyDetailResource(): BeautyGroup {


    let beautyGroup = new BeautyGroup('美体',this.getAssetsFromJson(Category.Body),true)
    return beautyGroup
  }


  // 调整
  private generateToneBeautyResource(): BeautyGroup {

    let beautyGroup = new BeautyGroup('调整',

      this.getAssetsFromJson(Category.Adjust)
    )
    return beautyGroup
  }

  //背景虚化
  // 调整
  private generateBokehResource(): BeautyGroup {

    let beautyGroup = new BeautyGroup('背景虚化',this.getAssetsFromJson(Category.Bokeh))
    return beautyGroup
  }
}