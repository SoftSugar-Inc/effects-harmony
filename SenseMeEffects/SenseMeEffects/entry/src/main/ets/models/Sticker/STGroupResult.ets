import { STEffectModel } from './STEffectModel'

export class STGroupResult {
  effectsListId : number | undefined
  listName : string | undefined
  type : number | undefined
  owner : string | undefined
  effects : STEffectModel[] | undefined

  constructor(effectsListId?:number, listName?:string, type?:number) {
    this.effectsListId = effectsListId
    this.listName = listName
    this.type = type
  }
}