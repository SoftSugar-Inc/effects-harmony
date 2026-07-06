//
// Created on 2024/12/17.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include "./log/ohos_log.h"
#include <cstdint>
#include <thread>
#include "STMobileWrapperNapi.h"
#include "sdk/wrapper/AudioManager.h"
#include "sdk/wrapper/STMobileWrapper.h"


namespace GLContextManager{
mobile_wrapper::STMobileWrapper *STMobileWrapperNapi::wrapper = nullptr;

void STMobileWrapperNapi::DefinePropertiesExport(napi_env env, napi_value exports) {
    if ((env == nullptr) || (exports == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, "[STMobileWrapperNapi]", "env or exports is null");
        return;
    }
    napi_property_descriptor desc[] = {
        {"InitializeByBuffer", nullptr, STMobileWrapperNapi::ndk_InitializeByBuffer, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"InitializeByMode", nullptr, STMobileWrapperNapi::ndk_InitializeByMode, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"checkLicenseByPath", nullptr, STMobileWrapperNapi::ndk_checkLicenseByPath, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"checkLicenseByBuffer", nullptr, STMobileWrapperNapi::ndk_checkLicenseByBuffer, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"addSubModelByPath", nullptr, STMobileWrapperNapi::ndk_addSubModelByPath, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"addSubModelByBuffer", nullptr, STMobileWrapperNapi::ndk_addSubModelByBuffer, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        
         {"addAnimalSubModelByPath", nullptr, STMobileWrapperNapi::ndk_addAnimalSubModelByPath, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"addAnimalSubModelByBuffer", nullptr, STMobileWrapperNapi::ndk_addAnimalSubModelByBuffer, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        
        {"resetHumanAction", nullptr, STMobileWrapperNapi::ndk_resetHumanAction, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setParamByEffectParam", nullptr, STMobileWrapperNapi::ndk_setParamByEffectParam, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setParamByHumanActionParam", nullptr, STMobileWrapperNapi::ndk_setParamByHumanActionParam, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"addPackageByPath", nullptr, STMobileWrapperNapi::ndk_addPackageByPath, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"addPackageByBuffer", nullptr, STMobileWrapperNapi::ndk_addPackageByBuffer, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"changePackageByPath", nullptr, STMobileWrapperNapi::ndk_changePackageByPath, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"changePackageByBuffer", nullptr, STMobileWrapperNapi::ndk_changePackageByBuffer, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"removePackage", nullptr, STMobileWrapperNapi::ndk_removePackage, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"clearPackages", nullptr, STMobileWrapperNapi::ndk_clearPackages, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setPackageBeautyStrength", nullptr, STMobileWrapperNapi::ndk_setPackageBeautyStrength, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"replayPackage", nullptr, STMobileWrapperNapi::ndk_replayPackage, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"getDetectConfig", nullptr, STMobileWrapperNapi::ndk_getDetectConfig, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"getCustomEventConfig", nullptr, STMobileWrapperNapi::ndk_getCustomEventConfig, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"getTriggerActions", nullptr, STMobileWrapperNapi::ndk_getTriggerActions, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBeautyPackageByPath", nullptr, STMobileWrapperNapi::ndk_setBeautyPackageByPath, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBeautyPackageByBuffer", nullptr, STMobileWrapperNapi::ndk_setBeautyPackageByBuffer, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBeautyMode", nullptr, STMobileWrapperNapi::ndk_setBeautyMode, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBeautyStrength", nullptr, STMobileWrapperNapi::ndk_setBeautyStrength, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBeautyParam", nullptr, STMobileWrapperNapi::ndk_setBeautyParam, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"getOverlappedBeautyInfo", nullptr, STMobileWrapperNapi::ndk_getOverlappedBeautyInfo, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"process", nullptr, STMobileWrapperNapi::ndk_process, nullptr, nullptr, nullptr,
         napi_default, nullptr},
         {"processASync", nullptr, STMobileWrapperNapi::ndk_processASync, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"makeCurrent", nullptr, STMobileWrapperNapi::ndk_makeCurrent, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"makeEmpty", nullptr, STMobileWrapperNapi::ndk_makeEmpty, nullptr, nullptr, nullptr,
         napi_default, nullptr},
         {"updateWindowSize", nullptr, STMobileWrapperNapi::ndk_updateWindowSize, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setResizingMode", nullptr, STMobileWrapperNapi::ndk_setResizingMode, nullptr, nullptr, nullptr,
         napi_default, nullptr},
         {"resetPixelReader", nullptr, STMobileWrapperNapi::ndk_resetPixelReader, nullptr, nullptr, nullptr,
         napi_default, nullptr},
         {"setSoundLoadCallback", nullptr, STMobileWrapperNapi::ndk_setSoundLoadCallback, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setSoundPlayCallback", nullptr, STMobileWrapperNapi::ndk_setSoundPlayCallback, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setSoundStopCallback", nullptr, STMobileWrapperNapi::ndk_setSoundStopCallback, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setSoundPauseCallback", nullptr, STMobileWrapperNapi::ndk_setSoundPauseCallback, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setSoundResumeCallback", nullptr, STMobileWrapperNapi::ndk_setSoundResumeCallback, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        
        {"updateFaceMeshList", nullptr, STMobileWrapperNapi::ndk_updateFaceMeshList, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"set3dBeautyPartsStrength", nullptr, STMobileWrapperNapi::ndk_set3dBeautyPartsStrength, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"get3DBeautyParts", nullptr, STMobileWrapperNapi::ndk_get3DBeautyParts, nullptr, nullptr, nullptr,
         napi_default, nullptr},
         {"changePackageBg", nullptr, STMobileWrapperNapi::ndk_changePackageBg, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"getDetectResult", nullptr, STMobileWrapperNapi::ndk_getDetectResult, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"humanActionDetect", nullptr, STMobileWrapperNapi::ndk_humanActionDetect, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"addFaceAttributeModel", nullptr, STMobileWrapperNapi::ndk_addFaceAttributeModel, nullptr, nullptr, nullptr,
         napi_default, nullptr},
         {"setBodyBeauty", nullptr, STMobileWrapperNapi::ndk_setBodyBeauty, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        // 多人美颜/美体接口 Multi-person beauty interfaces
        {"setFaceBeautyStrengthByFaceId", nullptr, STMobileWrapperNapi::ndk_setFaceBeautyStrengthByFaceId, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"clearFaceBeautyStrengthByFaceId", nullptr, STMobileWrapperNapi::ndk_clearFaceBeautyStrengthByFaceId, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBodyBeautyStrengthByBodyId", nullptr, STMobileWrapperNapi::ndk_setBodyBeautyStrengthByBodyId, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"clearBodyBeautyStrengthByBodyId", nullptr, STMobileWrapperNapi::ndk_clearBodyBeautyStrengthByBodyId, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"getBodyBeautyStrengthByBodyId", nullptr, STMobileWrapperNapi::ndk_getBodyBeautyStrengthByBodyId, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"destroy", nullptr, STMobileWrapperNapi::ndk_destroy, nullptr, nullptr, nullptr,
         napi_default, nullptr},
    };
    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok) {
        LOGE("napi_define_properties failed");
        return;
    }
}

napi_value STMobileWrapperNapi::ndk_InitializeByBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

   // 检查参数是否为ArrayBuffer
    bool isArraybuffer = false;
    napi_is_arraybuffer(env, args[0], &isArraybuffer);
    if (!isArraybuffer) {
        napi_throw_type_error(env, nullptr, "Argument must be an ArrayBuffer");
        return nullptr;
    }
    void *data = nullptr;
    size_t byteLength = 0;
    // 获取ArrayBuffer的底层数据缓冲区和长度
    napi_status status = napi_get_arraybuffer_info(env, args[0], &data, &byteLength);
    if (status != napi_ok) {
        napi_throw_error(env, nullptr, "Failed to get ArrayBuffer info");
        return nullptr;
    }
    
    bool result = wrapper->Initialize((const char *)data, (unsigned int)byteLength);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_InitializeByMode(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t value = 0;
    napi_status status = napi_get_value_int32(env, args[0], &value);
    if (status != napi_ok) {
        LOGE("ndk_InitializeByMode error %d", status);
        return nullptr;
    }
    bool result = wrapper->Initialize((mobile_wrapper::STMobileWrapper::EffectsMode)value);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_checkLicenseByPath(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length = 0;
    napi_status status = napi_get_value_string_utf8(env, args[0], nullptr, 0, &length);
    // 传入一个非字符串 napi_get_value_string_utf8接口会返回napi_string_expected
    if (status != napi_ok) {
        LOGE("ndk_checkLicenseByPath error %d", status);
        return nullptr;
    }
    char* buf = new char[length + 1];
    napi_get_value_string_utf8(env, args[0], buf, length + 1, &length);
    bool result = mobile_wrapper::STMobileWrapper::checkLicense(buf);
    delete[] buf;
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_checkLicenseByBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length;
    void *data = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status  status = napi_get_arraybuffer_info(env, args[0], &data, &length);
    if (status != napi_ok) {
         LOGE("ndk_checkLicenseByBuffer error %d", status);
    }
    bool result = mobile_wrapper::STMobileWrapper::checkLicense((const char *)data, length);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_addSubModelByPath(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length = 0;
    napi_status status = napi_get_value_string_utf8(env, args[0], nullptr, 0, &length);
    // 传入一个非字符串 napi_get_value_string_utf8接口会返回napi_string_expected
    if (status != napi_ok) {
        LOGE("ndk_addSubModelByPath error %d", status);
        return nullptr;
    }
    char* buf = new char[length + 1];
    napi_get_value_string_utf8(env, args[0], buf, length + 1, &length);
    bool result = wrapper->addSubModel(buf);
    delete[] buf;
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
 napi_value STMobileWrapperNapi::ndk_addSubModelByBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // 检查参数是否为ArrayBuffer
    bool isArraybuffer = false;
    napi_is_arraybuffer(env, args[0], &isArraybuffer);
    if (!isArraybuffer) {
        napi_throw_type_error(env, nullptr, "Argument must be an ArrayBuffer");
        return nullptr;
    }
    void *data = nullptr;
    size_t byteLength = 0;
    // 获取ArrayBuffer的底层数据缓冲区和长度
    napi_status status = napi_get_arraybuffer_info(env, args[0], &data, &byteLength);
    if (status != napi_ok) {
        napi_throw_error(env, nullptr, "Failed to get ArrayBuffer info");
        return nullptr;
    }
  
    bool result = wrapper->addSubModel((const unsigned char*)data, byteLength);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}   

napi_value STMobileWrapperNapi::ndk_addAnimalSubModelByPath(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length = 0;
    napi_status status = napi_get_value_string_utf8(env, args[0], nullptr, 0, &length);
    // 传入一个非字符串 napi_get_value_string_utf8接口会返回napi_string_expected
    if (status != napi_ok) {
        LOGE("ndk_addAnimalSubModelByPath error %d", status);
        return nullptr;
    }
    char* buf = new char[length + 1];
    napi_get_value_string_utf8(env, args[0], buf, length + 1, &length);
    bool result = wrapper->addAnimalSubModel(buf);
    delete[] buf;
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
 napi_value STMobileWrapperNapi::ndk_addAnimalSubModelByBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // 检查参数是否为ArrayBuffer
    bool isArraybuffer = false;
    napi_is_arraybuffer(env, args[0], &isArraybuffer);
    if (!isArraybuffer) {
        napi_throw_type_error(env, nullptr, "Argument must be an ArrayBuffer");
        return nullptr;
    }
    void *data = nullptr;
    size_t byteLength = 0;
    // 获取ArrayBuffer的底层数据缓冲区和长度
    napi_status status = napi_get_arraybuffer_info(env, args[0], &data, &byteLength);
    if (status != napi_ok) {
        napi_throw_error(env, nullptr, "Failed to get ArrayBuffer info");
        return nullptr;
    }
  
    bool result = wrapper->addSubModel((const unsigned char*)data, byteLength);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
} 


napi_value STMobileWrapperNapi::ndk_addFaceAttributeModel(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length = 0;
    napi_status status = napi_get_value_string_utf8(env, args[0], nullptr, 0, &length);
    // 传入一个非字符串 napi_get_value_string_utf8接口会返回napi_string_expected
    if (status != napi_ok) {
        LOGE("ndk_addFaceAttributeModel error %d", status);
        return nullptr;
    }
    char* buf = new char[length + 1];
    napi_get_value_string_utf8(env, args[0], buf, length + 1, &length);
    bool result = wrapper->addFaceAttributeModel(buf);
    delete[] buf;
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_resetHumanAction(napi_env env, napi_callback_info info) {
    bool result = wrapper->resetHumanAction();
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_setParamByEffectParam(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setParamByEffectParam error %d", status);
        return nullptr;
    }
    double value = 0;
    status = napi_get_value_double(env, args[1], &value);
    if (status != napi_ok) {
        LOGE("ndk_setParamByEffectParam error %d", status);
        return nullptr;
    }
    bool result = wrapper->setParam((st_effect_param_t)param, value);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_setParamByHumanActionParam(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setParamByHumanActionParam error %d", status);
        return nullptr;
    }
    double value = 0;
    status = napi_get_value_double(env, args[1], &value);
    if (status != napi_ok) {
        LOGE("ndk_setParamByHumanActionParam error %d", status);
        return nullptr;
    }
    bool result = wrapper->setParam((st_human_action_param_type)param, value);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_addPackageByPath(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length = 0;
    napi_status status = napi_get_value_string_utf8(env, args[0], nullptr, 0, &length);
    // 传入一个非字符串 napi_get_value_string_utf8接口会返回napi_string_expected
    if (status != napi_ok) {
        LOGE("ndk_addPackageByPath error %d", status);
        return nullptr;
    }
    char* buf = new char[length + 1];
    napi_get_value_string_utf8(env, args[0], buf, length + 1, &length);
    int result = wrapper->addPackage(buf);
    delete[] buf;
    
    // 创建返回结果并返回
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_addPackageByBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length;
    void *data = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status  status = napi_get_arraybuffer_info(env, args[0], &data, &length);
    if (status != napi_ok) {
         LOGE("ndk_addPackageByBuffer error %d", status);
    }
  
    int result = wrapper->addPackage((const char *)data, (unsigned int)length);
    // 创建返回结果并返回
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_changePackageByPath(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length = 0;
    napi_status status = napi_get_value_string_utf8(env, args[0], nullptr, 0, &length);
    // 传入一个非字符串 napi_get_value_string_utf8接口会返回napi_string_expected
    if (status != napi_ok) {
        LOGE("ndk_changePackageByPath error %d", status);
        return nullptr;
    }
    char* buf = new char[length + 1];
    napi_get_value_string_utf8(env, args[0], buf, length + 1, &length);
    int result = wrapper->changePackage(buf);
    delete[] buf;
    
    // 创建返回结果并返回
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_changePackageByBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length;
    void *data = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status  status = napi_get_arraybuffer_info(env, args[0], &data, &length);
    if (status != napi_ok) {
         LOGE("ndk_changePackageByBuffer error %d", status);
    }
  
    int result = wrapper->changePackage((const char *)data, (unsigned int)length);
    // 创建返回结果并返回
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_removePackage(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_removePackage error %d", status);
        return nullptr;
    }
   
    bool result = wrapper->removePackage(param);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_clearPackages(napi_env env, napi_callback_info info) {
    bool result = wrapper->clearPackages();
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_setPackageBeautyStrength(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setPackageBeautyStrength error %d", status);
        return nullptr;
    }
    
    int32_t type = 0;
    status = napi_get_value_int32(env, args[1], &type);
    if (status != napi_ok) {
        LOGE("ndk_setPackageBeautyStrength error %d", status);
        return nullptr;
    }
    
    double value = 0;
    status = napi_get_value_double(env, args[2], &value);
    if (status != napi_ok) {
        LOGE("ndk_setPackageBeautyStrength error %d", status);
        return nullptr;
    }
    bool result = wrapper->setPackageBeautyStrength(param, (st_effect_beauty_group_t)type, value);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_replayPackage(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_replayPackage error %d", status);
        return nullptr;
    }
   
    bool result = wrapper->replayPackage(param);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}     

napi_value STMobileWrapperNapi::ndk_getDetectConfig(napi_env env, napi_callback_info info) {

    uint64_t result = wrapper->getDetectConfig();
    // 创建返回结果并返回
    napi_value st_result;
    napi_create_bigint_uint64(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_getCustomEventConfig(napi_env env, napi_callback_info info) {

    uint64_t result = wrapper->getCustomEventConfig();
    // 创建返回结果并返回
    napi_value st_result;
    napi_create_int64(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_getTriggerActions(napi_env env, napi_callback_info info) {

    uint64_t result = wrapper->getTriggerActions();
    // 创建返回结果并返回
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_setBeautyPackageByPath(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setBeautyPackageByPath error %d", status);
        return nullptr;
    }

    size_t length = 0;
    status = napi_get_value_string_utf8(env, args[1], nullptr, 0, &length);
    // 传入一个非字符串 napi_get_value_string_utf8接口会返回napi_string_expected
    if (status != napi_ok) {
        LOGE("ndk_setBeautyPackageByPath error %d", status);
        return nullptr;
    }
    char* buf = new char[length + 1];
    napi_get_value_string_utf8(env, args[1], buf, length + 1, &length);
    
    bool result = wrapper->setBeautyPackage((st_effect_beauty_type_t)param, buf);
    delete[] buf;
    // 创建返回结果并返回
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}
     
napi_value STMobileWrapperNapi::ndk_setBeautyPackageByBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setBeautyPackageByBuffer error %d", status);
        return nullptr;
    }
    
    size_t length;
    void *data = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    status = napi_get_arraybuffer_info(env, args[1], &data, &length);
    if (status != napi_ok) {
         LOGE("ndk_setBeautyPackageByBuffer error %d", status);
    }
    
    bool result = wrapper->setBeautyPackage((st_effect_beauty_type_t)param, (const char *)data, length);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_setBeautyMode(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setBeautyMode error %d", status);
        return nullptr;
    }
    
    int32_t mode = 0;
    status = napi_get_value_int32(env, args[1], &mode);
    if (status != napi_ok) {
        LOGE("ndk_setBeautyMode error %d", status);
        return nullptr;
    }
    bool result = wrapper->setBeautyMode((st_effect_beauty_type_t)param, mode);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_setBeautyStrength(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setBeautyStrength error %d", status);
        return nullptr;
    }
    double value = 0;
    status = napi_get_value_double(env, args[1], &value);
    if (status != napi_ok) {
        LOGE("ndk_setBeautyStrength error %d", status);
        return nullptr;
    }
    bool result = wrapper->setBeautyStrength((st_effect_beauty_type_t)param, value);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_setBeautyParam(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setBeautyParam error %d", status);
        return nullptr;
    }
    double value = 0;
    status = napi_get_value_double(env, args[1], &value);
    if (status != napi_ok) {
        LOGE("ndk_setBeautyParam error %d", status);
        return nullptr;
    }
    bool result = wrapper->setBeautyParam((st_effect_beauty_param_t)param, value);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_setBodyBeauty(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setBodyBeauty error %d", status);
        return nullptr;
    }
    size_t length = 0;
    status = napi_get_value_string_utf8(env, args[1], nullptr, 0, &length);
    // 传入一个非字符串 napi_get_value_string_utf8接口会返回napi_string_expected
    if (status != napi_ok) {
        LOGE("ndk_setBodyBeauty error %d", status);
        return nullptr;
    }
    char* buf = new char[length + 1];
    napi_get_value_string_utf8(env, args[1], buf, length + 1, &length);
    
    
    bool result = wrapper->setBodyBeauty((st_effect_body_beautify_aux_type_t)param, buf);
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_updateFaceMeshList(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    int result = wrapper->updateFaceMeshList(param);
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_get3DBeautyParts(napi_env env, napi_callback_info info) {
 
    std::vector<st_effect_3D_beauty_part_info_t> result = wrapper->get3DBeautyParts();
    // 创建返回结果并返回
    napi_value array;
    napi_create_array_with_length(env, result.size(), &array);
    for (int i = 0; i < result.size(); i++) {
        napi_value element;
        napi_create_object(env, &element);
    
        napi_value value;
        
        napi_create_string_utf8(env, (const char *)result[i].name, NAPI_AUTO_LENGTH, &value);
        napi_set_named_property(env, element, "name", value);
    
        napi_create_int32(env, result[i].part_id, &value);
        napi_set_named_property(env, element, "part_id", value);
        napi_create_double(env, result[i].strength, &value);
        napi_set_named_property(env, element, "strength", value);
        napi_create_double(env, result[i].strength_min, &value);
        napi_set_named_property(env, element, "strength_min", value);
        napi_create_double(env, result[i].strength_max, &value);
        napi_set_named_property(env, element, "strength_max", value);
        
        napi_set_element(env, array, i, element);
    }
    return array;
}

napi_value STMobileWrapperNapi::ndk_set3dBeautyPartsStrength(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    uint32_t arrayLength;
    napi_get_array_length(env,  args[0], &arrayLength);
    
    std::vector<st_effect_3D_beauty_part_info_t> part_info(arrayLength);
     for (int i = 0; i < arrayLength; i++) {
        napi_value element;
        napi_get_element(env, args[0], i, &element);
        
        napi_value value;
        napi_get_named_property(env, element, "name", &value);
        size_t strLength = 0;
        napi_get_value_string_utf8(env, value, part_info.data()[i].name, EFFECT_MAX_NAME_LEN, &strLength);
        
        napi_get_named_property(env, element, "part_id", &value);
        napi_get_value_int32(env, value, &part_info.data()[i].part_id);
        double getValue = 0;
        napi_get_named_property(env, element, "strength", &value);
        napi_get_value_double(env, value, &getValue);
        part_info.data()[i].strength = getValue;
         napi_get_named_property(env, element, "strength_min", &value);
        napi_get_value_double(env, value, &getValue);
        part_info.data()[i].strength_min = getValue;
         napi_get_named_property(env, element, "strength_max", &value);
        napi_get_value_double(env, value, &getValue);
        part_info.data()[i].strength_max = getValue;
    }
    int result = wrapper->set3dBeautyPartsStrength(part_info);
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_makeCurrent(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_makeCurrent wrapper is null");
        napi_value st_result;
        bool false_result = false;
        napi_get_boolean(env, false_result, &st_result);
        return st_result;
    }
    bool result = wrapper->makeCurrent();
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_status Get_st_image_t(napi_env env, napi_value jsObj, st_image_t* result) {
    napi_status status;
    // 提取 left
    napi_value data,pixel_format,width,height,stride,time_stamp;
    status = napi_get_named_property(env, jsObj, "data", &data);
    size_t byteLength = 0;
    status = napi_get_arraybuffer_info(env, data, reinterpret_cast<void**>(&result->data), &byteLength);
    status = napi_get_named_property(env, jsObj, "pixel_format", &pixel_format);
    status = napi_get_value_int32(env, pixel_format, reinterpret_cast<int32_t*>(&result->pixel_format));
    status = napi_get_named_property(env, jsObj, "width", &width);
    status = napi_get_value_int32(env, width, &result->width);
    status = napi_get_named_property(env, jsObj, "height", &height);
    status = napi_get_value_int32(env, height, &result->height);
    status = napi_get_named_property(env, jsObj, "stride", &stride);
    status = napi_get_value_int32(env, stride, &result->stride);
    status = napi_get_named_property(env, jsObj, "time_stamp", &time_stamp);
    status = napi_get_value_double(env, time_stamp, &result->time_stamp);
    return status;
}

napi_value STMobileWrapperNapi::ndk_changePackageBg(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    int pkgId = 0;
    napi_get_value_int32(env, args[0], &pkgId);
    st_image_t inImage = {};
    Get_st_image_t(env,args[1],&inImage);
    
    int result = wrapper->changePackageBg(pkgId, &inImage);
    napi_value st_result;
    napi_create_int32(env, result, &st_result);
    return st_result;
}

napi_value Convert_st_rect_tToJS(napi_env env, st_rect_t obj) {
    napi_value jsObj;
    napi_create_object(env, &jsObj);
    napi_value left;
    napi_create_int32(env, obj.left, &left);
    napi_set_named_property(env, jsObj, "left", left);
    napi_value top;
    napi_create_int32(env, obj.top, &top);
    napi_set_named_property(env, jsObj, "top", top);
    napi_value right;
    napi_create_int32(env, obj.right, &right);
    napi_set_named_property(env, jsObj, "right", right);
    napi_value bottom;
    napi_create_int32(env, obj.bottom, &bottom);
    napi_set_named_property(env, jsObj, "bottom", bottom);
    return jsObj;
}

napi_value STMobileWrapperNapi::ndk_getDetectResult(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_getDetectResult wrapper is null");
        return nullptr;
    }
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    st_image_t inImage = {};
    Get_st_image_t(env,args[0],&inImage);
    
    int32_t rotate = 0;
    napi_get_value_int32(env, args[1], &rotate);
    
    bool mirror = false;
    napi_get_value_bool(env, args[2], &mirror);
    
    st_effect_in_image_t image = {
        .image = inImage,
        .rotate = (st_rotate_type)rotate,
        .b_mirror = mirror
    };
    
    st_mobile_human_action_t humanAction {};
    st_mobile_attributes_t* faceAttributes = nullptr;
    std::array<st_face_shape_t, 1> faceShape;
    
    bool result = wrapper->getDetectResult(&image, &humanAction, &faceAttributes, faceShape.data());
    if (result && humanAction.face_count > 0 && faceAttributes!= nullptr) {
        napi_value jsObj;
        napi_create_object(env, &jsObj);
        napi_set_named_property(env, jsObj, "faceRect", Convert_st_rect_tToJS(env, humanAction.p_faces[0].face106.rect));
        
        napi_value yaw;
        napi_create_double(env, humanAction.p_faces[0].face106.yaw, &yaw);
        napi_set_named_property(env, jsObj, "faceYaw", yaw);
        
        napi_value pitch;
        napi_create_double(env, humanAction.p_faces[0].face106.pitch, &pitch);
        napi_set_named_property(env, jsObj, "facePitch", pitch);
        
        napi_value shape;
        napi_create_int32(env, faceShape[0], &shape);
        napi_set_named_property(env, jsObj, "faceShape", shape);
        
        for (int i =0; i<faceAttributes[0].attribute_count; i++) {
            std::string category = std::string(faceAttributes[0].p_attributes[i].category);
            napi_value jsLabel;
            napi_create_string_utf8(env,faceAttributes[0].p_attributes[i].label, NAPI_AUTO_LENGTH, &jsLabel);
            if (category== "attractive") {
                napi_set_named_property(env, jsObj, "attractive", jsLabel);
            }else if (category== "age") {
                napi_set_named_property(env, jsObj, "age", jsLabel);
            }
            else if (category== "gender") {
                napi_set_named_property(env, jsObj, "gender", jsLabel);
            }
        }
        
        return jsObj;
    }
    return nullptr;
}

// 多人美颜/美体接口实现 Multi-person beauty interfaces implementation
napi_value STMobileWrapperNapi::ndk_setFaceBeautyStrengthByFaceId(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_setFaceBeautyStrength wrapper is null");
        napi_value st_result;
        napi_get_boolean(env, false, &st_result);
        return st_result;
    }
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setFaceBeautyStrength param error %d", status);
        return nullptr;
    }
    
    double value = 0;
    status = napi_get_value_double(env, args[1], &value);
    if (status != napi_ok) {
        LOGE("ndk_setFaceBeautyStrength value error %d", status);
        return nullptr;
    }
    
    int32_t face_id = 0;
    status = napi_get_value_int32(env, args[2], &face_id);
    if (status != napi_ok) {
        LOGE("ndk_setFaceBeautyStrength face_id error %d", status);
        return nullptr;
    }

    bool result = wrapper->setFaceBeautyStrength((st_effect_beauty_type_t)param, value, face_id);
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_clearFaceBeautyStrengthByFaceId(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_clearFaceBeautyStrength wrapper is null");
        napi_value st_result;
        napi_get_boolean(env, false, &st_result);
        return st_result;
    }
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t face_id = 0;
    napi_status status = napi_get_value_int32(env, args[0], &face_id);
    if (status != napi_ok) {
        LOGE("ndk_clearFaceBeautyStrength face_id error %d", status);
        return nullptr;
    }

    bool result = wrapper->clearFaceBeautyStrength(face_id);
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_setBodyBeautyStrengthByBodyId(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_setBodyBeautyStrengthByBodyId wrapper is null");
        napi_value st_result;
        napi_get_boolean(env, false, &st_result);
        return st_result;
    }
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_setBodyBeautyStrengthByBodyId param error %d", status);
        return nullptr;
    }
    
    double value = 0;
    status = napi_get_value_double(env, args[1], &value);
    if (status != napi_ok) {
        LOGE("ndk_setBodyBeautyStrengthByBodyId value error %d", status);
        return nullptr;
    }
    
    int32_t body_id = 0;
    status = napi_get_value_int32(env, args[2], &body_id);
    if (status != napi_ok) {
        LOGE("ndk_setBodyBeautyStrengthByBodyId body_id error %d", status);
        return nullptr;
    }

    bool result = wrapper->setBodyBeautyStrengthByBodyId((st_effect_beauty_type_t)param, value, body_id);
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_clearBodyBeautyStrengthByBodyId(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_clearBodyBeautyStrengthByBodyId wrapper is null");
        napi_value st_result;
        napi_get_boolean(env, false, &st_result);
        return st_result;
    }
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t body_id = 0;
    napi_status status = napi_get_value_int32(env, args[0], &body_id);
    if (status != napi_ok) {
        LOGE("ndk_clearBodyBeautyStrengthByBodyId body_id error %d", status);
        return nullptr;
    }

    bool result = wrapper->clearBodyBeautyStrengthByBodyId(body_id);
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_getBodyBeautyStrengthByBodyId(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_getBodyBeautyStrengthByBodyId wrapper is null");
        return nullptr;
    }
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t param = 0;
    napi_status status = napi_get_value_int32(env, args[0], &param);
    if (status != napi_ok) {
        LOGE("ndk_getBodyBeautyStrengthByBodyId param error %d", status);
        return nullptr;
    }
    
    int32_t body_id = 0;
    status = napi_get_value_int32(env, args[1], &body_id);
    if (status != napi_ok) {
        LOGE("ndk_getBodyBeautyStrengthByBodyId body_id error %d", status);
        return nullptr;
    }

    float value = 0;
    bool result = wrapper->getBodyBeautyStrengthByBodyId((st_effect_beauty_type_t)param, &value, body_id);
    if (!result) {
        return nullptr;
    }
    
    napi_value st_result;
    napi_create_double(env, value, &st_result);
    return st_result;
}

// st_mobile_human_action_detect 对外接口实现 - 提供完整检测结果
napi_value STMobileWrapperNapi::ndk_humanActionDetect(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_humanActionDetect wrapper is null");
        return nullptr;
    }
    size_t argc = 4;
    napi_value args[4] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    // 获取输入图像
    st_image_t inImage = {};
    Get_st_image_t(env, args[0], &inImage);
    
    // 获取旋转角度
    int32_t rotate = 0;
    napi_get_value_int32(env, args[1], &rotate);
    
    // 获取检测配置
    uint64_t detectConfig = 0;
    bool lossless = false;
    napi_get_value_bigint_uint64(env, args[2], &detectConfig, &lossless);
    
    // 获取镜像标志
    bool mirror = false;
    napi_get_value_bool(env, args[3], &mirror);
    
    // 准备 human_action 结果结构
    st_mobile_human_action_t humanAction = {};
    
    // 调用底层 process 方法进行人体行为检测
    bool result = wrapper->process(&inImage, (st_rotate_type)rotate, (uint64_t)detectConfig, &humanAction);
    
    if (!result) {
        LOGE("ndk_humanActionDetect process failed");
        return nullptr;
    }
    
    // 创建返回的 JS 对象
    napi_value jsResult;
    napi_create_object(env, &jsResult);
    
    // 设置 face_count
    napi_value faceCount;
    napi_create_int32(env, humanAction.face_count, &faceCount);
    napi_set_named_property(env, jsResult, "face_count", faceCount);
    
    // 设置 faces 数组
    napi_value facesArray;
    napi_create_array_with_length(env, humanAction.face_count, &facesArray);
    for (int i = 0; i < humanAction.face_count; i++) {
        napi_value faceObj;
        napi_create_object(env, &faceObj);
        
        // face106.rect
        napi_value rect;
        napi_create_object(env, &rect);
        napi_value left, top, right, bottom;
        napi_create_int32(env, humanAction.p_faces[i].face106.rect.left, &left);
        napi_create_int32(env, humanAction.p_faces[i].face106.rect.top, &top);
        napi_create_int32(env, humanAction.p_faces[i].face106.rect.right, &right);
        napi_create_int32(env, humanAction.p_faces[i].face106.rect.bottom, &bottom);
        napi_set_named_property(env, rect, "left", left);
        napi_set_named_property(env, rect, "top", top);
        napi_set_named_property(env, rect, "right", right);
        napi_set_named_property(env, rect, "bottom", bottom);
        napi_set_named_property(env, faceObj, "rect", rect);
        
        // face106.yaw, pitch, roll
        napi_value yaw, pitch, roll;
        napi_create_double(env, humanAction.p_faces[i].face106.yaw, &yaw);
        napi_create_double(env, humanAction.p_faces[i].face106.pitch, &pitch);
        napi_create_double(env, humanAction.p_faces[i].face106.roll, &roll);
        napi_set_named_property(env, faceObj, "yaw", yaw);
        napi_set_named_property(env, faceObj, "pitch", pitch);
        napi_set_named_property(env, faceObj, "roll", roll);
        
        // face106.score
        napi_value score;
        napi_create_double(env, humanAction.p_faces[i].face106.score, &score);
        napi_set_named_property(env, faceObj, "score", score);
        
        // face_id
        napi_value faceId;
        napi_create_int32(env, humanAction.p_faces[i].face106.ID, &faceId);
        napi_set_named_property(env, faceObj, "face_id", faceId);
        
        napi_set_element(env, facesArray, i, faceObj);
    }
    napi_set_named_property(env, jsResult, "faces", facesArray);
    
    // 设置 head_count
    napi_value headCount;
    napi_create_int32(env, humanAction.head_count, &headCount);
    napi_set_named_property(env, jsResult, "head_count", headCount);
    
    // 设置 hand_count
    napi_value handCount;
    napi_create_int32(env, humanAction.hand_count, &handCount);
    napi_set_named_property(env, jsResult, "hand_count", handCount);
    
    // 设置 hands 数组
    if (humanAction.hand_count > 0 && humanAction.p_hands != nullptr) {
        napi_value handsArray;
        napi_create_array_with_length(env, humanAction.hand_count, &handsArray);
        for (int i = 0; i < humanAction.hand_count; i++) {
            napi_value handObj;
            napi_create_object(env, &handObj);
            
            // hand id
            napi_value handId;
            napi_create_int32(env, humanAction.p_hands[i].id, &handId);
            napi_set_named_property(env, handObj, "id", handId);
            
            // hand rect
            napi_value handRect;
            napi_create_object(env, &handRect);
            napi_value hLeft, hTop, hRight, hBottom;
            napi_create_int32(env, humanAction.p_hands[i].rect.left, &hLeft);
            napi_create_int32(env, humanAction.p_hands[i].rect.top, &hTop);
            napi_create_int32(env, humanAction.p_hands[i].rect.right, &hRight);
            napi_create_int32(env, humanAction.p_hands[i].rect.bottom, &hBottom);
            napi_set_named_property(env, handRect, "left", hLeft);
            napi_set_named_property(env, handRect, "top", hTop);
            napi_set_named_property(env, handRect, "right", hRight);
            napi_set_named_property(env, handRect, "bottom", hBottom);
            napi_set_named_property(env, handObj, "rect", handRect);
            
            // hand_action
            napi_value handAction;
            napi_create_int64(env, (int64_t)humanAction.p_hands[i].hand_action, &handAction);
            napi_set_named_property(env, handObj, "hand_action", handAction);
            
            // score
            napi_value handScore;
            napi_create_double(env, humanAction.p_hands[i].score, &handScore);
            napi_set_named_property(env, handObj, "score", handScore);
            
            // left_right
            napi_value leftRight;
            napi_create_int32(env, humanAction.p_hands[i].left_right, &leftRight);
            napi_set_named_property(env, handObj, "left_right", leftRight);
            
            // key_points_count
            napi_value keyPointsCount;
            napi_create_int32(env, humanAction.p_hands[i].key_points_count, &keyPointsCount);
            napi_set_named_property(env, handObj, "key_points_count", keyPointsCount);
            
            // key_points array
            if (humanAction.p_hands[i].key_points_count > 0 && humanAction.p_hands[i].p_key_points != nullptr) {
                napi_value keyPointsArray;
                napi_create_array_with_length(env, humanAction.p_hands[i].key_points_count, &keyPointsArray);
                for (int j = 0; j < humanAction.p_hands[i].key_points_count; j++) {
                    napi_value pointObj;
                    napi_create_object(env, &pointObj);
                    napi_value px, py;
                    napi_create_double(env, humanAction.p_hands[i].p_key_points[j].x, &px);
                    napi_create_double(env, humanAction.p_hands[i].p_key_points[j].y, &py);
                    napi_set_named_property(env, pointObj, "x", px);
                    napi_set_named_property(env, pointObj, "y", py);
                    napi_set_element(env, keyPointsArray, j, pointObj);
                }
                napi_set_named_property(env, handObj, "key_points", keyPointsArray);
            }
            
            // skeleton_keypoints_count
            napi_value skeletonKpCount;
            napi_create_int32(env, humanAction.p_hands[i].skeleton_keypoints_count, &skeletonKpCount);
            napi_set_named_property(env, handObj, "skeleton_keypoints_count", skeletonKpCount);
            
            // skeleton_keypoints array
            if (humanAction.p_hands[i].skeleton_keypoints_count > 0 && humanAction.p_hands[i].p_skeleton_keypoints != nullptr) {
                napi_value skeletonKpArray;
                napi_create_array_with_length(env, humanAction.p_hands[i].skeleton_keypoints_count, &skeletonKpArray);
                for (int j = 0; j < humanAction.p_hands[i].skeleton_keypoints_count; j++) {
                    napi_value pointObj;
                    napi_create_object(env, &pointObj);
                    napi_value px, py;
                    napi_create_double(env, humanAction.p_hands[i].p_skeleton_keypoints[j].x, &px);
                    napi_create_double(env, humanAction.p_hands[i].p_skeleton_keypoints[j].y, &py);
                    napi_set_named_property(env, pointObj, "x", px);
                    napi_set_named_property(env, pointObj, "y", py);
                    napi_set_element(env, skeletonKpArray, j, pointObj);
                }
                napi_set_named_property(env, handObj, "skeleton_keypoints", skeletonKpArray);
            }
            
            // skeleton_3d_keypoints_count
            napi_value skeleton3dKpCount;
            napi_create_int32(env, humanAction.p_hands[i].skeleton_3d_keypoints_count, &skeleton3dKpCount);
            napi_set_named_property(env, handObj, "skeleton_3d_keypoints_count", skeleton3dKpCount);
            
            // skeleton_3d_keypoints array
            if (humanAction.p_hands[i].skeleton_3d_keypoints_count > 0 && humanAction.p_hands[i].p_skeleton_3d_keypoints != nullptr) {
                napi_value skeleton3dKpArray;
                napi_create_array_with_length(env, humanAction.p_hands[i].skeleton_3d_keypoints_count, &skeleton3dKpArray);
                for (int j = 0; j < humanAction.p_hands[i].skeleton_3d_keypoints_count; j++) {
                    napi_value pointObj;
                    napi_create_object(env, &pointObj);
                    napi_value px, py, pz;
                    napi_create_double(env, humanAction.p_hands[i].p_skeleton_3d_keypoints[j].x, &px);
                    napi_create_double(env, humanAction.p_hands[i].p_skeleton_3d_keypoints[j].y, &py);
                    napi_create_double(env, humanAction.p_hands[i].p_skeleton_3d_keypoints[j].z, &pz);
                    napi_set_named_property(env, pointObj, "x", px);
                    napi_set_named_property(env, pointObj, "y", py);
                    napi_set_named_property(env, pointObj, "z", pz);
                    napi_set_element(env, skeleton3dKpArray, j, pointObj);
                }
                napi_set_named_property(env, handObj, "skeleton_3d_keypoints", skeleton3dKpArray);
            }
            
            napi_set_element(env, handsArray, i, handObj);
        }
        napi_set_named_property(env, jsResult, "hands", handsArray);
    }
    
    // 设置 body_count
    napi_value bodyCount;
    napi_create_int32(env, humanAction.body_count, &bodyCount);
    napi_set_named_property(env, jsResult, "body_count", bodyCount);
    
    // 设置 bodys 数组
    if (humanAction.body_count > 0 && humanAction.p_bodys != nullptr) {
        napi_value bodysArray;
        napi_create_array_with_length(env, humanAction.body_count, &bodysArray);
        for (int i = 0; i < humanAction.body_count; i++) {
            napi_value bodyObj;
            napi_create_object(env, &bodyObj);
            
            // body id
            napi_value bodyId;
            napi_create_int32(env, humanAction.p_bodys[i].id, &bodyId);
            napi_set_named_property(env, bodyObj, "id", bodyId);
            
            // key_points_count
            napi_value kpCount;
            napi_create_int32(env, humanAction.p_bodys[i].key_points_count, &kpCount);
            napi_set_named_property(env, bodyObj, "key_points_count", kpCount);
            
            // key_points array
            if (humanAction.p_bodys[i].key_points_count > 0 && humanAction.p_bodys[i].p_key_points != nullptr) {
                napi_value keyPointsArray;
                napi_create_array_with_length(env, humanAction.p_bodys[i].key_points_count, &keyPointsArray);
                for (int j = 0; j < humanAction.p_bodys[i].key_points_count; j++) {
                    napi_value pointObj;
                    napi_create_object(env, &pointObj);
                    napi_value px, py;
                    napi_create_double(env, humanAction.p_bodys[i].p_key_points[j].x, &px);
                    napi_create_double(env, humanAction.p_bodys[i].p_key_points[j].y, &py);
                    napi_set_named_property(env, pointObj, "x", px);
                    napi_set_named_property(env, pointObj, "y", py);
                    napi_set_element(env, keyPointsArray, j, pointObj);
                }
                napi_set_named_property(env, bodyObj, "key_points", keyPointsArray);
            }
            
            // key_points_score array
            if (humanAction.p_bodys[i].key_points_count > 0 && humanAction.p_bodys[i].p_key_points_score != nullptr) {
                napi_value kpScoreArray;
                napi_create_array_with_length(env, humanAction.p_bodys[i].key_points_count, &kpScoreArray);
                for (int j = 0; j < humanAction.p_bodys[i].key_points_count; j++) {
                    napi_value scoreVal;
                    napi_create_double(env, humanAction.p_bodys[i].p_key_points_score[j], &scoreVal);
                    napi_set_element(env, kpScoreArray, j, scoreVal);
                }
                napi_set_named_property(env, bodyObj, "key_points_score", kpScoreArray);
            }
            
            // contour_points_count
            napi_value contourPCount;
            napi_create_int32(env, humanAction.p_bodys[i].contour_points_count, &contourPCount);
            napi_set_named_property(env, bodyObj, "contour_points_count", contourPCount);
            
            // contour_points array
            if (humanAction.p_bodys[i].contour_points_count > 0 && humanAction.p_bodys[i].p_contour_points != nullptr) {
                napi_value contourPointsArray;
                napi_create_array_with_length(env, humanAction.p_bodys[i].contour_points_count, &contourPointsArray);
                for (int j = 0; j < humanAction.p_bodys[i].contour_points_count; j++) {
                    napi_value pointObj;
                    napi_create_object(env, &pointObj);
                    napi_value px, py;
                    napi_create_double(env, humanAction.p_bodys[i].p_contour_points[j].x, &px);
                    napi_create_double(env, humanAction.p_bodys[i].p_contour_points[j].y, &py);
                    napi_set_named_property(env, pointObj, "x", px);
                    napi_set_named_property(env, pointObj, "y", py);
                    napi_set_element(env, contourPointsArray, j, pointObj);
                }
                napi_set_named_property(env, bodyObj, "contour_points", contourPointsArray);
            }
            
            // contour_points_score array
            if (humanAction.p_bodys[i].contour_points_count > 0 && humanAction.p_bodys[i].p_contour_points_score != nullptr) {
                napi_value contourScoreArray;
                napi_create_array_with_length(env, humanAction.p_bodys[i].contour_points_count, &contourScoreArray);
                for (int j = 0; j < humanAction.p_bodys[i].contour_points_count; j++) {
                    napi_value scoreVal;
                    napi_create_double(env, humanAction.p_bodys[i].p_contour_points_score[j], &scoreVal);
                    napi_set_element(env, contourScoreArray, j, scoreVal);
                }
                napi_set_named_property(env, bodyObj, "contour_points_score", contourScoreArray);
            }
            
            // key_points_3d_count
            napi_value kp3dCount;
            napi_create_int32(env, humanAction.p_bodys[i].key_points_3d_count, &kp3dCount);
            napi_set_named_property(env, bodyObj, "key_points_3d_count", kp3dCount);
            
            // key_points_3d array
            if (humanAction.p_bodys[i].key_points_3d_count > 0 && humanAction.p_bodys[i].p_key_points_3d != nullptr) {
                napi_value kp3dArray;
                napi_create_array_with_length(env, humanAction.p_bodys[i].key_points_3d_count, &kp3dArray);
                for (int j = 0; j < humanAction.p_bodys[i].key_points_3d_count; j++) {
                    napi_value pointObj;
                    napi_create_object(env, &pointObj);
                    napi_value px, py, pz;
                    napi_create_double(env, humanAction.p_bodys[i].p_key_points_3d[j].x, &px);
                    napi_create_double(env, humanAction.p_bodys[i].p_key_points_3d[j].y, &py);
                    napi_create_double(env, humanAction.p_bodys[i].p_key_points_3d[j].z, &pz);
                    napi_set_named_property(env, pointObj, "x", px);
                    napi_set_named_property(env, pointObj, "y", py);
                    napi_set_named_property(env, pointObj, "z", pz);
                    napi_set_element(env, kp3dArray, j, pointObj);
                }
                napi_set_named_property(env, bodyObj, "key_points_3d", kp3dArray);
            }
            
            // key_points_3d_score array
            if (humanAction.p_bodys[i].key_points_3d_count > 0 && humanAction.p_bodys[i].p_key_points_3d_score != nullptr) {
                napi_value kp3dScoreArray;
                napi_create_array_with_length(env, humanAction.p_bodys[i].key_points_3d_count, &kp3dScoreArray);
                for (int j = 0; j < humanAction.p_bodys[i].key_points_3d_count; j++) {
                    napi_value scoreVal;
                    napi_create_double(env, humanAction.p_bodys[i].p_key_points_3d_score[j], &scoreVal);
                    napi_set_element(env, kp3dScoreArray, j, scoreVal);
                }
                napi_set_named_property(env, bodyObj, "key_points_3d_score", kp3dScoreArray);
            }
            
            // label
            napi_value bodyLabel;
            napi_create_int32(env, humanAction.p_bodys[i].label, &bodyLabel);
            napi_set_named_property(env, bodyObj, "label", bodyLabel);
            
            napi_set_element(env, bodysArray, i, bodyObj);
        }
        napi_set_named_property(env, jsResult, "bodys", bodysArray);
    }
    
    // 设置 camera_motion_score
    napi_value cameraMotion;
    napi_create_double(env, humanAction.camera_motion_score, &cameraMotion);
    napi_set_named_property(env, jsResult, "camera_motion_score", cameraMotion);
    
    return jsResult;
}

    
napi_value STMobileWrapperNapi::ndk_destroy(napi_env env, napi_callback_info info) {
    if (STMobileWrapperNapi::wrapper != nullptr) {
        delete STMobileWrapperNapi::wrapper;
        STMobileWrapperNapi::wrapper = nullptr;
    }
    return nullptr;
}

napi_value STMobileWrapperNapi::ndk_makeEmpty(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_makeEmpty wrapper is null");
        napi_value st_result;
        bool false_result = false;
        napi_get_boolean(env, false_result, &st_result);
        return st_result;
    }
    bool result = wrapper->makeEmpty();
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_getOverlappedBeautyInfo(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_getOverlappedBeautyInfo wrapper is null");
        napi_value array;
        napi_create_array_with_length(env, 0, &array);
        return array;
    }
    std::vector<st_effect_beauty_info_t> result = wrapper->getOverlappedBeautyInfo();
    // 创建返回结果并返回
    napi_value array;
    napi_create_array_with_length(env, result.size(), &array);
    for (int i = 0; i < result.size(); i++) {
        napi_value element;
        napi_create_object(env, &element);
        napi_value value;
        napi_create_int32(env, result[i].type, &value);
        napi_set_named_property(env, element, "type", value);
        napi_create_int32(env, result[i].mode, &value);
        napi_set_named_property(env, element, "mode", value);
        napi_create_string_utf8(env, (const char *)result[i].name, 256, &value);
        napi_set_named_property(env, element, "name", value);
        napi_create_double(env, result[i].strength, &value);
        napi_set_named_property(env, element, "strength", value);
        
        napi_set_element(env, array, i, element);
    }
    return array;
}    
//异步执行
struct AsyncData {
    napi_async_work work; // 异步工作对象
    napi_deferred deferred; // Promise 的 deferred 对象
    st_effect_in_image_t inImage;
    size_t outLength;
    void *outData;
    int32_t width;
    int32_t height;
    st_pixel_format outFormat;
    
    st_rotate_type orientation;
    bool isOrigin;
    bool immediately;
    bool result;
};
// 后台线程执行的函数（不阻塞主线程）
static void ExecuteWork(napi_env env, void* data) {
    AsyncData* async_data = static_cast<AsyncData*>(data);
    std::unique_ptr<st_image_t> outImage = nullptr;
    
    if (async_data->outLength > 0 && async_data->outData != nullptr) {
        outImage.reset(new st_image_t());
        memset(outImage.get(), 0x0, sizeof(st_image_t));
        outImage->pixel_format = async_data->outFormat;
    }
    
    bool result = STMobileWrapperNapi::wrapper->process(&async_data->inImage, outImage.get(), async_data->orientation, async_data->isOrigin, async_data->immediately);
    if (outImage!= nullptr && outImage->data!=nullptr) {
        int32_t length = (async_data->outFormat == ST_PIX_FMT_NV21)? (async_data->width*async_data->height*3/2):(async_data->width*async_data->height*4);
        memcpy(async_data->outData, outImage->data, length);
    }
    async_data->result = result;
}
// 主线程完成回调（处理结果或错误）
static void CompleteWork(napi_env env, napi_status status, void* data) {
    AsyncData* async_data = static_cast<AsyncData*>(data);
    // 创建 JS 结果
    napi_value js_result;
    napi_get_boolean(env, async_data->result, &js_result);
    
    if (status == napi_ok) {
        // 创建成功结果
        napi_value js_result;
        napi_create_int32(env, async_data->result, &js_result);
        napi_resolve_deferred(env, async_data->deferred, js_result);
    } else {
        // 创建错误对象
        napi_value error;
        napi_create_string_utf8(env, "Async task failed", NAPI_AUTO_LENGTH, &error);
        napi_reject_deferred(env, async_data->deferred, error);
    }
    
    // 清理资源
    napi_delete_async_work(env, async_data->work);
    delete async_data;
}
napi_value STMobileWrapperNapi::ndk_processASync(napi_env env, napi_callback_info info) {
    size_t argc = 13;
    napi_value args[13] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    
    size_t length;
    void *data = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status status = napi_get_arraybuffer_info(env, args[0], &data, &length);
    if (status != napi_ok) {
         LOGE("ndk_processASync ger data error %d", status);
    }
    
    int32_t format = 0;
    status = napi_get_value_int32(env, args[1], &format);
    
    int32_t width = 0;
    status = napi_get_value_int32(env, args[2], &width);
    
    int32_t height = 0;
    status = napi_get_value_int32(env, args[3], &height);
    
    int32_t stride = 0;
    status = napi_get_value_int32(env, args[4], &stride);
    
    int32_t rotate = 0;
    status = napi_get_value_int32(env, args[5], &rotate);
    
    bool mirror = false;
    status = napi_get_value_bool(env, args[6], &mirror);
    
    double time_stamp = 0;
    status = napi_get_value_double(env, args[7], &time_stamp);
    

    st_effect_in_image_t image = {
        .image ={
            .data = (unsigned char *)data,
            .pixel_format = (st_pixel_format)format,
            .width = width,
            .height = height,
            .stride = stride,
            .time_stamp = time_stamp
        },
        .rotate = (st_rotate_type)rotate,
        .b_mirror = mirror
    };
    
    AsyncData* async_data = new AsyncData();
    
    //out data
    //size_t outLength;
    //void *outData= nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    status = napi_get_arraybuffer_info(env, args[8], &async_data->outData, &async_data->outLength);
    
    int32_t outFormat = 0;
    status = napi_get_value_int32(env, args[9], &outFormat);

    int32_t orientation = 0;
    status = napi_get_value_int32(env, args[10], &orientation);
    
    bool isOrigin = false;
    status = napi_get_value_bool(env, args[11], &isOrigin);
    
    bool immediately = false;
    status = napi_get_value_bool(env, args[12], &immediately);
    
    async_data->inImage = image;
    async_data->outFormat = (st_pixel_format)outFormat;
    async_data->width = width;
    async_data->height = height;
    async_data->orientation = (st_rotate_type)orientation;
    async_data->isOrigin = isOrigin;
    async_data->immediately = immediately;
    
    napi_value promise;
    napi_create_promise(env, &async_data->deferred, &promise);
    
    napi_value async_name;
    napi_create_string_utf8(env, "processAsync", NAPI_AUTO_LENGTH, &async_name);
    napi_create_async_work(
        env,
        nullptr,
        async_name,
        ExecuteWork,
        CompleteWork,
        async_data,
        &async_data->work
    );
    napi_queue_async_work(env, async_data->work);
    return promise;
}

napi_value STMobileWrapperNapi::ndk_process(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        return nullptr;
    }
    size_t argc = 14;
    napi_value args[14] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    size_t length;
    void *data = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status status = napi_get_arraybuffer_info(env, args[0], &data, &length);
    if (status != napi_ok) {
         LOGE("ndk_process ger data error %d", status);
    }
    
    int32_t format = 0;
    status = napi_get_value_int32(env, args[1], &format);
    
    int32_t width = 0;
    status = napi_get_value_int32(env, args[2], &width);
    
    int32_t height = 0;
    status = napi_get_value_int32(env, args[3], &height);
    
    int32_t stride = 0;
    status = napi_get_value_int32(env, args[4], &stride);
    
    int32_t rotate = 0;
    status = napi_get_value_int32(env, args[5], &rotate);
    
    bool mirror = false;
    status = napi_get_value_bool(env, args[6], &mirror);
    
    double time_stamp = 0;
    status = napi_get_value_double(env, args[7], &time_stamp);
    

    st_effect_in_image_t image = {
        .image ={
            .data = (unsigned char *)data,
            .pixel_format = (st_pixel_format)format,
            .width = width,
            .height = height,
            .stride = stride,
            .time_stamp = time_stamp
        },
        .rotate = (st_rotate_type)rotate,
        .b_mirror = mirror
    };
    
    //out data
    size_t outLength;
    void *outData= nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    status = napi_get_arraybuffer_info(env, args[8], &outData, &outLength);
    
    int32_t outFormat = 0;
    status = napi_get_value_int32(env, args[9], &outFormat);
    //st_image_t *outImage = nullptr;
    std::unique_ptr<st_image_t> outImage = nullptr;
    if (outLength > 0 && outData != nullptr) {
        outImage.reset(new st_image_t());
        memset(outImage.get(), 0x0, sizeof(st_image_t));
        outImage->pixel_format = (st_pixel_format)outFormat;
    }
     
    
    int32_t orientation = 0;
    status = napi_get_value_int32(env, args[10], &orientation);
    
    bool isOrigin = false;
    status = napi_get_value_bool(env, args[11], &isOrigin);
    
    bool immediately = false;
    status = napi_get_value_bool(env, args[12], &immediately);
    
    int32_t customEvent = 0;
    status = napi_get_value_int32(env, args[13], &customEvent);

    bool result = wrapper->process(&image, outImage.get(),(st_rotate_type)orientation, isOrigin, immediately,customEvent);
    
    if (outImage!= nullptr && outImage->data!=nullptr) {
        int32_t length = ((st_pixel_format)outFormat == ST_PIX_FMT_NV21)? (width*height*3/2):(width*height*4);
        memcpy(outData, outImage->data, length);
    }
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_updateWindowSize(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_updateWindowSize wrapper is null");
        return nullptr;
    }
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t width = 0;
    napi_status status = napi_get_value_int32(env, args[0], &width);
    if (status != napi_ok) {
        LOGE("ndk_updateWindowSize width error %d", status);
        return nullptr;
    }
    int32_t height = 0;
    status = napi_get_value_int32(env, args[1], &height);
    if (status != napi_ok) {
        LOGE("ndk_updateWindowSize height error %d", status);
        return nullptr;
    }
    
    wrapper->updateWindowSize(width,height);
    return nullptr;
}
napi_value STMobileWrapperNapi::ndk_setResizingMode(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_setResizingMode wrapper is null");
        return nullptr;
    }
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t mode = 0;
    napi_status status = napi_get_value_int32(env, args[0], &mode);
    if (status != napi_ok) {
        LOGE("setResizingMode width error %d", status);
        return nullptr;
    }
    wrapper->setResizingMode((mobile_wrapper::RenderingResizingMode)mode);
    return nullptr;
}
napi_value STMobileWrapperNapi::ndk_resetPixelReader(napi_env env, napi_callback_info info) {
    if (wrapper == nullptr) {
        LOGE("ndk_resetPixelReader wrapper is null");
        napi_value st_result;
        bool false_result = false;
        napi_get_boolean(env, false_result, &st_result);
        return st_result;
    }
    bool result = wrapper->resetPixelReader();
     // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

napi_value STMobileWrapperNapi::ndk_setSoundLoadCallback(napi_env env, napi_callback_info info) 
{     
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
 
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr); 
    napi_ref callbackRef;
    napi_create_reference(env, args[0] ,1, &callbackRef);
    
    // 获取 uv_loop
    uv_loop_s* loop = nullptr;
    napi_get_uv_event_loop(env, &loop);
    
    mobile_wrapper::AudioManager::loadCallback = new mobile_wrapper::SoundCallbackInfo{
        .env = env,
        .jsCallback = callbackRef,
        .loop = loop
    };
    return nullptr;
}
napi_value STMobileWrapperNapi::ndk_setSoundPlayCallback(napi_env env, napi_callback_info info) 
{     
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
 
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr); 
    napi_ref callbackRef;
    napi_create_reference(env, args[0] ,1, &callbackRef);
    
    // 获取 uv_loop
    uv_loop_s* loop = nullptr;
    napi_get_uv_event_loop(env, &loop);
    
    mobile_wrapper::AudioManager::playCallback = new mobile_wrapper::SoundCallbackInfo{
        .env = env,
        .jsCallback = callbackRef,
        .loop = loop
    };
    return nullptr;
}
napi_value STMobileWrapperNapi::ndk_setSoundStopCallback(napi_env env, napi_callback_info info) 
{     
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
 
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr); 
    napi_ref callbackRef;
    napi_create_reference(env, args[0] ,1, &callbackRef);
    
    // 获取 uv_loop
    uv_loop_s* loop = nullptr;
    napi_get_uv_event_loop(env, &loop);
    
    mobile_wrapper::AudioManager::stopCallback = new mobile_wrapper::SoundCallbackInfo{
        .env = env,
        .jsCallback = callbackRef,
        .loop = loop
    };
    return nullptr;
}
napi_value STMobileWrapperNapi::ndk_setSoundPauseCallback(napi_env env, napi_callback_info info) 
{     
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
 
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr); 
    napi_ref callbackRef;
    napi_create_reference(env, args[0] ,1, &callbackRef);
    
    // 获取 uv_loop
    uv_loop_s* loop = nullptr;
    napi_get_uv_event_loop(env, &loop);
    
    mobile_wrapper::AudioManager::pauseCallback = new mobile_wrapper::SoundCallbackInfo{
        .env = env,
        .jsCallback = callbackRef,
        .loop = loop
    };
    return nullptr;
}
napi_value STMobileWrapperNapi::ndk_setSoundResumeCallback(napi_env env, napi_callback_info info) 
{     
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
 
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr); 
    napi_ref callbackRef;
    napi_create_reference(env, args[0] ,1, &callbackRef);
    
    // 获取 uv_loop
    uv_loop_s* loop = nullptr;
    napi_get_uv_event_loop(env, &loop);
    
    mobile_wrapper::AudioManager::resumeCallback = new mobile_wrapper::SoundCallbackInfo{
        .env = env,
        .jsCallback = callbackRef,
        .loop = loop
    };
    return nullptr;
}



}