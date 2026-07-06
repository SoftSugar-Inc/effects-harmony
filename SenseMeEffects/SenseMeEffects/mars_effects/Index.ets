import {
  BeautyParamType,
  BeautyType,
  EffectBeautyGroup,
  EffectBeautyInfo,
  EffectParam,
  EffectsMode,
  HumanActionParam,
  PixelFormat, RenderingResizingMode, RotateType,
  BodyBeautyParam,MeshType,st_image_t,st_face_shape_t,st_effect_3D_beauty_part_info_t,Rect,DetectResult,
  HumanActionDetectConfig, HumanActionDetectResult, FaceDetectInfo, BodyDetectInfo, Point2D
  } from 'libentry.so'

import {
  InitializeByBuffer,InitializeByMode,checkLicenseByPath,checkLicenseByBuffer,addSubModelByPath,addSubModelByBuffer,
  addAnimalSubModelByPath,addAnimalSubModelByBuffer,resetHumanAction,setParamByEffectParam,setParamByHumanActionParam,
  addPackageByPath,addPackageByBuffer,changePackageByPath,changePackageByBuffer,removePackage,clearPackages,
  setPackageBeautyStrength,replayPackage,getDetectConfig,getCustomEventConfig,getTriggerActions,setBeautyPackageByPath,
  setBeautyPackageByBuffer,setBeautyMode,setBeautyStrength,setBeautyParam,getOverlappedBeautyInfo,process,processASync,
  makeCurrent,makeEmpty,updateWindowSize,setResizingMode,resetPixelReader,
  get3DBeautyParts,set3dBeautyPartsStrength,changePackageBg,setBodyBeauty,updateFaceMeshList,
  setSoundLoadCallback,setSoundPlayCallback,setSoundStopCallback,setSoundPauseCallback,setSoundResumeCallback,
  destroy,addFaceAttributeModel,getDetectResult,humanActionDetect,
   setBodyBeautyStrengthByBodyId,clearBodyBeautyStrengthByBodyId,getBodyBeautyStrengthByBodyId
 ,setFaceBeautyStrengthByFaceId,clearFaceBeautyStrengthByFaceId
}from  'libentry.so'


export {
 BeautyParamType,
 BeautyType,
 EffectBeautyGroup,
 EffectBeautyInfo,
 EffectParam,
 EffectsMode,
 HumanActionParam,
 PixelFormat, RenderingResizingMode, RotateType,
 BodyBeautyParam,MeshType,st_image_t,st_face_shape_t,st_effect_3D_beauty_part_info_t,Rect,DetectResult,
 HumanActionDetectConfig, HumanActionDetectResult, FaceDetectInfo, BodyDetectInfo, Point2D
 ,setFaceBeautyStrengthByFaceId,clearFaceBeautyStrengthByFaceId}



export class STEffects{
  InitializeByBuffer(buffer:ArrayBuffer): boolean{
   return InitializeByBuffer(buffer)
 }
  InitializeByMode(mode: EffectsMode): boolean{
   return InitializeByMode(mode)
 }
  checkLicenseByPath(path: string) : boolean{
   return checkLicenseByPath(path)
 }
  checkLicenseByBuffer(buffer: ArrayBuffer) : boolean{
   return checkLicenseByBuffer(buffer)
 }
  addSubModelByPath(path: string) : boolean{
   return addSubModelByPath(path)
 }
  addSubModelByBuffer(buffer: ArrayBuffer) : boolean{
   return addSubModelByBuffer(buffer)
 }
  addAnimalSubModelByPath(path: string) : boolean{
   return addAnimalSubModelByPath(path)
 }
  addAnimalSubModelByBuffer(buffer: ArrayBuffer) : boolean{
   return addAnimalSubModelByBuffer(buffer)
 }

  resetHumanAction() : boolean{
   return resetHumanAction()
 }
  setParamByEffectParam(param:EffectParam, value: number|undefined) : boolean{
   return setParamByEffectParam(param, value)
 }
  setParamByHumanActionParam(param:HumanActionParam, value: number|undefined) : boolean{
   return setParamByHumanActionParam(param, value)
 }
  addPackageByPath(path: string) : number{
   return addPackageByPath(path)
 }
  addPackageByBuffer(buffer: ArrayBuffer|null) : number{
   return addPackageByBuffer(buffer)
 }
  changePackageByPath(path: string) : number{
   return changePackageByPath(path)
 }
  changePackageByBuffer(buffer: ArrayBuffer|null) : number{
   return changePackageByBuffer(buffer)
 }
  removePackage(id: number) : boolean{
   return removePackage(id)
 }
  clearPackages() : boolean{
   return clearPackages()
 }
  setPackageBeautyStrength(id:number, type:EffectBeautyGroup, value: number|undefined) : boolean{
   return setPackageBeautyStrength(id, type, value)
 }
  replayPackage(id:number) : boolean{
   return replayPackage(id)
 }

