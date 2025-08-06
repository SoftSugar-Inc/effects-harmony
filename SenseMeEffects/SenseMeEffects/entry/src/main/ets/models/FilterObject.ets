export default class FilterObject {
  name: string
  path: string
  thumbnail: string = ''

  constructor(path: string, name: string) {
    this.path = path
    this.name = name
  }
}