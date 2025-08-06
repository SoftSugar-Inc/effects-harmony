export class BasicDataSource<T> implements IDataSource{
  private listeners : DataChangeListener[] = []
  private dataSource : T[] = []

  public totalCount(): number {
    return this.dataSource.length
  }
  public getData(index: number): T {
    return this.dataSource[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos,1)
    }
  }

  notifyDataReload(){
    this.listeners.forEach(listener =>{
      listener.onDataReloaded()
    })
  }

  notifyDataAdd(index:number) {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  notifyDataChange(index:number){
    this.listeners.forEach(listener =>{
      listener.onDataChange(index)
    })
  }

  notifyDataDelete(index:number){
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  notifyDataMove(from:number, to:number) {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }

  notifyDatasetChange(operations:DataOperation[]){
    this.listeners.forEach(listener => {
      listener.onDatasetChange(operations)
    })
  }

}