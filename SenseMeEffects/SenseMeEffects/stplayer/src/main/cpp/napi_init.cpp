#include "common/common.h"
#include "napi/native_api.h"
#include "native_common.h"
#include "utils/log.h"
#include <string>
#include <sys/stat.h>
#include "./MediaPlayer.h"
#include "./utils//log.h"
#include <uv.h>
#include "./MediaRecorder.h"
#include "./RecordBean.h"

const int32_t PARAM_COUNT_1 = 1;
const int32_t PARAM_COUNT_2 = 2;
const int32_t PARAM_COUNT_3 = 3;
const int32_t PARAM_COUNT_4 = 4;
const int32_t PARAM_COUNT_5 = 5;

const char *TAG = "NAPI_INIT";

using namespace MediaPlayerContext;
using namespace MediaRecorderContext;

shared_ptr<MediaPlayer> g_player;
shared_ptr<MediaRecorder> g_recorder;
napi_env g_envMessage;
napi_ref g_callBackRefMessage;
napi_ref g_stateCallBack;
void* g_buffer;
napi_value g_arrayBuffer;

struct GetFrameAsyncCallbackInfo {
    napi_env env;
    napi_async_work asyncWork;
    napi_deferred deferred;
    std::string path;
    uint32_t fd;
    uint32_t size;
    napi_ref callbackRef = nullptr;
    void* data;
    int widht;
    int height;
    int rotate;
    int state;//0正常 !0异常
};

struct RecorderContext {
    napi_env env;
    napi_async_work asyncWork;
    napi_deferred deferred;
    napi_ref callbackRef = nullptr;
    string path;
    int fd;
    int width;
    int height;
    int format;
    int rotate;
    int state; // 0正常 !0异常
};

std::string jsValueToString(const napi_env &env, const napi_value &value) {
    char charStr[1024] = {0};
    size_t charLen = 0;
    int len = 1024;
    napi_get_value_string_utf8(env, value, charStr, len, &charLen);
    std::string str = charStr;
    return str;
}

