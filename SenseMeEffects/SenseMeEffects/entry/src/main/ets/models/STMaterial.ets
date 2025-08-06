export enum CellState {
  NeedDonwload = 0,
  Downloading,
  Downloaded,
}

export interface STMaterial {
  selected : boolean
  downloaded : boolean
  pkgLocalPath : string
  state : CellState
  type : number
  packageId: number
  //strength: number
}