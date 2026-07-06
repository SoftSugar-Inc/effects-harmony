//
// Created on 2024/12/17.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "sdk/wrapper/STMobileWrapper.h"

#include <napi/native_api.h>

#ifndef EFFECTSHARMONY_STMOBILEWRAPPERNAPI_H
#define EFFECTSHARMONY_STMOBILEWRAPPERNAPI_H
namespace GLContextManager{

class  STMobileWrapperNapi{
    public:
    static mobile_wrapper::STMobileWrapper *wrapper;
    static void DefinePropertiesExport(napi_env env, napi_value exports);
    


private:
    static napi_value ndk_InitializeByBuffer(napi_env env, napi_callback_info info);
    static napi_value ndk_InitializeByMode(napi_env env, napi_callback_info info);
     
    static napi_value ndk_checkLicenseByPath(napi_env env, napi_callback_info info);
    static napi_value ndk_checkLicenseByBuffer(napi_env env, napi_callback_info info);
     
    static napi_value ndk_addSubModelByPath(napi_env env, napi_callback_info info);
    static napi_value ndk_addSubModelByBuffer(napi_env env, napi_callback_info info);
    static napi_value ndk_addAnimalSubModelByPath(napi_env env, napi_callback_info info);
    static napi_value ndk_addAnimalSubModelByBuffer(napi_env env, napi_callback_info info);
    static napi_value ndk_addFaceAttributeModel(napi_env env, napi_callback_info info);
    
    static napi_value ndk_resetHumanAction(napi_env env, napi_callback_info info);
    static napi_value ndk_setParamByEffectParam(napi_env env, napi_callback_info info);
    static napi_value ndk_setParamByHumanActionParam(napi_env env, napi_callback_info info);
    static napi_value ndk_addPackageByPath(napi_env env, napi_callback_info info);
    static napi_value ndk_addPackageByBuffer(napi_env env, napi_callback_info info);
    static napi_value ndk_changePackageByPath(napi_env env, napi_callback_info info);
    static napi_value ndk_changePackageByBuffer(napi_env env, napi_callback_info info);
    static napi_value ndk_removePackage(napi_env env, napi_callback_info info);
    static napi_value ndk_clearPackages(napi_env env, napi_callback_info info);
     
    static napi_value ndk_setPackageBeautyStrength(napi_env env, napi_callback_info info);
    static napi_value ndk_replayPackage(napi_env env, napi_callback_info info);
     
    static napi_value ndk_getDetectConfig(napi_env env, napi_callback_info info);
    static napi_value ndk_getCustomEventConfig(napi_env env, napi_callback_info info);
    static napi_value ndk_getTriggerActions(napi_env env, napi_callback_info info);
     
    static napi_value ndk_setBeautyPackageByPath(napi_env env, napi_callback_info info);
    static napi_value ndk_setBeautyPackageByBuffer(napi_env env, napi_callback_info info);
    static napi_value ndk_setBeautyMode(napi_env env, napi_callback_info info);
    static napi_value ndk_setBeautyStrength(napi_env env, napi_callback_info info);
    static napi_value ndk_setBeautyParam(napi_env env, napi_callback_info info);
    
    static napi_value ndk_setBodyBeauty(napi_env env, napi_callback_info info);
    
    // 多人美颜/美体接口 Multi-person beauty interfaces
    static napi_value ndk_setFaceBeautyStrengthByFaceId(napi_env env, napi_callback_info info);
    static napi_value ndk_clearFaceBeautyStrengthByFaceId(napi_env env, napi_callback_info info);
    static napi_value ndk_setBodyBeautyStrengthByBodyId(napi_env env, napi_callback_info info);
    static napi_value ndk_clearBodyBeautyStrengthByBodyId(napi_env env, napi_callback_info info);
    static napi_value ndk_getBodyBeautyStrengthByBodyId(napi_env env, napi_callback_info info);
    
    static napi_value ndk_updateFaceMeshList(napi_env env, napi_callback_info info);
    static napi_value ndk_get3DBeautyParts(napi_env env, napi_callback_info info);
    static napi_value ndk_set3dBeautyPartsStrength(napi_env env, napi_callback_info info);
    
    static napi_value ndk_changePackageBg(napi_env env, napi_callback_info info);
    static napi_value ndk_getDetectResult(napi_env env, napi_callback_info info);
    
    // st_mobile_human_action_detect 对外接口 - 提供完整检测结果
    static napi_value ndk_humanActionDetect(napi_env env, napi_callback_info info);
     
    static napi_value ndk_getOverlappedBeautyInfo(napi_env env, napi_callback_info info);
     
    static napi_value ndk_process(napi_env env, napi_callback_info info);
    static napi_value ndk_processASync(napi_env env, napi_callback_info info);
    
    static napi_value ndk_makeCurrent(napi_env env, napi_callback_info info);
    static napi_value ndk_makeEmpty(napi_env env, napi_callback_info info);
    
    static napi_value ndk_updateWindowSize(napi_env env, napi_callback_info info);
    static napi_value ndk_setResizingMode(napi_env env, napi_callback_info info);
    static napi_value ndk_resetPixelReader(napi_env env, napi_callback_info info);
    
    static napi_value ndk_setSoundLoadCallback(napi_env env, napi_callback_info info);
    static napi_value ndk_setSoundPlayCallback(napi_env env, napi_callback_info info);
    static napi_value ndk_setSoundStopCallback(napi_env env, napi_callback_info info);
    static napi_value ndk_setSoundPauseCallback(napi_env env, napi_callback_info info);
    static napi_value ndk_setSoundResumeCallback(napi_env env, napi_callback_info info);
    
    static napi_value ndk_destroy(napi_env env, napi_callback_info info);
    
};

}

#endif //EFFECTSHARMONY_STMOBILEWRAPPERNAPI_H
