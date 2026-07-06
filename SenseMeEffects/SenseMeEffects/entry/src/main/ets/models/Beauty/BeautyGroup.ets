import BeautyObject from './BeautyObject';

@Observed
export default class BeautyGroup {
  name: string
  isSupportMultiMode:boolean
  beauties: BeautyObject[]

  constructor(name: string, beauties: BeautyObject[], isSupportMultiMode:boolean = false) {
    this.name = name
    this.beauties = beauties
    this.isSupportMultiMode = isSupportMultiMode
  }
}