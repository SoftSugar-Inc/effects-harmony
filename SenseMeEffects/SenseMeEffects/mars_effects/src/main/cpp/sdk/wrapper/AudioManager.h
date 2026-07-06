//
// Created on 2025/9/22.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef SENSEMEEFFECTS_AUDIOMANAGER_H
#define SENSEMEEFFECTS_AUDIOMANAGER_H
#include <js_native_api_types.h>
#include <uv.h>

#endif //SENSEMEEFFECTS_AUDIOMANAGER_H
#include <ohaudio/native_audiorenderer.h>
#include <ohaudio/native_audiostreambuilder.h>
namespace mobile_wrapper
{

struct SoundCallbackInfo {
    napi_env env;
    napi_ref jsCallback;
    uv_loop_s* loop;  // 添加 uv_loop
};

// 用于传递给 uv_queue_work 的数据结构
struct SoundLoadWorkData {
    SoundCallbackInfo* callbackInfo;
    std::string filePath;
};

struct SoundPlayWorkData {
    SoundCallbackInfo* callbackInfo;
    int loop;
};

struct SoundSimpleWorkData {
    SoundCallbackInfo* callbackInfo;
};

class AudioManager
{
    public:
        AudioManager();
        ~AudioManager(){
            loadCallback = nullptr;
            playCallback = nullptr;
            stopCallback = nullptr;
            pauseCallback = nullptr;
            resumeCallback = nullptr;
        }
    
        static SoundCallbackInfo *loadCallback;
        static SoundCallbackInfo *playCallback;
        static SoundCallbackInfo *stopCallback;
        static SoundCallbackInfo *pauseCallback;
        static SoundCallbackInfo *resumeCallback;

        static void soundLoad(void* handle, char* sound, const char* sound_name, int length);
        static void soundPlay(void* handle, const char* sound_name, int loop);
        static void soundStop(void* handle, const char* sound_name);
        static void soundPause(void* handle, const char* sound_name);
        static void soundResume(void* handle, const char* sound_name);
};
}