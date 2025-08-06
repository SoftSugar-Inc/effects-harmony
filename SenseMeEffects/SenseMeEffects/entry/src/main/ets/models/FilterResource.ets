import FilterObject from './FilterObject'

export default class FilterResource {
  public resource: Map<string, FilterObject[]>

  constructor() {
    this.resource = new Map<string, FilterObject[]>()
    this.getAllFilters()
  }

  private getAllFilters() {
    let context = getContext(this)
    let resourceManager = context.resourceManager
    let fileList = resourceManager.getRawFileListSync('filters')
    for (let index = 0; index < fileList.length; index++) {
      let filterCategory = fileList[index]
      let directoryName = `filters/${filterCategory}`
      let files = resourceManager.getRawFileListSync(directoryName)
      let filterList: FilterObject[] = []
      // console.log(`@mahaomeng ${filterCategory} length: ${files.length}`)
      for (let filterIndex = 0; filterIndex < files.length; filterIndex++) {
        const file = files[filterIndex];
        if (file.endsWith('.model')) {
          const baseName = file.slice(0, -('.model'.length))
          const prefix = "filter_style_"
          const name = baseName.replace(prefix, '')
          let filterPath = `${directoryName}/${file}`
          let filter = new FilterObject(filterPath, name)
          const thumbnailFile = files.find(f => f.startsWith(baseName) && (f.endsWith('.jpg') || f.endsWith('.png')))
          if (thumbnailFile) {
            filter.thumbnail = `${directoryName}/${thumbnailFile}`
          }
          filterList.push(filter);
        }
      }
      this.resource.set(filterCategory, filterList)
    }
  }
}