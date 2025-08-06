import BeautyObject from './BeautyObject';

@Observed
export default class BeautyGroup {
  name: string
  beauties: BeautyObject[]

  constructor(name: string, beauties: BeautyObject[]) {
    this.name = name
    this.beauties = beauties
  }
}