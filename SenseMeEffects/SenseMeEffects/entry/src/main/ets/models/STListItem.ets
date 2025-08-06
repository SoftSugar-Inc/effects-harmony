import { BasicDataSource } from './BasicDataSource';

export class STListItem<T> extends BasicDataSource<T>{
  private dataArray : T[] = []
  public getDataArray(): T[] {
    return this.dataArray
  }
  public totalCount(): number {
    return this.dataArray.length
  }
  public getData(index: number): T {
    return this.dataArray[index]
  }
  public addData(index:number, data:T){
    this.dataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }
  public pushData(data:T){
    this.dataArray.push(data)
    this.notifyDataAdd(this.dataArray.length-1)
  }
  public deleteData(index:number){
    this.dataArray.splice(index, 1)
    this.notifyDataDelete(index)
  }
  public chagneData(index:number){
    this.notifyDataChange(index)
  }
  public deleteAllData(){
    let deleteCount = this.dataArray.length
    for (let index = 0; index < deleteCount; index++) {
      this.deleteData(0)
    }
  }
  operationData(){
    let deleteCount = this.dataArray.length
    this.dataArray.splice(0, deleteCount)
    this.notifyDatasetChange([{type:DataOperationType.DELETE, index:0, count:this.dataArray.length}])
  }
}