  getDetectConfig() : bigint{
   return getDetectConfig()
 }
  getCustomEventConfig() : number{
   return getCustomEventConfig()
 }
  getTriggerActions() : number{
   return getTriggerActions()
 }
  setBeautyPackageByPath(type:BeautyType|undefined, path: string) : boolean{
   return setBeautyPackageByPath(type, path)
 }
  setBeautyPackageByBuffer(type:BeautyType|undefined, buffer: ArrayBuffer|null) : boolean{
   return setBeautyPackageByBuffer(type, buffer)
 }
  setBeautyMode(type:BeautyType|undefined,mode: number|undefined) : boolean{
   return setBeautyMode(type, mode)
 }
  setBeautyStrength(type:BeautyType|undefined,value: number|undefined) : boolean{
   return setBeautyStrength(type, value)
 }
  setBeautyParam(type:BeautyParamType,value: number|undefined) : boolean{
   return setBeautyParam(type, value)
 }
  getOverlappedBeautyInfo() : EffectBeautyInfo[]{
   return getOverlappedBeautyInfo()
 }
  process(srcBuffer: ArrayBuffer|null, format:PixelFormat,width:number,height:number,stride:number,rotate:RotateType,mirror:boolean,
   time_stamp:number, outBuffer:ArrayBuffer|null, outFormat:PixelFormat, orientation:RotateType, isOrigin:boolean,immediately:boolean,customEvent:number) : boolean{
   return process(srcBuffer, format,width,height,stride,rotate,mirror,
   time_stamp, outBuffer, outFormat, orientation, isOrigin,immediately,customEvent)
 }
  processASync(srcBuffer: ArrayBuffer|null, format:PixelFormat,width:number,height:number,stride:number,rotate:RotateType,mirror:boolean,
   time_stamp:number, outBuffer:ArrayBuffer|null, outFormat:PixelFormat, orientation:RotateType, isOrigin:boolean,immediately:boolean) : Promise<boolean>{
   return processASync(srcBuffer, format,width,height,stride,rotate,mirror,
   time_stamp, outBuffer, outFormat, orientation, isOrigin,immediately)
 }
  makeCurrent() : boolean{
   return makeCurrent()
 }
  makeEmpty() : boolean{
   return makeEmpty()
 }

  updateWindowSize(width:number,height:number) : void{
   return updateWindowSize(width, height)
 }
  setResizingMode(mode:RenderingResizingMode) : void{
   return setResizingMode(mode)
 }
  resetPixelReader() : boolean{
   return resetPixelReader()
 }
  get3DBeautyParts() : st_effect_3D_beauty_part_info_t[]{
   return get3DBeautyParts()
 }
  set3dBeautyPartsStrength(parts: st_effect_3D_beauty_part_info_t[]) : number{
   return set3dBeautyPartsStrength(parts)
 }
  changePackageBg(packageId:number|undefined, image:st_image_t) : number{
   return changePackageBg(packageId,image)
 }
  setBodyBeauty(param:BodyBeautyParam, path: string) : boolean{
   return setBodyBeauty(param, path)
 }
  updateFaceMeshList(value: MeshType) : number{
   return updateFaceMeshList(value)
 }
  setSoundLoadCallback(callback:Object) : number{
   return setSoundLoadCallback(callback)
 }
  setSoundPlayCallback(callback:Object) : number{
   return setSoundPlayCallback(callback)
 }
  setSoundStopCallback(callback:Object) : number{
   return setSoundStopCallback(callback)
 }
  setSoundPauseCallback(callback:Object) : number{
   return setSoundPauseCallback(callback)
 }
  setSoundResumeCallback(callback:Object) : number{
   return setSoundResumeCallback(callback)
 }
  destroy():void{
   destroy()
  }
 addFaceAttributeModel(path:string) : boolean{
  return addFaceAttributeModel(path)
 }
 getDetectResult(image:st_image_t, rotate:RotateType, mirror: boolean) : DetectResult|null{
  return getDetectResult(image,rotate,mirror)
 }
 humanActionDetect(image:st_image_t, rotate:RotateType, detectConfig:bigint, mirror: boolean) : HumanActionDetectResult|null{
  return humanActionDetect(image,rotate,detectConfig,mirror)
 }
 setBodyBeautyStrengthByBodyId(type:BeautyType, value: number, body_id: number) : boolean{
    return setBodyBeautyStrengthByBodyId(type, value, body_id)
 }
 clearBodyBeautyStrengthByBodyId(body_id: number) : boolean{
    return clearBodyBeautyStrengthByBodyId(body_id)
 }
 getBodyBeautyStrengthByBodyId(type:BeautyType, body_id: number) : number|null{
    return getBodyBeautyStrengthByBodyId(type, body_id)
 }
 setFaceBeautyStrengthByFaceId(type:BeautyType, value: number, body_id: number) : boolean{
    return setFaceBeautyStrengthByFaceId(type, value, body_id)
 }
  clearFaceBeautyStrengthByFaceId(face_id: number) : boolean{
    return clearFaceBeautyStrengthByFaceId(face_id)
 }
}
export default new STEffects()


