import { STMaterial, CellState } from '../STMaterial'

@Observed
export class STEffectModel implements STMaterial {
  id : number | undefined
  name : string | undefined
  pkgSize : number | undefined
  memorySize : number | undefined
  sdkVersion : number | undefined
  studioVersion : number | undefined
  effectsId : number | undefined
  thumbnail : string | undefined
  pkgUrl : string | undefined
  updateTime : number | undefined
  desc : string | undefined
  extraInfo : number | undefined
  serialNumber : number | undefined
  tags : number | undefined
  selected : boolean = false
  downloaded : boolean = false
  pkgLocalPath : string = ""
  state : CellState = CellState.NeedDonwload
  type : number = 0
  packageId: number = -1
  constructor(name?:string, thumbnail?:string, pkgUrl?:string, id? : number) {
    this.name = name
    this.id = id
    this.thumbnail = thumbnail
    this.pkgUrl = pkgUrl
  }
}