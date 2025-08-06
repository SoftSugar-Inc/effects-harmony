import { STAuthorizeData }  from  './STAuthorizeData'

export interface STAuthorizeResult {
  code : number | undefined
  message : string | undefined
  data : STAuthorizeData | undefined
}