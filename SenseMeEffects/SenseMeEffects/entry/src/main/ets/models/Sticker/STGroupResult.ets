import { STEffectModel } from './STEffectModel'

export class STGroupResult {
  effectsListId : number | undefined
  listName : string | undefined
  type : number | undefined
  owner : string | undefined
  effects : STEffectModel[] | undefined
  localPackages : string[] | undefined

  constructor(effectsListId?:number, listName?:string, type?:number, localPackages? : string[] | undefined) {
    this.effectsListId = effectsListId
    this.listName = listName
    this.type = type
    this.localPackages = localPackages
  }
}