static napi_value setPlayerDataSource(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value argv[PARAM_COUNT_3];
    napi_get_cb_info(env, info, &argc, argv, NULL, NULL);
    napi_deferred deferred;
    napi_value promise;
    NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
    std::string path = jsValueToString(env, argv[0]);
    uint32_t fd = 0;
    napi_get_value_uint32(env, argv[1], &fd);
    uint32_t size = 0;
    napi_get_value_uint32(env, argv[2], &size);
    GetFrameAsyncCallbackInfo *asyncCallbackInfo = new GetFrameAsyncCallbackInfo{
        .env = env,
        .asyncWork = nullptr,
        .deferred = deferred,
        .path = path,
        .fd = fd,
        .size = size,
    };
    napi_value resourceName;
    napi_create_string_latin1(env, "setPlayerDataSource", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(
        env, nullptr, resourceName,
        [](napi_env env, void *data) {
            GetFrameAsyncCallbackInfo *asyncCallbackInfo = (GetFrameAsyncCallbackInfo *)data;
            g_player = make_shared<MediaPlayer>();
            if(g_player->setDataSource(asyncCallbackInfo->path, asyncCallbackInfo->fd, asyncCallbackInfo->size) != PLAYER_OK){
                asyncCallbackInfo->state = -1;
            }
        },
        [](napi_env env, napi_status status, void *data) {
            GetFrameAsyncCallbackInfo *asyncCallbackInfo = (GetFrameAsyncCallbackInfo *)data;
            napi_value result;
            napi_create_int32(env, asyncCallbackInfo->state == 0 ? 0 : -1, &result);
            napi_resolve_deferred(asyncCallbackInfo->env, asyncCallbackInfo->deferred, result);
            napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
            delete asyncCallbackInfo;
        },
        (void *)asyncCallbackInfo, &asyncCallbackInfo->asyncWork);
    napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
    return promise;
}

bool createArrayBuffer(napi_env env, void *src, size_t srcLen) {
    if (src == nullptr) {
        return false;
    }
    if(g_arrayBuffer == nullptr){
        if (napi_create_arraybuffer(env, srcLen, &g_buffer, &g_arrayBuffer) != napi_ok) {
            return false;
        }
    }
    else
    {
        size_t len = 0;
        napi_get_arraybuffer_info(env, g_arrayBuffer, NULL, &len);
        if (len != srcLen) {
            if (napi_create_arraybuffer(env, srcLen, &g_buffer, &g_arrayBuffer) != napi_ok) {
                return false;
            }
        }
    }
    memcpy(g_buffer, src, srcLen);
    return true;
}

void messageCallBack(void * data, int width, int height, int rotate, int state) {
    struct GetFrameAsyncCallbackInfo *context = new GetFrameAsyncCallbackInfo();
    context->env = g_envMessage;
    uv_loop_s *loopMessage = nullptr;
    napi_get_uv_event_loop(context->env, &loopMessage);
    if (loopMessage == nullptr) {
        LOGI(TAG,"napi-->loopMessage null");
        return;
    }
    uv_work_t *work = new (std::nothrow) uv_work_t;
    if (work == nullptr) {
        LOGI(TAG,"napi-->work null");
        return;
    }
    context->data = data;
    context->widht = width;
    context->height = height;
    context->rotate = rotate;
    context->state = state;
    context->callbackRef = g_callBackRefMessage;
    work->data = (void *)context;
    uv_queue_work(
        loopMessage, work, 
        [](uv_work_t *work) {},//operation
        [](uv_work_t *work, int status) {//complete
            GetFrameAsyncCallbackInfo *context = static_cast<GetFrameAsyncCallbackInfo *>(work->data);
            if(context->state){
                if (work != nullptr) {
                    delete work;
                }
                delete context;
                return;
            }
            if (g_player == nullptr) {
                if (work != nullptr) delete work;
                if (context != nullptr)delete context;
                return;
            }
            napi_value callback = nullptr;
            napi_get_reference_value(context->env, context->callbackRef, &callback);
            napi_value result[PARAM_COUNT_5] = {nullptr};
            createArrayBuffer(context->env, context->data, context->widht * context->height * 3 >> 1);
            result[0] = g_arrayBuffer;
            napi_create_int32(context->env, context->widht, &result[1]);
            napi_create_int32(context->env, context->height, &result[2]);
            napi_create_int32(context->env, context->rotate, &result[3]);
            napi_create_int32(context->env, context->state, &result[4]);
            napi_value ret = 0;
            napi_call_function(context->env, nullptr, callback, PARAM_COUNT_5, result, &ret);
            if (work != nullptr) {
                delete work;
            }
            delete context;
        });
}


void stateCallback(int state){
    struct GetFrameAsyncCallbackInfo *context = new GetFrameAsyncCallbackInfo();
    context->env = g_envMessage;
    uv_loop_s *loopMessage = nullptr;
    napi_get_uv_event_loop(context->env, &loopMessage);
    if (loopMessage == nullptr) {
        LOGI(TAG, "napi-->loopMessage null");
        return;
    }
    uv_work_t *work = new (std::nothrow) uv_work_t;
    if (work == nullptr) {
        LOGI(TAG, "napi-->work null");
        return;
    }
    context->state = state;
    context->callbackRef = g_stateCallBack;
    work->data = (void *)context;
    uv_queue_work(
        loopMessage, work, [](uv_work_t *work) {}, 
        [](uv_work_t *work, int status) {  
            GetFrameAsyncCallbackInfo *context = static_cast<GetFrameAsyncCallbackInfo *>(work->data);
            napi_value callback = nullptr;
            napi_get_reference_value(context->env, context->callbackRef, &callback);
            napi_value result[PARAM_COUNT_1] = {nullptr};
            napi_create_int32(context->env, context->state, &result[0]);
            napi_value ret = 0;
            napi_call_function(context->env, nullptr, callback, PARAM_COUNT_1, result, &ret);
            if (work != nullptr) {
                delete work;
            }
            delete context;
        });
}

static napi_value PlayerGetVideoInfo(napi_env env, napi_callback_info info) { 
    LOGI(TAG, "PlayerGetVideoInfo");
    if (g_player) {
        VideoInfo info = g_player->getVideoInfo();
        // Construct string types and int types.
        napi_value width, height, rotate;
        if (napi_ok != napi_create_int32(env, info.width, &width)  ||
            napi_ok != napi_create_int32(env, info.height, &height)  ||
            napi_ok != napi_create_int32(env, info.rotate, &rotate) ) {
            LOGI(TAG, "napi_create_property error");
            return nullptr;
        }
        // Construct an object type.
        napi_value obj;
        if (napi_ok != napi_create_object(env, &obj)) {
            LOGI(TAG, "napi_create_object error");
            return nullptr;
        }
        // Set and assign values to the name and age attributes.
        if (napi_ok !=napi_set_named_property(env, obj, "width", width) ||
            napi_ok !=napi_set_named_property(env, obj, "height", height) ||
            napi_ok !=napi_set_named_property(env, obj, "rotate", rotate)) {
            return nullptr;
        }
        return obj;
    }
    return nullptr;
}


static napi_value  PlayerSetFrameRate(napi_env env, napi_callback_info info){
    LOGI(TAG, "PlayerSetFrameRate");
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    int32_t frameRate = 0;
    napi_get_value_int32(env, args[0], &frameRate);
    if (g_player) {
        LOGD(TAG, "frame Rate %d", frameRate);
        g_player->m_defaultFrameRate = frameRate * 1.0f;
    }
    return nullptr;
}

static napi_value PlayerStart(napi_env env, napi_callback_info info) {
    LOGI(TAG, "PlayerStart");
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    napi_value callback = args[0];
    napi_ref callBackRefMessage_;
    napi_create_reference(env, callback, 1, &callBackRefMessage_);
    g_callBackRefMessage = callBackRefMessage_;
    g_envMessage = env;
    if (g_player) {
        LOGI(TAG, "setFrameCallback");
        g_player->setFrameCallback(messageCallBack);
        g_player->start();
    }
    return nullptr;
}

static napi_value PlayerPause(napi_env env, napi_callback_info info) {
    LOGI(TAG, "PlayerPause");
    if (g_player) {
        g_player->pause();
    }
    return nullptr;
}

static napi_value PlayerStateCallback(napi_env env, napi_callback_info info) {
    LOGI(TAG, "StateCallback");
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    napi_value callback = args[0];
    napi_ref callBackRefMessage_;
    napi_create_reference(env, callback, 1, &callBackRefMessage_);
    g_stateCallBack = callBackRefMessage_;
    g_envMessage = env;
    if (g_player) {
        LOGI(TAG, "StateCallback");
        g_player->setStateCallback(stateCallback);
    }
    return nullptr;
}

static napi_value PlayerResume(napi_env env, napi_callback_info info) {
    LOGI(TAG, "PlayerResume");
    if (g_player) {
        g_player->resume();
    }
    return nullptr;
}


static napi_value PlayerStop(napi_env env, napi_callback_info info) {
    LOGI(TAG, "PlayerStop");
    if (g_player) {
        g_player->stop();
        g_player = nullptr;
    }
    return nullptr;
}


static napi_value setRecorderDataSource(napi_env env, napi_callback_info info) {
    size_t argc = 6;
    napi_value argv[6];
    napi_get_cb_info(env, info, &argc, argv, NULL, NULL);
    napi_deferred deferred;
    napi_value promise;
    NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
    std::string path = jsValueToString(env, argv[0]);
    int fd = 0;
    napi_get_value_int32(env, argv[1], &fd);
    int width = 0;
    napi_get_value_int32(env, argv[2], &width);
    int height = 0;
    napi_get_value_int32(env, argv[3], &height);
    int format = 0;
    napi_get_value_int32(env, argv[4], &format);
    int rotate = 0;
    napi_get_value_int32(env, argv[5], &rotate);

    RecorderContext *context = new RecorderContext{
        .env = env,
        .asyncWork = nullptr,
        .deferred = deferred,
        .path = path,
        .fd = fd,
        .width = width,
        .height = height,
        .format = format,
        .rotate = rotate,
    };
    napi_value resourceName;
    napi_create_string_latin1(env, "setRecorderDataSource", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(
        env, nullptr, resourceName,
        [](napi_env env, void *data) {
            RecorderContext *info = (RecorderContext *)data;
            g_recorder = make_shared<MediaRecorder>();
            auto recoreBean = make_unique<RecordBean>();
            recoreBean->m_fd = info->fd;
            if(info->width)recoreBean->m_width = info->width;
            if(info->height)recoreBean->m_height = info->height;
            if(info->rotate)recoreBean->m_rotate = info->rotate;
            g_recorder->recordBean = move(recoreBean);
            if (g_recorder->setRecordPath() != RECORDER_OK) {
                info->state = -1;
            }
        },
        [](napi_env env, napi_status status, void *data) {
            RecorderContext *info = (RecorderContext *)data;
            napi_value result;
            napi_create_int32(env, info->state == 0 ? 0 : -1, &result);
            napi_resolve_deferred(info->env, info->deferred, result);
            napi_delete_async_work(env, info->asyncWork);
            delete info;
        },
        (void *)context, &context->asyncWork);
    napi_queue_async_work(env, context->asyncWork);
    return promise;
}


static napi_value RecorderStart(napi_env env, napi_callback_info info) {
    LOGI(TAG, "Record Start");
    napi_deferred deferred;
    napi_value promise;
    NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
    RecorderContext *context = new RecorderContext{
        .env = env,
        .asyncWork = nullptr,
        .deferred = deferred,
    };
    napi_value resourceName;
    napi_create_string_latin1(env, "startRecord", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(
        env, nullptr, resourceName,
        [](napi_env env, void *data) {
            RecorderContext *info = (RecorderContext *)data;
            info->state = -1;
            if (g_recorder) {
               info->state = g_recorder->startRecord();
            }
        },
        [](napi_env env, napi_status status, void *data) {
            RecorderContext *info = (RecorderContext *)data;
            napi_value result;
            napi_create_int32(env, info->state == 0 ? 0 : -1, &result);
            napi_resolve_deferred(info->env, info->deferred, result);
            napi_delete_async_work(env, info->asyncWork);
            delete info;
        },
        (void *)context, &context->asyncWork);
    napi_queue_async_work(env, context->asyncWork);
    return promise;
}

static napi_value PushVideoFrame(napi_env env, napi_callback_info info) {
    napi_value funcResult;
    if (g_recorder == nullptr) {
        napi_create_int32(env, -1, &funcResult);
        return funcResult;
    }
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    size_t inputBufferLength;
    void *inputBuffer = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status status = napi_get_arraybuffer_info(env, args[0], &inputBuffer, &inputBufferLength);
    uint32_t width = 0;
    napi_get_value_uint32(env, args[1], &width);
    uint32_t height = 0;
    napi_get_value_uint32(env, args[2], &height);
    if (status != napi_ok) {
        LOGI(TAG, "napi_get_arraybuffer_info 666 error %{public}d", status);
        napi_create_int32(env, -1, &funcResult);
        return funcResult;
    }
    int ret = g_recorder->pushFrameData((uint8_t *)inputBuffer, width, height);
    napi_create_int32(env, ret, &funcResult);
    return funcResult;
}

static napi_value RecorderStop(napi_env env, napi_callback_info info) {
    LOGI(TAG, "RecorderStop");
    if (g_recorder) {
        g_recorder->stopRecord();
        napi_value funcResult;
        napi_create_int32(env, g_recorder->recordBean->m_fd, &funcResult);
        return funcResult;
    }
    return nullptr;
}


EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        DECLARE_NAPI_FUNCTION("setPlayerDataSource", setPlayerDataSource),
        DECLARE_NAPI_FUNCTION("startPlay", PlayerStart),
        DECLARE_NAPI_FUNCTION("getVideoInfo", PlayerGetVideoInfo),
        DECLARE_NAPI_FUNCTION("setFrameRate", PlayerSetFrameRate),
        DECLARE_NAPI_FUNCTION("pausePlay", PlayerPause),
        DECLARE_NAPI_FUNCTION("resumePlay", PlayerResume),
        DECLARE_NAPI_FUNCTION("setStateCallback", PlayerStateCallback),
        DECLARE_NAPI_FUNCTION("stopPlay", PlayerStop),
        DECLARE_NAPI_FUNCTION("setRecorderDataSource", setRecorderDataSource),
        DECLARE_NAPI_FUNCTION("startRecord", RecorderStart),
        DECLARE_NAPI_FUNCTION("pushVideoFrame", PushVideoFrame),
        DECLARE_NAPI_FUNCTION("stopRecord", RecorderStop),
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "stplayer",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterStplayerModule(void)
{
    napi_module_register(&demoModule);
}
