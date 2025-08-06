import { relationalStore } from '@kit.ArkData'; // 导入模块
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common'
import { fileIo } from '@kit.CoreFileKit';

let context = getContext(this) as common.UIAbilityContext;

export class STKVStorage {
  private dbName : string = 'SQLIT.db'
  private RdbStore : relationalStore.RdbStore | undefined = undefined

  constructor(dbName : string) {
    this.dbName = dbName
  }

  async openRdb() : Promise<boolean> {
    const config :relationalStore.StoreConfig = {
      name: this.dbName,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    let RdbStore = await relationalStore.getRdbStore(context, config)
    if (RdbStore == null) {
      console.error(`open Rdb error!!!`)
      return false
    }
    this.RdbStore = RdbStore
    if (this.RdbStore.version == 0) {
      let sql = `CREATE TABLE IF NOT EXISTS TABLENAME (ID INTEGER PRIMARY KEY AUTOINCREMENT, KEY TEXT NOT NULL, SIZE INTEGER, DATA BLOB);`
      await this.RdbStore.execute(sql)
      this.RdbStore.version = 3
    }
    console.log(`db version ${this.RdbStore.version}`)
    return true
  }

  private async _checkRdbStore() : Promise<boolean> {
    if (this.RdbStore == undefined) {
      let ret = await this.openRdb()
      if (!ret) {
        console.error(`open failture}`)
        return false
      }
    }
    return true
  }


  async update(key : string, value: ArrayBuffer) : Promise<boolean> {
    let check = await this._checkRdbStore()
    if(!check) return false
    let newValue = new Uint8Array(value)
    const valueBucket : relationalStore.ValuesBucket = {
      'KEY' : key,
      'SIZE' : newValue.length,
      'DATA' : newValue
    }
    let predicates = new relationalStore.RdbPredicates('TABLENAME')
    predicates.equalTo('KEY', key)
    let ret = await (this.RdbStore as relationalStore.RdbStore).update(valueBucket, predicates)
    return ret != 0
  }


  async get(key : string) : Promise<ArrayBuffer | undefined> {
    let check = await this._checkRdbStore()
    if(!check) return undefined
    return this.quary(key)
  }

  async set(key : string, value : ArrayBuffer) : Promise<boolean>{
    let check = await this._checkRdbStore()
    if(!check) return false
    let newValue = new Uint8Array(value)
    let size = newValue.byteLength
    const valueBucket: relationalStore.ValuesBucket = {
      'KEY' : key,
      'SIZE' : size,
      'DATA' : newValue
    };
    let ret = await (this.RdbStore as relationalStore.RdbStore).insert('TABLENAME', valueBucket)
    return ret != 0
  }

  private async quary(key: string) : Promise<ArrayBuffer | undefined>{
    let predicate = new relationalStore.RdbPredicates('TABLENAME')
    predicate.equalTo('KEY', key)
    let ret = await (this.RdbStore as relationalStore.RdbStore).query(predicate, ['ID', 'KEY', 'SIZE', 'DATA'])
    if (ret == null) return undefined
    while (ret.goToNextRow()) {
      let id = ret.getLong(ret.getColumnIndex('ID'))
      let key = ret.getString(ret.getColumnIndex('KEY'))
      let size = ret.getLong(ret.getColumnIndex('SIZE'))
      let buffer = ret.getBlob(ret.getColumnIndex('DATA'))
      if (size == 0){
        ret.close()
        return undefined
      }else{
        ret.close()
        return buffer.buffer
      }
    }
    ret.close()
    return undefined
  }

  async delete(key : string) : Promise<boolean> {
    let check = await this._checkRdbStore()
    if(!check) return false
    let predicate = new relationalStore.RdbPredicates('TABLENAME')
    predicate.equalTo('KEY', key)
    let ret = await (this.RdbStore as relationalStore.RdbStore).delete(predicate)
    return ret != 0
  }

  async clear() : Promise<boolean>{
    let check = await this._checkRdbStore()
    if(!check) return false
    await this.RdbStore!.close()
    await relationalStore.deleteRdbStore(context, "SQLIT.db")
    return this.openRdb()
  }

}