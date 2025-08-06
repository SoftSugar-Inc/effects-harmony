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
     
    static napi_value ndk_getOverlappedBeautyInfo(napi_env env, napi_callback_info info);
     
    static napi_value ndk_process(napi_env env, napi_callback_info info);
    static napi_value ndk_processASync(napi_env env, napi_callback_info info);
    
    static napi_value ndk_makeCurrent(napi_env env, napi_callback_info info);
    static napi_value ndk_makeEmpty(napi_env env, napi_callback_info info);
    
    static napi_value ndk_updateWindowSize(napi_env env, napi_callback_info info);
    static napi_value ndk_setResizingMode(napi_env env, napi_callback_info info);
    static napi_value ndk_resetPixelReader(napi_env env, napi_callback_info info);
    
};

}

#endif //EFFECTSHARMONY_STMOBILEWRAPPERNAPI_H
