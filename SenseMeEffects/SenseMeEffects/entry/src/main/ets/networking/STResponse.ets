export interface STResponse<T> {
  code : number | undefined
  message : string | undefined
  data : T | undefined
}