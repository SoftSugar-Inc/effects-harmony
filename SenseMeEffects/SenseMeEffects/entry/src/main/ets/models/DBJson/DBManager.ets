import { fileIo } from "@kit.CoreFileKit";
import { List } from "@kit.ArkTS";
import DBUserInfo from "./DBUserInfo";

export interface Item{
  uid:string
  value:number
}
export class  DBFilter{
  id:string = "filter"
  time:number = 0
  selectedPosition:number = -1
  groupEnumName:string = ""
  filterPath:string = ""
  filterStrength:number = 0
}
export class  DBStyle{
  id:string = "style"
  time:number = 0
  parentIndex:number = 0
  childIndex:number = -1
  makeupStrength:number = 0
  filterStrength:number = 0
}

export class DBMakeUp{
  id:string = "makeup"
  time:number = 0
  type:number = -1
  selectParentIndex:number = -1
  selectIndex:number = -1
  makeupPath:string = ""
  makeupStrength:number = 0
}

export class DBManagerData{
  userInfo: DBUserInfo|null = null
  filter:DBFilter = new DBFilter()
  makeUp:Record<number, DBMakeUp|null> = {}
  beauty:Record<string, number|undefined> = {}
  style:DBStyle|undefined
  public constructor() {
  }
}
export default class DBManager{
  private static instance: DBManager;
  private constructor() {}

  private context: Context |null= null;

  private data:DBManagerData = new DBManagerData()

  setContext(context: Context): void {
    this.context = context
    try {
      const filePath = this.context.filesDir + '/DBManager.json';
      if (fileIo.accessSync(filePath)) {
        const jsonStr = fileIo.readTextSync(filePath);
        this.data = JSON.parse(jsonStr);
        if (!this.data.makeUp) {
          this.data.makeUp = {}
        }
      }
    }
    catch (e) {
      console.error('DBManager parse json error :' + e)
    }
  }

  public static Instance(){
    if (!DBManager.instance){
      DBManager.instance = new DBManager()
    }

    return DBManager.instance
  }

  public save(){
    const content = JSON.stringify(this.data)
    const filePath = this.context?.filesDir + '/DBManager.json'
    if (fileIo.accessSync(filePath)) {
      fileIo.unlinkSync(filePath)
    }
    const file = fileIo.createWriteStream(filePath)
    file.write(content)
    file.close()
  }

  public updateUserInfo(userInfo : DBUserInfo){
    this.data.userInfo = userInfo
    this.save()
  }
  public getUserInfo():DBUserInfo|null{
    return this.data.userInfo
  }

  //Filter
  public deleteAllFilter(){
    this.data.filter = new DBFilter()
  }
  public updateFilter(groupEnumName:string, selectedPosition:number, path:string){
    this.data.filter.groupEnumName = groupEnumName
    this.data.filter.selectedPosition = selectedPosition
    this.data.filter.filterPath = path

    this.data.filter.time =Date.now()
  }
  public updateFilterStrength(strength:number){
    this.data.filter.filterStrength = strength
    this.data.filter.time =Date.now()
  }
  public getFilter():DBFilter{
    return this.data.filter
  }

  //Style
  public deleteStyle(){
    this.data.style = new DBStyle()
  }
  public updateStyle(parentIndex:number, childIndex:number){
    if (this.data.style == undefined) {
      this.data.style = new DBStyle()
    }
    this.data.style.parentIndex = parentIndex
    this.data.style.childIndex = childIndex
    this.data.style.time =Date.now()
  }
  public updateStyleStrength( filterStrength:number, makeUpStrength:number){
    if (this.data.style == undefined) {
      return
    }
    this.data.style.filterStrength = filterStrength
    this.data.style.makeupStrength = makeUpStrength
    this.data.filter.time =Date.now()
  }
  public getStyle(){
    return this.data.style
  }

  //makeup
  public deleteAllMakeup(){
    this.data.makeUp = {}
  }
  public deleteMakeup(type:number){
    this.data.makeUp[type] = null
  }
  public updateMakeup(type:number, parentIndex:number, index:number, path:string, strength:number){
    let item = this.data.makeUp[type]
    if (!item) {
      item = new DBMakeUp()
      this.data.makeUp[type] = item
    }
    item.type = type
    item.selectParentIndex = parentIndex
    item.selectIndex = index
    item.makeupPath = path
    item.makeupStrength = strength
    item.time =Date.now()
  }
  public updateMakeupStrength(type:number, strength:number){
    let item = this.data.makeUp[type]
    if (item){
      item.makeupStrength = strength
      item.time =Date.now()
    }
  }
  public getMakeups():DBMakeUp[]{
    let list =new List<DBMakeUp>()
    if (this.data.makeUp) {
      Object.values(this.data.makeUp).forEach((m)=>{
        if (m) {
          list.add(m)
        }
      })
      return list.convertToArray()
    }
    return []
  }


  //beauty
  public deleteAllBeauty(){
    this.data.beauty = {}
  }
  public deleteBeauty(uid:string){
    this.data.beauty[uid] = undefined
  }
  public updateBeauty(uid:string, strength:number){
    this.data.beauty[uid] =strength
  }

  public getBeauties():Item[]{
    let list =new List<Item>()
    if (this.data.beauty) {
      Object.keys(this.data.beauty).forEach((id)=>{
        if (this.data.beauty[id] != undefined) {
          list.add({uid:id, value:this.data.beauty[id]})
        }
      })
      return list.convertToArray()
    }
    return []
  }
}

