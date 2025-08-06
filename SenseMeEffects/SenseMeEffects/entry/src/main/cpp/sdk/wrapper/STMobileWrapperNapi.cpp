//
// Created on 2024/12/17.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include "./log/ohos_log.h"
#include "sdk/wrapper/STMobileWrapper.h"
#include <cstdint>
#include <thread>
#include "STMobileWrapperNapi.h"

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
    delete buf;
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
    delete buf;
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
    delete buf;
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
    delete buf;
    
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
    delete buf;
    
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
    napi_create_int64(env, result, &st_result);
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
    napi_create_int64(env, result, &st_result);
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
    delete buf;
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
napi_value STMobileWrapperNapi::ndk_makeCurrent(napi_env env, napi_callback_info info) {

    bool result = wrapper->makeCurrent();
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_makeEmpty(napi_env env, napi_callback_info info) {

    bool result = wrapper->makeEmpty();
    // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}
napi_value STMobileWrapperNapi::ndk_getOverlappedBeautyInfo(napi_env env, napi_callback_info info) {

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
    size_t argc = 13;
    napi_value args[13] = {nullptr};
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

    bool result = wrapper->process(&image, outImage.get(),(st_rotate_type)orientation, isOrigin, immediately);
    
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
    bool result = wrapper->resetPixelReader();
     // 创建返回结果并返回
    napi_value st_result;
    napi_get_boolean(env, result, &st_result);
    return st_result;
}

}