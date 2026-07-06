import { PlayerState } from "stplayer"

export class CameraData {
  type: string = ''
  cameraPosition: number = 0
  cameraWidth: number = 0
  cameraHeight: number = 0

  uri:string = ''
  pageData:PageData = new PageData()
}

export class PageData{
  mode = PageMode.Photo
  context : Context|undefined = undefined

  changeVideoState:PlayerState = PlayerState.PLAYER_NODE

  mCustomEvent:number = 0
  immediately:boolean = true
  isOrigin:boolean = false

  isSavePicture = false

  isRecord = false
}

export enum PageMode{
  Photo,
  Video,
  Preview
}