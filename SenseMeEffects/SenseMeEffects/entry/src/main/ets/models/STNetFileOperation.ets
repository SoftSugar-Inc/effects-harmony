import { request } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import fs from '@ohos.file.fs';
import { STCrypto } from '../common/STCrypto'

const TAG: string = 'STNetFileOperation'
let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
export class STNetFileOperation {

  /**
   * upload
   * @param fileDir
   * @param progress
   */
  upload(fileDir : string, progress:(uploadSize : number, totalSize : number) => void){

  }

  /**
   * download file
   * @param folder
   * @param url
   * @param success
   * @param failure
   * @param progressCB
   * @returns task
   */
  async download(folder : string, url : string, success:(filePath:string) => void, failure:(message:string) => void, progressCB?:(progress:number) => void) : Promise<request.agent.Task|undefined>{
    if (url == undefined || url.length <= 0) {
      failure(`url is empty!!!`)
      return undefined
    }
    let splitUrl = url.split('//')[1].split('/')
    splitUrl = splitUrl[splitUrl.length-1].split('?')
    const fileName = splitUrl[0]
    const filePath = `${folder}/${fileName}`
    console.info(`@@@ ${splitUrl}  ${filePath}  ${fileName} `)
    //check file
    if (STNetFileOperation.checkFile(folder, fileName)) {
      success(filePath)
      return undefined
    }
    let taskRunning = await request.agent.search({
      state:request.agent.State.RUNNING,
      action:request.agent.Action.DOWNLOAD,
      mode:request.agent.Mode.FOREGROUND
    })
    if (taskRunning) {
      taskRunning.forEach((value, index)=>{
        console.info(`current task info ${value} index ${index}}`)
      })
    }
    let downloadConfig : request.agent.Config = {
      action:request.agent.Action.DOWNLOAD,
      url:url,
      overwrite:true,
      saveas:filePath
    }
    console.info(TAG, `donwload config ${JSON.stringify(downloadConfig)}}`)
    try {
      let task = await request.agent.create(context, downloadConfig)
      if (progressCB) {
        task.on('progress', (progress:request.agent.Progress)=>{
          console.info(TAG, `progress,  progress = ${progress.processed} ${progress.state}`);
          let processed = Number(progress.processed.toString()).valueOf();
          let size = progress.sizes[0];
          let process: number = Math.floor(processed / size * 100);
          if (process < 100) {
            progressCB(process)
          }
        })
      }
      task.on('completed', (progress:request.agent.Progress)=>{
        console.info(TAG, `completed,  progress = ${progress.processed} ${progress.state}`)
        success(filePath)
      })
      task.on('failed', async (progress: request.agent.Progress) => {
        console.info(TAG, `failed,  progress = ${progress.processed} ${progress.state}`)
        let taskInfo = await request.agent.show(task.tid);
        failure(taskInfo.reason)
      })
      await task.start()
      return task
    } catch (err) {
      console.error(TAG, `donwload task create ${JSON.stringify(err)}}`)
      return undefined
    }
  }

  static checkFile(folder : string, filePath : string, suffix?:string) : boolean {
    let files = fs.listFileSync(folder)
    if (files.includes(filePath)) {
      return true
    }
    return false
  }
}