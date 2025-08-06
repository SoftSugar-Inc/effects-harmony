//
// Created on 2024/3/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_ASYNCCALLBACKINFO_H
#define EFFECTSHARMONY_ASYNCCALLBACKINFO_H

#include <bits/alltypes.h>
#include <js_native_api_types.h>
#include <node_api_types.h>
#include <string>

struct AsyncCallbackInfo {
    napi_env env;
    int32_t width;
    int32_t height;
    napi_async_work asyncWork;
    napi_deferred deferred;
    int32_t outFd = true;
    int32_t resultCode = 0;
    std::string resultStr = "";
    std::string outputPath = "";
};

#endif //EFFECTSHARMONY_ASYNCCALLBACKINFO_H
