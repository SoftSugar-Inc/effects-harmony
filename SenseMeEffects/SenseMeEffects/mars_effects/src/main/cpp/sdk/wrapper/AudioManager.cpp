//
// Created on 2025/9/22.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".


#include <cstdio> 
#include <cstring>
#include <hilog/log.h>
#include <js_native_api.h>
#include <napi/native_api.h>
#include <string>
#include "sdk/wrapper/AudioManager.h"


#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200   // 全局业务域标识
#define LOG_TAG    "AudioManager" // 模块标签
#define LOGE(fmt, ...) {char log_buff[1024];snprintf(log_buff, sizeof(log_buff), fmt, ##__VA_ARGS__);  OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, LOG_TAG, "%{public}s", log_buff);}

namespace mobile_wrapper
{
SoundCallbackInfo *AudioManager::loadCallback = nullptr;
SoundCallbackInfo *AudioManager::playCallback = nullptr;
SoundCallbackInfo *AudioManager::stopCallback = nullptr;
SoundCallbackInfo *AudioManager::pauseCallback = nullptr;
SoundCallbackInfo *AudioManager::resumeCallback = nullptr;

// soundLoad 的主线程回调
void soundLoadMainThread(uv_work_t* work, int status) {
    SoundLoadWorkData* data = static_cast<SoundLoadWorkData*>(work->data);
    if (data && data->callbackInfo) {
        napi_handle_scope scope;
        napi_open_handle_scope(data->callbackInfo->env, &scope);
        napi_value jsCallback;
        napi_get_reference_value(data->callbackInfo->env, data->callbackInfo->jsCallback, &jsCallback);
        napi_value result[1] = {nullptr};
        napi_create_string_utf8(data->callbackInfo->env, data->filePath.c_str(), NAPI_AUTO_LENGTH, &result[0]);
        napi_call_function(data->callbackInfo->env, nullptr, jsCallback, 1, result, nullptr);
        napi_close_handle_scope(data->callbackInfo->env, scope);
    }
    delete data;
    delete work;
}

void AudioManager::soundLoad(void* handle, char* sound, const char* sound_name, int length)
{
    LOGE("AudioManager  soundLoad: %s", sound_name);
    std::string filePath = "/data/storage/el2/base/files/" + std::string(sound_name);
    FILE* file = fopen(filePath.c_str(), "wb");
    if (file) {
        fwrite(sound, 1, length, file);
        fclose(file);
        
        // 使用 uv_queue_work 调度到主线程
        if (loadCallback && loadCallback->loop) {
            uv_work_t* work = new uv_work_t();
            SoundLoadWorkData* data = new SoundLoadWorkData{
                .callbackInfo = loadCallback,
                .filePath = filePath
            };
            work->data = data;
            uv_queue_work(loadCallback->loop, work, 
                [](uv_work_t* work) {}, // 工作线程什么都不做
                soundLoadMainThread);    // 完成回调在主线程执行
        }
    } else {
        LOGE("AudioManager Failed to save file: %{public}s", filePath.c_str());
    }
}

// soundPlay 的主线程回调
void soundPlayMainThread(uv_work_t* work, int status) {
    SoundPlayWorkData* data = static_cast<SoundPlayWorkData*>(work->data);
    if (data && data->callbackInfo) {
        napi_handle_scope scope;
        napi_open_handle_scope(data->callbackInfo->env, &scope);
        napi_value jsCallback;
        napi_get_reference_value(data->callbackInfo->env, data->callbackInfo->jsCallback, &jsCallback);
        napi_value result[1] = {nullptr};
        napi_create_int32(data->callbackInfo->env, data->loop, &result[0]);
        napi_call_function(data->callbackInfo->env, nullptr, jsCallback, 1, result, nullptr);
        napi_close_handle_scope(data->callbackInfo->env, scope);
    }
    delete data;
    delete work;
}

void AudioManager::soundPlay(void* handle, const char* sound_name, int loop)
{
    LOGE("AudioManager  soundPlay: %s", sound_name);
    
    if (playCallback && playCallback->loop) {
        uv_work_t* work = new uv_work_t();
        SoundPlayWorkData* data = new SoundPlayWorkData{
            .callbackInfo = playCallback,
            .loop = loop
        };
        work->data = data;
        uv_queue_work(playCallback->loop, work, 
            [](uv_work_t* work) {},
            soundPlayMainThread);
    }
}

// soundStop 的主线程回调
void soundStopMainThread(uv_work_t* work, int status) {
    SoundSimpleWorkData* data = static_cast<SoundSimpleWorkData*>(work->data);
    if (data && data->callbackInfo) {
        napi_handle_scope scope;
        napi_open_handle_scope(data->callbackInfo->env, &scope);
        napi_value jsCallback;
        napi_get_reference_value(data->callbackInfo->env, data->callbackInfo->jsCallback, &jsCallback);
        napi_call_function(data->callbackInfo->env, nullptr, jsCallback, 0, nullptr, nullptr);
        napi_close_handle_scope(data->callbackInfo->env, scope);
    }
    delete data;
    delete work;
}

void AudioManager::soundStop(void* handle, const char* sound_name)
{
    LOGE("AudioManager  soundStop: %s", sound_name);
    
    if (stopCallback && stopCallback->loop) {
        uv_work_t* work = new uv_work_t();
        SoundSimpleWorkData* data = new SoundSimpleWorkData{
            .callbackInfo = stopCallback
        };
        work->data = data;
        uv_queue_work(stopCallback->loop, work, 
            [](uv_work_t* work) {},
            soundStopMainThread);
    }
}

// soundPause 的主线程回调
void soundPauseMainThread(uv_work_t* work, int status) {
    SoundSimpleWorkData* data = static_cast<SoundSimpleWorkData*>(work->data);
    if (data && data->callbackInfo) {
        napi_handle_scope scope;
        napi_open_handle_scope(data->callbackInfo->env, &scope);
        napi_value jsCallback;
        napi_get_reference_value(data->callbackInfo->env, data->callbackInfo->jsCallback, &jsCallback);
        napi_call_function(data->callbackInfo->env, nullptr, jsCallback, 0, nullptr, nullptr);
        napi_close_handle_scope(data->callbackInfo->env, scope);
    }
    delete data;
    delete work;
}

void AudioManager::soundPause(void* handle, const char* sound_name)
{
    LOGE("AudioManager  soundPause: %s", sound_name);
    
    if (pauseCallback && pauseCallback->loop) {
        uv_work_t* work = new uv_work_t();
        SoundSimpleWorkData* data = new SoundSimpleWorkData{
            .callbackInfo = pauseCallback
        };
        work->data = data;
        uv_queue_work(pauseCallback->loop, work, 
            [](uv_work_t* work) {},
            soundPauseMainThread);
    }
}

// soundResume 的主线程回调
void soundResumeMainThread(uv_work_t* work, int status) {
    SoundSimpleWorkData* data = static_cast<SoundSimpleWorkData*>(work->data);
    if (data && data->callbackInfo) {
        napi_handle_scope scope;
        napi_open_handle_scope(data->callbackInfo->env, &scope);
        napi_value jsCallback;
        napi_get_reference_value(data->callbackInfo->env, data->callbackInfo->jsCallback, &jsCallback);
        napi_call_function(data->callbackInfo->env, nullptr, jsCallback, 0, nullptr, nullptr);
        napi_close_handle_scope(data->callbackInfo->env, scope);
    }
    delete data;
    delete work;
}

void AudioManager::soundResume(void* handle, const char* sound_name)
{
   LOGE("AudioManager  soundResume: %s", sound_name);
   
   if (resumeCallback && resumeCallback->loop) {
       uv_work_t* work = new uv_work_t();
       SoundSimpleWorkData* data = new SoundSimpleWorkData{
           .callbackInfo = resumeCallback
       };
       work->data = data;
       uv_queue_work(resumeCallback->loop, work, 
           [](uv_work_t* work) {},
           soundResumeMainThread);
   }
}


}