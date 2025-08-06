#include "napi/native_api.h"
#include "log.h"
#include "napi/native_api.h"
#include "Manager/GLManager.h"
//#include "sdk/manager/EffectInterface.h"
//#include "sdk/manager/CommonInterface.h"
//#include "sdk/manager/HumanAction/st_mobile_human_action_interface.h"
#include "sdk/wrapper/STMobileWrapperNapi.h"

namespace GLContextManager {
    EXTERN_C_START
    static napi_value Init(napi_env env, napi_value exports) {
        if ((env == nullptr) || (exports == nullptr)) {
            LOGE("INDEX", "env or exports is null");
            return nullptr;
        }
        STMobileWrapperNapi::DefinePropertiesExport(env, exports);
        GLManager::GetInstance()->Export(env, exports);
        /*EffectInterface::DefinePropertiesExport(env, exports);
        CommonInterface::DefinePropertiesExport(env, exports);
        st_mobile_human_action_interface::DefinePropertiesExport(env, exports);*/
        return exports;
    }
    EXTERN_C_END

    static napi_module demoModule = {
        .nm_version = 1,
        .nm_flags = 0,
        .nm_filename = nullptr,
        .nm_register_func = Init,
        .nm_modname = "entry",
        .nm_priv = ((void *)0),
        .reserved = {0},
    };

    extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
} // namespace GLContextManager
