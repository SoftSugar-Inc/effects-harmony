
#include "STMobileWrapper.h"
#include "st_mobile_glutil.h"
#include "st_mobile_license.h"
#include "json11.hpp"
#include <cstring>
#include <string>
#include <fstream>
#include <iostream>
#include <sstream>
#include <memory>
#include <chrono>

#define MSAA_DEBUG 0

#define DESKTOP_DEBUG 0
#if DESKTOP_DEBUG
#include <opencv2/opencv.hpp>
#else
#ifndef __HARMONY__
#define __HARMONY__
#endif
#endif


#if TARGET_OS_IPHONE

#if CONFIG_ST_MOBILE_ANGLE_EGL
#include <GLES3/gl3.h>
#ifndef GL_GLEXT_PROTOTYPES
#define GL_GLEXT_PROTOTYPES
#endif
#include <GLES2/gl2ext.h>
#include <GLES2/gl2ext_angle.h>

#include <EGL/egl.h>
#ifndef EGL_EGLEXT_PROTOTYPES
#define EGL_EGLEXT_PROTOTYPES
#endif
#include <EGL/eglext.h>
#include <EGL/eglext_angle.h>
#else
#include <OpenGLES/ES2/glext.h>
#include <OpenGLES/ES3/glext.h>
#endif

#elif defined(__ANDROID__) || defined(__HARMONY__) //__ANDROID__
// #include <GLES2/gl2.h>
#include <GLES3/gl3.h>

#ifndef __gl2_h_
#define __gl2_h_
#endif
#include <GLES2/gl2ext.h>
//#include <GLES3/gl3ext.h>

#include <EGL/egl.h>
#include <EGL/eglext.h>

#else
#ifdef WIN32

#ifndef USE_OPENGL_DESKTOP
    #include "glad/glad.h"
#else
    #include <GL/gl3w.h>
#endif

#else
#include <GL/glew.h>
#endif

#endif  // end of TARGET_OS_IPHONE

#if defined(__HARMONY__)
#include <hilog/log.h>
#undef LOG_DOMAIN
#define LOG_DOMAIN 0x0011
#define LOGE(fmt, ...) {char log_buff[1024]; snprintf(log_buff, 1024, fmt, ##__VA_ARGS__); OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "STMobileWrapper", "%{public}s", log_buff);}
#else
#define LOGE(fmt, ...) {char log_buff[1024]; snprintf(log_buff, 1024, fmt, ##__VA_ARGS__); fprintf(stderr, "STMobileWrapper: %s\n", log_buff);}
#endif

#define DEBUG_LOG 0
#if DEBUG_LOG
#define __TIC1__(tag) auto time_##tag##_start = std::chrono::high_resolution_clock::now(); //long mem_##tag##_start=getMemoryInfo()
#define __TOC1__(tag) auto time_##tag##_end = std::chrono::high_resolution_clock::now();\
        LOGE("%s: %f", #tag, static_cast<float>(std::chrono::duration_cast<std::chrono::microseconds>(time_##tag##_end - time_##tag##_start).count()) / 1000.f);
#else
#define __TIC1__(tag)
#define __TOC1__(tag)
#endif

#ifndef __CHECK_HANDLE_IMP__
#define __CHECK_HANDLE_IMP__(handle) \
    do {    \
        if (!handle)  \
        {   \
            LOGE("%s-%d: handle %s cannot be null", __FUNCTION__, __LINE__, #handle); \
            return false; \
        }   \
    } while(0);
#endif

#ifndef __CHECK_HUMAN_ACTION_HANDLE__
#define __CHECK_HUMAN_ACTION_HANDLE__   __CHECK_HANDLE_IMP__(mhDetect)
#endif

#ifndef __CHECK_EFFECT_HANDLE__
#define __CHECK_EFFECT_HANDLE__ __CHECK_HANDLE_IMP__(mhEffect)
#endif

#ifndef __CHECK_COLORCONVERT_HANDLE__
#define __CHECK_COLORCONVERT_HANDLE__ __CHECK_HANDLE_IMP__(mhColorConvert)
#endif

#ifndef __CHECK_ANIMAL_HANDLE__
#define __CHECK_ANIMAL_HANDLE__   __CHECK_HANDLE_IMP__(mhAnimal)
#endif

#ifndef __CHECK_FACEATTRIBUTE_HANDLE__
#define __CHECK_FACEATTRIBUTE_HANDLE__   __CHECK_HANDLE_IMP__(mhFaceAttribute)
#endif

namespace mobile_wrapper
{

bool STMobileWrapper::mbAuth = false;

inline bool isYUVFormat(st_pixel_format format)
{
    return format == ST_PIX_FMT_NV12 || format == ST_PIX_FMT_NV21 || format == ST_PIX_FMT_YUV420P;
}

inline st_multiplane_image_t stimage2stmultplaneimage(const st_image_t *p_image)
{
    if (p_image == nullptr || p_image->width <= 0 || p_image->height <= 0 || p_image->data == nullptr)
    {
        LOGE("invalid image");
        return {};
    }

    st_multiplane_image_t image {};
    image.format = p_image->pixel_format;
    image.width = p_image->width;
    image.height = p_image->height;
    image.planes[0] = p_image->data;
    image.strides[0] = p_image->width;
    switch (p_image->pixel_format)
    { 
    case ST_PIX_FMT_NV12:
    case ST_PIX_FMT_NV21:
        image.planes[1] = p_image->data + p_image->width * p_image->height;
        image.strides[1] = p_image->width;
        break;
    case ST_PIX_FMT_YUV420P:
        image.planes[1] = p_image->data + p_image->width * p_image->height;
        image.strides[1] = p_image->width / 2;
        image.planes[2] = p_image->data + p_image->width * p_image->height * 5 / 4;
        image.strides[2] = p_image->width / 2;
        break;
    default:
        break;
    }
    return image;
}

inline int bitsPerPixelForPixelFormat(st_pixel_format format)
{
    switch (format)
    {
    case ST_PIX_FMT_GRAY8:
        return 8;
    case ST_PIX_FMT_YUV420P:
    case ST_PIX_FMT_NV12:
    case ST_PIX_FMT_NV21:
        return 12;
    case ST_PIX_FMT_BGRA8888:
    case ST_PIX_FMT_RGBA8888:
        return 32;
    case ST_PIX_FMT_BGR888:
    case ST_PIX_FMT_RGB888:
        return 24;
    case ST_PIX_FMT_FLOAT:
        return 32;
    default:
        return 0;
    }
}

bool trimImagePadding(const st_image_t *p_src, unsigned char *p_dst)
{
    return trimImagePadding(p_src->data, p_src->width, p_src->height, p_src->stride, p_src->pixel_format, p_dst);
}

bool trimImagePadding(const unsigned char *p_src, 
        int width, int height, int stride, st_pixel_format format,
        unsigned char *p_dst)
{
    if (p_src == nullptr || p_dst == nullptr || width * height * stride == 0)
    {
        return false;
    }

    bool ret = true;

    switch (format)
    {
    case ST_PIX_FMT_RGBA8888:
    case ST_PIX_FMT_BGRA8888:
    case ST_PIX_FMT_RGB888:
    case ST_PIX_FMT_BGR888:
    case ST_PIX_FMT_GRAY8:
    {
        int bytesPerComponent = bitsPerPixelForPixelFormat(format) / 8;
        for (int i = 0; i < height; ++ i)
        {
            memcpy(p_dst + i * width * bytesPerComponent, p_src + i * stride, width * bytesPerComponent);
        }
    }
        break;
    case ST_PIX_FMT_NV12:
    case ST_PIX_FMT_NV21:
    {
        for (int i = 0; i < height + height / 2; ++ i)
        {
            memcpy(p_dst + i * width , p_src + i * stride, width);
        }
    }
        break;
    default:
        LOGE("unsupported format: %d", format);
        ret = false;
        break;
    }

    return ret;
}

inline st_rect_t makeRectWithAspectRatioInsideRect(st_pointi_t size, st_rect_t rect)
{
    float width = rect.right - rect.left;
    float height = rect.bottom - rect.top;
    float hRatio = width / size.x;
    float vRatio = height / size.y;

    float ratio = std::min(hRatio, vRatio);
    float newWidth = size.x * ratio;
    float newHeight = size.y * ratio;

    st_rect_t ret {};
    ret.left = rect.left + (width - newWidth) / 2;
    ret.top = rect.top + (height - newHeight) / 2;
    ret.right = ret.left + newWidth;
    ret.bottom = ret.top + newHeight;

    return ret;
}

inline bool writeFile(const char *buffer, int size, const std::string &filePath) 
{
    std::ofstream ofs(filePath, std::ios::binary | std::ios::trunc);
    if (!ofs.is_open()) 
    {
        LOGE("cannot open file: %s", filePath.c_str());
        return false; 
    }

    ofs.write(buffer, size);
    ofs.close();
    return true;
}

inline std::string readFile(const std::string &filePath) 
{
    std::ifstream ifs(filePath);
    if (!ifs.is_open())
    {
        LOGE("cannot open file: %s", filePath.c_str());
        return ""; 
    }

    std::ostringstream oss;

    std::string line;
    while (std::getline(ifs, line))
    {
        oss << line << "\n";
    }
    ifs.close();

    return oss.str();
}

const std::string vsh = R"(
    attribute vec4 aPosition;
    attribute vec2 aTexCoord;
    varying vec2 vTexCoord;
    void main()
    {
        gl_Position = aPosition;
        vTexCoord = aTexCoord;
    }
)";

const std::string fsh = R"(
    precision mediump float;
    varying vec2 vTexCoord;
    uniform sampler2D uSrcTex;
    void main() {
        gl_FragColor = texture2D(uSrcTex, vTexCoord);
    }
)";

inline std::string getTemporaryDir()
{
#if defined(__HARMONY__)
    return "data/storage/el2/base/files/";
#else
    return "./";
#endif
}

static std::map<st_handle_t, STMobileWrapper *> &GetMobileWrapperMap()
{
    static std::map<st_handle_t, STMobileWrapper *> sMobileWrapperMap;
    return sMobileWrapperMap;
}

static st_result_t module_state_change_cb(st_handle_t handle, const st_effect_module_info_t *p_module_info)
{
    st_result_t ret = ST_OK;
    st_effect_module_type_t type = p_module_info->type;
    switch (type)
    {
    case EFFECT_MODULE_SEGMENT:
        if (p_module_info->rsv_type == EFFECT_RESERVED_SEGMENT_BASECOLOR && p_module_info->reserved)
        {
            const auto &mobileWrapperMap = GetMobileWrapperMap();
            auto it = mobileWrapperMap.find(handle); 
            if (it != mobileWrapperMap.end())
            {
                const uint32_t *reserved = static_cast<const uint32_t *>(p_module_info->reserved);
                it->second->setParam(ST_HUMAN_ACTION_PARAM_GREEN_SEGMENT_COLOR, *reserved);
            }
        }
        break;
    default:
        LOGE("unsupported module type: %d", type);
        ret = ST_E_FAIL;
        break;
    }

    return ret;
}

static st_result_t packaged_state_change_cb(st_handle_t handle, const st_effect_package_info_t *p_package_info)
{
    return ST_OK;
}

STMobileWrapper::STMobileWrapper(HandleConfig config, void *window)
    : mHandleConfig(config)
    , mWindow(window)
{
#if DEBUG_LOG
    mTimeStart = std::chrono::time_point<std::chrono::high_resolution_clock>::min();
#endif
}

STMobileWrapper::~STMobileWrapper()
{
    if (mhDetect) st_mobile_human_action_destroy(mhDetect);
    if (mhAnimal) st_mobile_tracker_animal_face_destroy(mhAnimal);
    if (mhFaceAttribute) st_mobile_face_attribute_destroy(mhFaceAttribute);

    destoryGLResources();
}

void STMobileWrapper::destoryGLResources()
{
    // CAUTION: must make current before destroy, and glutil will make empty after destroy
    makeCurrent();

    if (mhEffect) 
    {
        auto &mobileWrapperMap = GetMobileWrapperMap();
        mobileWrapperMap.erase(mhEffect);

        st_mobile_effect_destroy_handle(mhEffect);
    }
    if (mhColorConvert) st_mobile_color_convert_destroy(mhColorConvert);    

#if MSAA_DEBUG
    glDeleteFramebuffers(1, &mFbo);
    glDeleteFramebuffers(1, &mMidFbo);
    glDeleteTextures(1, &mTexId);
    glDeleteRenderbuffers(1, &mRboId);
#endif

    // CAUTION: mhGLUtil must be destroyed at last for the inner gl context
    if (mhGLUtil) st_mobile_glutil_destroy(mhGLUtil);
}

bool STMobileWrapper::Initialize(const char *buffer, unsigned int length)
{
    std::string config_str(buffer, length);
    std::string err; 
    const json11::Json &config = json11::Json::parse(config_str, err);
    if (!err.empty())
    {
        LOGE("parse config faild: %s", err.c_str());
        return false;
    }
            
    const std::string &licensePath = config["license"].string_value();
    if (!licensePath.empty())
    {
        checkLicense(licensePath.c_str());     
    }

    EffectsMode mode = (EffectsMode)config["config"].int_value();
    bool ret = Initialize(mode);
    if (!ret) return false;
             
    const json11::Json::array &models = config["models"].array_items();
    for (const json11::Json &model : models)
    {
        addSubModel(model.string_value().c_str());
    }

    return true;
}

bool STMobileWrapper::Initialize(EffectsMode mode)
{
    if (!mbAuth) return false;

    mMode = mode;

    int humanConfig = 0, effectConfig = 0;
    switch (mode)
    {
    case EffectsMode::PHOTO:
        humanConfig = ST_MOBILE_DETECT_MODE_IMAGE;  
        effectConfig = EFFECT_CONFIG_IMAGE_MODE; 
        break;
    case EffectsMode::VIDEO:
    case EffectsMode::PREVIEW:
        humanConfig = ST_MOBILE_DETECT_MODE_PREVIEW;  
        effectConfig = EFFECT_CONFIG_NONE; 
        break;
    default:
        humanConfig = ST_MOBILE_DETECT_MODE_VIDEO_POST_PROCESS;
        effectConfig = EFFECT_CONFIG_IMAGE_MODE;
        break;
    }

    st_mobile_glutil_create(&mhGLUtil);

    if (mHandleConfig & INNER_CONTEXT)
    {
        st_result_t ret = st_mobile_glutil_create_context(mhGLUtil, mWindow);
        if (ret != ST_OK)
        {
            LOGE("faild to create inner context, ret: %d", ret);
            return false;
        }
    }

    st_mobile_human_action_create(NULL, humanConfig, &mhDetect);
    if (mhDetect)
    {
        st_mobile_human_action_setparam(mhDetect, ST_HUMAN_ACTION_PARAM_BACKGROUND_SEGMENT_USE_TEMPERATURE, 0.0f);
        st_mobile_human_action_setparam(mhDetect, ST_HUMAN_ACTION_PARAM_HEAD_SEGMENT_INSTANCE, 1.0f);
        st_mobile_human_action_setparam(mhDetect, ST_HUMAN_ACTION_PARAM_FACE_MESH_OUTPUT_FORMAT, ST_3D_WORLD_COORDINATE);
    }
    else
    {
        LOGE("faild to create human action handle");
    }

    st_mobile_effect_create_handle(effectConfig, &mhEffect);
    if (mhEffect)
    {
        st_mobile_effect_set_param(mhEffect, EFFECT_PARAM_MAX_MEMORY_BUDGET_MB, 1000.0f); 
        st_mobile_effect_set_param(mhEffect, EFFECT_PARAM_DISABLE_TRIGER_OVERLAP, 1.0f); 

        st_mobile_effect_set_module_state_change_callback(mhEffect, module_state_change_cb);
        st_mobile_effect_set_packaged_state_change_callback(mhEffect, packaged_state_change_cb);

        auto &mobileWrapperMap = GetMobileWrapperMap();
        mobileWrapperMap.insert(std::make_pair(mhEffect, this));
    }
    else
    {
        LOGE("faild to create effect handle");
    }

    st_mobile_color_convert_create(&mhColorConvert);    
    if (!mhColorConvert) LOGE("faild to create color convert handle");

    st_mobile_tracker_animal_face_create(NULL, humanConfig, &mhAnimal);
    if (!mhAnimal) LOGE("faild to create animal face handle");

    st_mobile_glutil_make_context_empty(mhGLUtil);

    return true;
}

bool STMobileWrapper::checkLicense(const char *licensePath)
{
    const std::string &license = readFile(licensePath);
    if (license.empty())
    {
        LOGE("no license at: %s", licensePath);
        return false;
    }

    return checkLicense(license.c_str(), license.size()); 
}

bool STMobileWrapper::checkLicense(const char *buffer, unsigned int length)
{
    const char* mobile_ver = st_mobile_get_version();
    LOGE("st_mobile SDK version: %s", mobile_ver);
    
    const std::string &activeCodePath = getTemporaryDir() + "EFFECTS_ACTIVE_CODE";
    const std::string &activeCode = readFile(activeCodePath);

    st_result_t ret = ST_OK;        

    if (!activeCode.empty())
    {
        ret = st_mobile_check_activecode_from_buffer(buffer,
                                                     length,
                                                     activeCode.c_str(),
                                                     activeCode.size());
        if ((mbAuth = (ret == ST_OK))) return mbAuth;
    }

    int active_code_len = 10240;
    char active_code[active_code_len];
    memset(active_code, 0x0, active_code_len);

    ret = st_mobile_generate_activecode_from_buffer(buffer,
                                                    length,
                                                    active_code,
                                                    &active_code_len);
    mbAuth = (ret == ST_OK);
    if (ret != ST_OK) 
    {
        LOGE("failed to check license: %d", ret);
        return false;
    }

    writeFile(active_code, active_code_len, activeCodePath);

    return mbAuth;
}

bool STMobileWrapper::addSubModel(const char *path)
{
    __CHECK_HUMAN_ACTION_HANDLE__

    st_result_t ret = st_mobile_human_action_add_sub_model(mhDetect, path);
    if (ret != ST_OK)
    {
        LOGE("add sub model failed: %d", ret);
        return false;
    }

    return true;
}

bool STMobileWrapper::addSubModel(const unsigned char *buffer, unsigned int length)
{
    __CHECK_HUMAN_ACTION_HANDLE__

    st_result_t ret = st_mobile_human_action_add_sub_model_from_buffer(mhDetect, buffer, length);
    if (ret != ST_OK)
    {
        LOGE("add sub model failed: %d", ret);
        return false;
    }

    return true;
}

bool STMobileWrapper::addAnimalSubModel(const char *path)
{
    __CHECK_ANIMAL_HANDLE__

    st_result_t ret = st_mobile_tracker_animal_face_add_sub_model(mhAnimal, path);
    if (ret != ST_OK)
    {
        LOGE("add sub model failed: %d", ret);
        return false;
    }

    return true;
}

bool STMobileWrapper::addAnimalSubModel(const unsigned char *buffer, unsigned int length)
{
    __CHECK_ANIMAL_HANDLE__

    st_result_t ret = st_mobile_tracker_animal_face_add_sub_model_from_buffer(mhAnimal, buffer, length);
    if (ret != ST_OK)
    {
        LOGE("add sub model failed: %d", ret);
        return false;
    }

    return true;
}

bool STMobileWrapper::resetHumanAction()
{
    if (mhDetect) st_mobile_human_action_reset(mhDetect);
    if (mhAnimal) st_mobile_tracker_animal_face_reset(mhAnimal);

    return true;
}

bool STMobileWrapper::setParam(st_effect_param_t param, float value)
{
    __CHECK_EFFECT_HANDLE__

    st_mobile_effect_set_param(mhEffect, param, value);
    return true;
}

bool STMobileWrapper::setParam(st_human_action_param_type param, float value)
{
    __CHECK_HUMAN_ACTION_HANDLE__

    st_mobile_human_action_setparam(mhDetect, param, value);
    return true;
}

int STMobileWrapper::addPackage(const char *packagePath)
{
    if (!mhEffect)
    {
        LOGE("need initlize effect firstly");
        return 0;
    }

    int pkgId = 0;
    st_result_t ret = st_mobile_effect_add_package(mhEffect, packagePath, &pkgId);
    if (ret != ST_OK)
    {
        LOGE("add package: %s faild, ret: %d", packagePath, pkgId);
    }
    return pkgId;
}

int STMobileWrapper::addPackage(const char *buffer, unsigned int length)
{
    if (!mhEffect)
    {
        LOGE("need initlize effect firstly");
        return 0;
    }

    int pkgId = 0;
    st_effect_buffer_t effect_buffer { (char *)buffer, length };
    st_result_t ret = st_mobile_effect_add_package_from_buffer(mhEffect, &effect_buffer, &pkgId);
    if (ret != ST_OK)
    {
        LOGE("add package faild, ret: %d", pkgId);
    }
    return pkgId;
}

int STMobileWrapper::changePackage(const char *packagePath)
{
    if (!mhEffect)
    {
        LOGE("need initlize effect firstly");
        return 0;
    }

    int pkgId = 0;
    st_result_t ret = st_mobile_effect_change_package(mhEffect, packagePath, &pkgId);
    if (ret != ST_OK)
    {
        LOGE("change package: %s faild, ret: %d", packagePath, pkgId);
    }
    return pkgId;
}

int STMobileWrapper::changePackage(const char *buffer, unsigned int length)
{
    if (!mhEffect)
    {
        LOGE("need initlize effect firstly");
        return 0;
    }

    int pkgId = 0;
    st_effect_buffer_t effect_buffer { (char *)buffer, length };
    st_result_t ret = st_mobile_effect_change_package_from_buffer(mhEffect, &effect_buffer, &pkgId);
    if (ret != ST_OK)
    {
        LOGE("change package faild, ret: %d", pkgId);
    }
    return pkgId;
}


bool STMobileWrapper::removePackage(int packageId)
{
    __CHECK_EFFECT_HANDLE__

    st_result_t ret = st_mobile_effect_remove_package(mhEffect, packageId);
    return ret == ST_OK;
}


bool STMobileWrapper::clearPackages()
{
    __CHECK_EFFECT_HANDLE__

    st_result_t ret = st_mobile_effect_clear_packages(mhEffect);
    return ret == ST_OK;
}


bool STMobileWrapper::setPackageBeautyStrength(int packageId, st_effect_beauty_group_t type, float strength)
{
    __CHECK_EFFECT_HANDLE__
    
    st_result_t ret = st_mobile_effect_set_package_beauty_group_strength(mhEffect, packageId, type, strength);
    return ret == ST_OK;
}

bool STMobileWrapper::replayPackage(int packageId)
{
    __CHECK_EFFECT_HANDLE__

    st_result_t ret = st_mobile_effect_replay_package(mhEffect, packageId); 
    return ret == ST_OK;
}


uint64_t STMobileWrapper::getDetectConfig() const
{
    __CHECK_EFFECT_HANDLE__

    uint64_t config = 0;
    st_mobile_effect_get_detect_config(mhEffect, &config);
    return config;
}

uint64_t STMobileWrapper::getCustomEventConfig() const
{
    __CHECK_EFFECT_HANDLE__

    uint64_t eventConfig = 0;
    st_mobile_effect_get_custom_event_config(mhEffect, &eventConfig);
    return eventConfig;
}

uint64_t STMobileWrapper::getTriggerActions() const
{
    __CHECK_EFFECT_HANDLE__

    uint64_t triggerAction = 0;
    st_mobile_effect_get_human_trigger_actions(mhEffect, ST_MOBILE_DETECT_HAND_GESTURE, &triggerAction);
    return triggerAction;
}

uint64_t STMobileWrapper::getAnimalDetectConfig() const
{
    __CHECK_EFFECT_HANDLE__

    uint64_t config = 0;
    st_mobile_effect_get_animal_detect_config(mhEffect, &config);
    return config;
}

bool STMobileWrapper::setBeautyPackage(st_effect_beauty_type_t type, const char *path)
{
    __CHECK_EFFECT_HANDLE__

    st_result_t ret = st_mobile_effect_set_beauty(mhEffect, type, path);
    if (ret != ST_OK)
    {
        LOGE("failed to set beauty path: %s, ret: %d", path, ret);
        return false;
    }

    return true;
}

bool STMobileWrapper::setBeautyPackage(st_effect_beauty_type_t type, const char *buffer, unsigned int length)
{
    __CHECK_EFFECT_HANDLE__

    st_effect_buffer_t effect_buffer { (char *)buffer, length };
    st_result_t ret = st_mobile_effect_set_beauty_from_buffer(mhEffect, type, &effect_buffer);
    if (ret != ST_OK)
    {
        LOGE("failed to set beauty ret: %d", ret);
        return false;
    }

    return true;
}

bool STMobileWrapper::setBeautyMode(st_effect_beauty_type_t type, int mode)
{
    __CHECK_EFFECT_HANDLE__

    st_result_t ret = st_mobile_effect_set_beauty_mode(mhEffect, type, mode);
    if (ret != ST_OK)
    {
        LOGE("failed to set beauty mode for type: %d, ret: %d", type, ret);
        return false;
    }

    return true;
}

bool STMobileWrapper::setBeautyStrength(st_effect_beauty_type_t type, float strength)
{
    __CHECK_EFFECT_HANDLE__

    st_result_t ret = st_mobile_effect_set_beauty_strength(mhEffect, type, strength);
    if (ret != ST_OK)
    {
        LOGE("failed to set beauty strength for type: %d, ret: %d", type, ret);
        return false;
    }

    return true;
}

bool STMobileWrapper::setBeautyParam(st_effect_beauty_param_t type, float value)
{
    __CHECK_EFFECT_HANDLE__

    st_result_t ret = st_mobile_effect_set_beauty_param(mhEffect, type, value);
    if (ret != ST_OK)
    {
        LOGE("failed to set beauty param for type: %d, ret: %d", type, ret);
        return false;
    }

    return true;
}


std::vector<st_effect_beauty_info_t> STMobileWrapper::getOverlappedBeautyInfo() const
{
    if (!mhEffect)
    {
        LOGE("need initlize effect firstly");
        return std::vector<st_effect_beauty_info_t>{};
    }

    int beauty_num = 0;
    st_mobile_effect_get_overlapped_beauty_count(mhEffect, &beauty_num);

    std::vector<st_effect_beauty_info_t> beauty_info(beauty_num);
    st_result_t ret = st_mobile_effect_get_overlapped_beauty(mhEffect, beauty_info.data(), beauty_num);
    return beauty_info; 
}

st_result_t STMobileWrapper::createTexture(int width, int height, int &name, st_mobile_texture_t *p_tex)
{
    if (name == 0)
    {
        st_result_t ret = st_mobile_glutil_create_object(mhGLUtil, GL_OBJECT_TEXTURE, &name); 
        if (ret != ST_OK)
        {
            LOGE("failed to create texture, ret: %d", ret);
            return ret;
        }
    }

    st_image_t img{};
    img.data = nullptr;
    img.width = width;
    img.height = height;
    img.stride = width * 4;
    img.pixel_format = ST_PIX_FMT_RGBA8888;
    st_mobile_glutil_update_tex(mhGLUtil, name, &img);

    if (p_tex)
    {
        int tex_id = 0;
        st_mobile_glutil_get_object_id(mhGLUtil, name, &tex_id);
        p_tex->id = tex_id;
        p_tex->width = width;
        p_tex->height = height;
        p_tex->format = ST_PIX_FMT_RGBA8888;
    }

    return ST_OK;
}

bool STMobileWrapper::process(const st_effect_in_image_t *p_src, st_image_t *p_dst, st_rotate_type orientation, bool origin, bool immediately)
{

#if DEBUG_LOG
    if (mTimeStart == std::chrono::time_point<std::chrono::high_resolution_clock>::min()) 
    {
        mTimeStart = std::chrono::high_resolution_clock::now();
    }
#endif

    if (p_src == nullptr)
    {
        LOGE("the src img must not be nil");
        return false;
    }

    if (!p_dst && !mWindow)
    {
        LOGE("need has valid dst buffer or window");
        return false;
    }

    if (mWindow && (mWndWidth == 0 || mWndHeight == 0))
    {
        LOGE("the window must has valid width & height");
        return false;
    }

    //writeFile((char *)p_src->image.data, p_src->image.width * p_src->image.height * 3 / 2, getTemporaryDir() + std::to_string(p_src->image.width) + "x" + std::to_string(p_src->image.height) + "_src_img.nv21");

    __TIC1__(process)

    st_effect_in_image_t src = *p_src;

    int bitsPerPixel = bitsPerPixelForPixelFormat(p_src->image.pixel_format);
    int bytesPerPixel = bitsPerPixel / 8;
    if (p_src->image.width * bytesPerPixel < p_src->image.stride)
    {
        if (!mSrcImg || mSrcImg->width != p_src->image.width || mSrcImg->height != p_src->image.height || mSrcImg->pixel_format != p_src->image.pixel_format) 
        {
            mSrcImg.reset(new st_image_t(), [](st_image_t *p) {
                if (p->data) delete []p->data;
                if (p) delete p; 
            });

            mSrcImg->width = p_src->image.width;
            mSrcImg->height = p_src->image.height;
            mSrcImg->stride = p_src->image.width * bytesPerPixel;
            mSrcImg->pixel_format = p_src->image.pixel_format;
            mSrcImg->data = new unsigned char[mSrcImg->width * mSrcImg->height * bitsPerPixel / 8];
            mSrcImg->time_stamp = 0.0;
        }

        trimImagePadding(&p_src->image, mSrcImg->data);
        src.image = *mSrcImg;
    }

    bool ret = processImpl(&src, p_dst, orientation, origin, immediately);

    mFrameIndex ++;

    __TOC1__(process)

#if DEBUG_LOG
    auto currentTime = std::chrono::high_resolution_clock::now();
    float duration = static_cast<float>(std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - mTimeStart).count()) / mFrameIndex;
    LOGE("fps: %.2fms, %dfps", duration, static_cast<int>(1000.0f / duration));
#endif

    return ret;
}

bool STMobileWrapper::processImpl(const st_effect_in_image_t *p_src, st_image_t *p_dst, st_rotate_type orientation, bool origin, bool immediately)
{
    __CHECK_EFFECT_HANDLE__
    __CHECK_COLORCONVERT_HANDLE__

    GLContextGuard guard(this);

    if (!immediately && mMode != EffectsMode::PHOTO) st_mobile_glutil_swap_buffers(mhGLUtil);

    st_result_t ret = ST_OK;

    st_pointi_t img_size = { p_src->image.width, p_src->image.height };
    if (p_src->rotate % 2)
    {
        std::swap(img_size.x, img_size.y);
    }

    st_mobile_texture_t mid_tex {};
    if (!origin)
    {
        ret = createTexture(img_size.x, img_size.y, mMidTexName, &mid_tex);
        if (ret != ST_OK) return false;
    }

    st_mobile_texture_t dst_tex {};
    ret = createTexture(img_size.x, img_size.y, mTexName, &dst_tex); 
    if (ret != ST_OK) return false;

    int dst_tex_id = origin ? dst_tex.id : mid_tex.id;

    __TIC1__(color_convert)
    if (isYUVFormat(p_src->image.pixel_format))
    {
        const st_multiplane_image_t &multiplaneImage = stimage2stmultplaneimage(&p_src->image);
        ret = st_mobile_convert_yuv_buffer_2_rgba_tex(mhColorConvert, &multiplaneImage, (st_rotate_type)((4 - (int)p_src->rotate) % 4), p_src->b_mirror, dst_tex_id);
    }
    else
    {
        ret = st_mobile_convert_image_to_rgba_tex_ex(mhColorConvert, &p_src->image, (st_rotate_type)((4 - (int)p_src->rotate) % 4), p_src->b_mirror, dst_tex_id); 
    }
    __TOC1__(color_convert)
    if (ret != ST_OK)
    {
        LOGE("convert to rgba tex ret: %d", ret);
        return false;
    }

    if (!origin)
    {
        st_mobile_human_action_t humanAction {};
        bool human_ret = process(&p_src->image, p_src->rotate, getDetectConfig(), &humanAction);
        if (human_ret)
        {
            if (p_src->rotate != ST_CLOCKWISE_ROTATE_0)
            {
                st_mobile_human_action_rotate(p_src->image.width, p_src->image.height, p_src->rotate, false, &humanAction); 
            }
            if (p_src->b_mirror)
            {
                st_mobile_human_action_mirror(img_size.x, &humanAction);
            }
        }

        st_mobile_animal_result_t animal {};
        uint64_t animalDetectConfig = getAnimalDetectConfig();
        bool animal_ret = process(&p_src->image, p_src->rotate, animalDetectConfig, &animal);
        if (animal_ret)
        {
            if (p_src->rotate != ST_CLOCKWISE_ROTATE_0)
            {
                st_mobile_animal_face_rotate(p_src->image.width, p_src->image.height, p_src->rotate, &animal);   
            }
            if (p_src->b_mirror)
            {
                st_mobile_animal_face_mirror(img_size.x, &animal);
            }
        }

        st_effect_render_in_param_t in{};    
        in.p_human = &humanAction;
        in.p_animal = &animal;
        in.p_tex = &mid_tex;

        st_effect_render_out_param_t out{};
        out.p_tex = &dst_tex;

        process(&in, &out);
    }

    st_rotate_type rot = ST_CLOCKWISE_ROTATE_0;
    if (orientation == ST_CLOCKWISE_ROTATE_90)
    {
        // rear camera
        rot = static_cast<st_rotate_type>((4 - (int)p_src->rotate + 1) % 4);
    }
    else if (orientation == ST_CLOCKWISE_ROTATE_270)
    {
        // front camera
        rot = static_cast<st_rotate_type>(((int)p_src->rotate + 1) % 4);
    }

    if (mProgram == 0)
    {
        st_mobile_glutil_create_object(mhGLUtil, GL_OBJECT_PROGRAM, &mProgram);
        st_mobile_glutil_compile_program(mhGLUtil, mProgram, vsh.c_str(), fsh.c_str());
    }
    if (mVbo == 0)
    {
        st_mobile_glutil_create_object(mhGLUtil, GL_OBJECT_BUFFER, &mVbo);
    }

    if (p_dst)
    {
        if (mFboName == 0)
        {
            st_mobile_glutil_create_object(mhGLUtil, GL_OBJECT_FRAMEBUFFER, &mFboName);
        }

        st_mobile_texture_t mid2_tex {};
        int w = img_size.x, h = img_size.y;
        if (rot % 2) std::swap(w, h);
        ret = createTexture(w, h, mMid2TexName, &mid2_tex);
        if (ret != ST_OK) return false;

        st_mobile_glutil_bind_object(mhGLUtil, mFboName);
        st_mobile_glutil_framebuffer_attach_tex(mhGLUtil, mFboName, &mid2_tex);
        st_color_t clearColor = { 0, 0, 0, 1 };
        st_mobile_glutil_framebuffer_clear_color(mhGLUtil, mFboName, &clearColor);
        st_mobile_glutil_bind_object(mhGLUtil, mProgram);

        const std::array<float, 24> &vertices = verticesForOrientation(rot, true);
        st_glbuffer_t buffer {}; 
        buffer.target = BUFFER_TARGET_VERTEX;
        buffer.usage = BUFFER_USAGE_DYNAMIC;
        buffer.size = sizeof(vertices);
        buffer.buffer = const_cast<float *>(vertices.data());
        st_mobile_glutil_update_buffer(mhGLUtil, mVbo, &buffer);

        st_mobile_glutil_bind_object(mhGLUtil, mVbo);
        st_mobile_glutil_program_bind_vertex_attrib(mhGLUtil, mProgram, "aPosition", 4, 6 * sizeof(float), (const void *)0);
        st_mobile_glutil_program_bind_vertex_attrib(mhGLUtil, mProgram, "aTexCoord", 2, 6 * sizeof(float), (const void *)(4 * sizeof(float)));
        st_mobile_glutil_unbind_object(mhGLUtil, mVbo);

        st_mobile_glutil_program_bind_uniform_tex(mhGLUtil, mProgram, "uSrcTex", mTexName, 0);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        st_mobile_glutil_unbind_object(mhGLUtil, mProgram);
        st_mobile_glutil_unbind_object(mhGLUtil, mFboName); 
        glBindTexture(GL_TEXTURE_2D, 0);

        if (mReadPixel == 0)
        {
            st_mobile_glutil_create_read_pixel_id(mhGLUtil, &mReadPixel, mMode == EffectsMode::PHOTO ? PIXEL_READ_SYNC : PIXEL_READ_PBO);
        }
        if (!mCacheImage || mCacheImage->width != mid2_tex.width || mCacheImage->height != mid2_tex.height || mCacheImage->pixel_format != p_dst->pixel_format)
        {
            mCacheImage.reset(new st_image_t(), [](st_image_t *p) { 
                if (p->data) delete []p->data;
                if (p) delete p;
            });
            int bitsPerPixel = bitsPerPixelForPixelFormat(p_dst->pixel_format);
            mCacheImage->width = mid2_tex.width;
            mCacheImage->height = mid2_tex.height;
            mCacheImage->stride = mid2_tex.width * (bitsPerPixel / 8);   
            mCacheImage->pixel_format = p_dst->pixel_format;
            mCacheImage->data = new unsigned char[mid2_tex.width * mid2_tex.height * bitsPerPixel / 8];
            mCacheImage->time_stamp = 0.0;
        }
        st_mobile_glutil_read_pixel(mhGLUtil, mReadPixel, &mid2_tex, mCacheImage.get());
        *p_dst = *mCacheImage;

#if 0
        mobile_wrapper::writeFile((const char *)p_dst->data, 
                                  mid2_tex.width * mid2_tex.height * bitsPerPixelForPixelFormat(p_dst->pixel_format) / 8, 
                                  (std::string(getTemporaryDir()) + std::to_string(p_src->rotate) + "_ret.rgba").c_str());
#endif
    }

    if (mWindow)
    {
        __TIC1__(draw_window)
#if MSAA_DEBUG
        if (mFbo == 0)
        {
            glGenTextures(1, &mTexId);
            glBindTexture(GL_TEXTURE_2D, mTexId);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, p_src->image.width, p_src->image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
            glBindTexture(GL_TEXTURE_2D, 0);

            glGenFramebuffers(1, &mFbo); 
            glBindFramebuffer(GL_FRAMEBUFFER, mFbo);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, mTexId, 0);

            glGenFramebuffers(1, &mMSAAFbo);
            glBindFramebuffer(GL_FRAMEBUFFER, mMSAAFbo);

            glGenRenderbuffers(1, &mRboId);
            glBindRenderbuffer(GL_RENDERBUFFER, mRboId);
            glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_RGBA8, p_src->image.width, p_src->image.height);

            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, mRboId);
            
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
            glBindRenderbuffer(GL_RENDERBUFFER, 0);
        }

        {
        glBindFramebuffer(GL_FRAMEBUFFER, mMSAAFbo);
        glViewport(0, 0, p_src->image.width, p_src->image.height);

        st_mobile_glutil_bind_object(mhGLUtil, mProgram);

        std::array<float, 24> vertices = {
            -1.0f,  1.0f, 0.0f, 1.0f, 0.0f, 1.0f,   // l_t
            -1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 0.0f,   // l_b
             1.0f,  1.0f, 0.0f, 1.0f, 1.0f, 1.0f,   // r_t
             1.0f, -1.0f, 0.0f, 1.0f, 1.0f, 0.0f,   // r_b
        };

        st_glbuffer_t buffer {}; 
        buffer.target = BUFFER_TARGET_VERTEX;
        buffer.usage = BUFFER_USAGE_DYNAMIC;
        buffer.size = sizeof(vertices);
        buffer.buffer = const_cast<float *>(vertices.data());
        st_mobile_glutil_update_buffer(mhGLUtil, mVbo, &buffer);

        st_mobile_glutil_bind_object(mhGLUtil, mVbo);
        st_mobile_glutil_program_bind_vertex_attrib(mhGLUtil, mProgram, "aPosition", 4, 6 * sizeof(float), (const void *)0);
        st_mobile_glutil_program_bind_vertex_attrib(mhGLUtil, mProgram, "aTexCoord", 2, 6 * sizeof(float), (const void *)(4 * sizeof(float)));
        st_mobile_glutil_unbind_object(mhGLUtil, mVbo);
        
        st_mobile_glutil_program_bind_uniform_tex(mhGLUtil, mProgram, "uSrcTex", mTexName, 0);

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        st_mobile_glutil_unbind_object(mhGLUtil, mProgram);

        glBindFramebuffer(GL_READ_FRAMEBUFFER, mMSAAFbo);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, mFbo);
        glBlitFramebuffer(0, 0, p_src->image.width, p_src->image.height, 0, 0, p_src->image.width, p_src->image.height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
        
        GLenum attachments[] =  { GL_COLOR_ATTACHMENT0 };
        glInvalidateFramebuffer(GL_READ_FRAMEBUFFER, 1, attachments);
            
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        }
#endif

        st_pointi_t size { img_size.x, img_size.y };
        
        st_rect_t rect = makeRectWithAspectRatioInsideRect(size, { 0, 0, mWndWidth, mWndHeight });

        std::array<float, 24> vertices = verticesForOrientation(rot, false);
        float widthScaling, heightScaling;
        switch (mResizingMode)
        {
        case Stretch:
            widthScaling = 1.0f;
            heightScaling = 1.0f;
            break;
        case AspectFit:
            widthScaling = (rect.right - rect.left) * 1.0f / mWndWidth;
            heightScaling = (rect.bottom - rect.top) * 1.0f / mWndHeight;
            break;
        case AspectFill:
            widthScaling = mWndHeight * 1.0f / (rect.bottom - rect.top);
            heightScaling = mWndWidth * 1.0f / (rect.right - rect.left);
            break;
        }
        for (int i = 0; i < 4; ++ i)
        {
            vertices[0 + i * 6] *= widthScaling;
            vertices[1 + i * 6] *= heightScaling;
        }

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glViewport(0, 0, mWndWidth, mWndHeight);

        st_mobile_glutil_bind_object(mhGLUtil, mProgram);

        st_glbuffer_t buffer {}; 
        buffer.target = BUFFER_TARGET_VERTEX;
        buffer.usage = BUFFER_USAGE_DYNAMIC;
        buffer.size = sizeof(vertices);
        buffer.buffer = const_cast<float *>(vertices.data());
        st_mobile_glutil_update_buffer(mhGLUtil, mVbo, &buffer);

        st_mobile_glutil_bind_object(mhGLUtil, mVbo);
        st_mobile_glutil_program_bind_vertex_attrib(mhGLUtil, mProgram, "aPosition", 4, 6 * sizeof(float), (const void *)0);
        st_mobile_glutil_program_bind_vertex_attrib(mhGLUtil, mProgram, "aTexCoord", 2, 6 * sizeof(float), (const void *)(4 * sizeof(float)));
        st_mobile_glutil_unbind_object(mhGLUtil, mVbo);
        
#if MSAA_DEBUG
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, mTexId);
        glUniform1i(0, 0);
#else
        st_mobile_glutil_program_bind_uniform_tex(mhGLUtil, mProgram, "uSrcTex", mTexName, 0);
#endif

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        st_mobile_glutil_unbind_object(mhGLUtil, mProgram);
        glBindTexture(GL_TEXTURE_2D, 0);

#if 0
        {
        std::unique_ptr<unsigned char []> buffer(new unsigned char[dst_tex.width * dst_tex.height *4]);
        glBindTexture(GL_TEXTURE_2D, dst_tex.id);
        glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, buffer.get());
        glBindTexture(GL_TEXTURE_2D, 0);
        writeFile((char *)buffer.get(), dst_tex.width * dst_tex.height * 4, "ret_img.rgba");
        }
#endif

#if MSAA_DEB
        // when enable MSAA, using glFlush will cause the screen tearing, so use glFinish instead
        glFinish();
#else
        glFlush();
#endif
        if (immediately || mMode == EffectsMode::PHOTO) 
        {
            glFinish();
            st_mobile_glutil_swap_buffers(mhGLUtil);
        }
        __TOC1__(draw_window)
    }

    return true;
}

bool STMobileWrapper::makeCurrent()
{
    if (!(mHandleConfig & INNER_CONTEXT)) return false;
    st_result_t ret = st_mobile_glutil_make_context_current(mhGLUtil);
    return ret == ST_OK;
}

bool STMobileWrapper::makeEmpty()
{
    if (!(mHandleConfig & INNER_CONTEXT)) return false;
    st_result_t ret = st_mobile_glutil_make_context_empty(mhGLUtil);
    return ret == ST_OK;
}

bool STMobileWrapper::resetPixelReader()
{
    if (mReadPixel)
    {
        st_mobile_glutil_reset_read_pixel_id(mhGLUtil, mReadPixel);
    }
    return true;
}

std::array<float, 24> STMobileWrapper::verticesForOrientation(st_rotate_type orientation, bool mirror) const
{
    std::array<float, 24> vertices = {
        -1.0f,  1.0f, 0.0f, 1.0f, 0.0f, mirror ? 1.0f : 0.0f,   // l_t
        -1.0f, -1.0f, 0.0f, 1.0f, 0.0f, mirror ? 0.0f : 1.0f,   // l_b
         1.0f,  1.0f, 0.0f, 1.0f, 1.0f, mirror ? 1.0f : 0.0f,   // r_t
         1.0f, -1.0f, 0.0f, 1.0f, 1.0f, mirror ? 0.0f : 1.0f,   // r_b
    };
    switch (orientation)
    {
    case ST_CLOCKWISE_ROTATE_0:
        break;
    case ST_CLOCKWISE_ROTATE_90:
        vertices[4]  = mirror ? 1.0f : 0.0f; vertices[5]  = 1.0f;
        vertices[10] = mirror ? 0.0f : 1.0f; vertices[11] = 1.0f;
        vertices[16] = mirror ? 1.0f : 0.0f; vertices[17] = 0.0f;
        vertices[22] = mirror ? 0.0f : 1.0f; vertices[23] = 0.0f;
        break;
    case ST_CLOCKWISE_ROTATE_180:
        vertices[4]  = 1.0f; vertices[5]  = mirror ? 0.0f : 1.0f;
        vertices[10] = 1.0f; vertices[11] = mirror ? 1.0f : 0.0f;
        vertices[16] = 0.0f; vertices[17] = mirror ? 0.0f : 1.0f;
        vertices[22] = 0.0f; vertices[23] = mirror ? 1.0f : 0.0f;
        break;  
    case ST_CLOCKWISE_ROTATE_270:
        vertices[4]  = mirror ? 0.0 : 1.0f; vertices[5]  = 0.0f;
        vertices[10] = mirror ? 1.0 : 0.0f; vertices[11] = 0.0f;
        vertices[16] = mirror ? 0.0 : 1.0f; vertices[17] = 1.0f;
        vertices[22] = mirror ? 1.0 : 0.0f; vertices[23] = 1.0f;
        break;
    default:
        break;
    }
    return vertices;
}

bool STMobileWrapper::process(const st_effect_render_in_param_t *p_in_param, st_effect_render_out_param_t *p_out_param)
{
    if (p_in_param == nullptr || p_out_param == nullptr)
    {
        LOGE("the in_param and out_param must not be nil");
        return false;
    }

    __CHECK_EFFECT_HANDLE__

    __TIC1__(effect_render)
    st_result_t ret = st_mobile_effect_render(mhEffect, p_in_param, p_out_param);
    __TOC1__(effect_render)
    if (ret != ST_OK)
    {
        LOGE("effect render failed: %d", ret);
        return false;
    }
    return true;
}

bool STMobileWrapper::process(const st_image_t *p_src, st_rotate_type orientation, uint64_t detectConfig, st_mobile_human_action_t *p_human_action)
{
    if (p_src == nullptr || p_human_action == nullptr)
    {
        LOGE("the src img and human_action must not be nil");
        return false;
    }

    __CHECK_HUMAN_ACTION_HANDLE__

    if (!detectConfig) return true;

    __TIC1__(human_action_detect)
    st_result_t ret = st_mobile_human_action_detect(mhDetect, p_src->data, p_src->pixel_format, p_src->width, p_src->height, p_src->stride, orientation, detectConfig, p_human_action);
    __TOC1__(human_action_detect)
#if DEBUG_LOG
    LOGE("st_mobile_human_action_detect p_faces: %p", p_human_action->p_faces);
#endif
    if (ret != ST_OK)
    {
        LOGE("human action detect ret: %d", ret);
        return false;
    }
    return true;
}

bool STMobileWrapper::process(const st_image_t *p_src, st_rotate_type orientation, uint64_t detectConfig, st_mobile_animal_result_t *p_animal_result)
{
    if (p_src == nullptr || p_animal_result == nullptr)
    {
        LOGE("the src img and animal_result must not be nil");
        return false;
    }

    __CHECK_ANIMAL_HANDLE__

    if (!detectConfig) return true;

    __TIC1__(animal_detect)
    st_result_t ret = st_mobile_tracker_animal_face_track(mhAnimal, p_src->data, p_src->pixel_format, p_src->width, p_src->height, p_src->stride, orientation, detectConfig, p_animal_result);
    __TOC1__(animal_detect)            
    if (ret != ST_OK)
    {
        LOGE("animal face track failed: %d", ret);
        return false;
    }
    return true;
}

bool STMobileWrapper::addFaceAttributeModel(const char *path)
{
    if (path == nullptr)
    {
        LOGE("the param path must not be nil");
        return false;
    }

    st_result_t ret = st_mobile_face_attribute_create(path, &mhFaceAttribute);
    if (ret != ST_OK)
    {
        LOGE("face attribute create failed: %d", ret);
        return false;
    }
    return true;
}

bool STMobileWrapper::addFaceAttributeModel(const unsigned char *buffer, unsigned int length)
{
    if (buffer == nullptr || length == 0)
    {
        LOGE("the param buffer must not be nil");
        return false;
    }

    st_result_t ret = st_mobile_face_attribute_create_from_buffer(buffer, length, &mhFaceAttribute);
    if (ret != ST_OK)
    {
        LOGE("face attribute create failed: %d", ret);
        return false;
    }
    return true;
}

bool STMobileWrapper::process(const st_image_t *p_src, const st_mobile_human_action_t *p_human_action, st_mobile_attributes_t **p_attributes)
{
    if (p_human_action == nullptr)
    {
        LOGE("the param human_action and attributes_arrays must not be nil");
        return false;
    }
    return process(p_src, p_human_action->p_faces, p_human_action->face_count, p_attributes);
}

bool STMobileWrapper::process(const st_image_t *p_src, const st_mobile_face_t *p_faces, int face_count, st_mobile_attributes_t **p_attributes)
{
    if (p_src == nullptr || p_faces == nullptr || p_attributes == nullptr)
    {
        LOGE("the param must not be nil");
        return false;
    }

    if (face_count == 0)
    {
        return true;
    }

    __CHECK_FACEATTRIBUTE_HANDLE__

    st_mobile_106_t key_points[face_count];
    for (int i = 0; i < face_count; ++ i)
    {
        key_points[i] = p_faces[i].face106;
    }

    st_result_t ret = st_mobile_face_attribute_detect(mhFaceAttribute, 
                                                      p_src->data, p_src->pixel_format, 
                                                      p_src->width, p_src->height, p_src->stride, 
                                                      key_points, face_count, 
                                                      p_attributes);
    if (ret != ST_OK)
    {
        LOGE("face attribute detect failed: %d", ret);
        return false;
    }

    return true;
}

void STMobileWrapper::drawPoints(const st_pointf_t *p_points, int num, int width, int height, int outTex)
{
    if (p_points == nullptr || num <= 0)
    {
        return;
    }

    static int fbo, program = 0, vbo = 0;

    if (fbo == 0)
    {
        st_mobile_glutil_create_object(mhGLUtil, GL_OBJECT_FRAMEBUFFER, &fbo);
    }

    if (program == 0)
    {
        const std::string vsh = R"(
            attribute vec4 aPosition;
            void main() {
                gl_PointSize = 10.0;
                gl_Position = aPosition;
            }
        )";

        const std::string fsh = R"(
            precision mediump float;
            void main() {
                gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
            }
        )";
    
        st_mobile_glutil_create_object(mhGLUtil, GL_OBJECT_PROGRAM, &program);
        st_mobile_glutil_compile_program(mhGLUtil, program, vsh.c_str(), fsh.c_str());
    }

    st_mobile_glutil_bind_object(mhGLUtil, fbo);

    st_mobile_texture_t tex {};
    tex.id = outTex;
    tex.width = width;
    tex.height = height;
    tex.format = ST_PIX_FMT_RGBA8888;
    st_mobile_glutil_framebuffer_attach_tex(mhGLUtil, fbo, &tex);

    st_mobile_glutil_bind_object(mhGLUtil, program);

    if (vbo == 0)
    {
        st_mobile_glutil_create_object(mhGLUtil, GL_OBJECT_BUFFER, &vbo);
    } 

    st_pointf_t points[num];
    for (int i = 0;  i < num; ++ i)
    {
        points[i].x = p_points[i].x * 2.0f / width - 1.0f;
        points[i].y = p_points[i].y * 2.0f / height - 1.0f;
    }

    st_glbuffer_t buffer {};
    buffer.target = BUFFER_TARGET_VERTEX;
    buffer.usage = BUFFER_USAGE_DYNAMIC;
    buffer.size = sizeof(st_pointf_t) * num;
    buffer.buffer = (float *)&points;
    st_mobile_glutil_update_buffer(mhGLUtil, vbo, &buffer);

    st_mobile_glutil_bind_object(mhGLUtil, vbo);
    st_mobile_glutil_program_bind_vertex_attrib(mhGLUtil, program, "aPosition", 2, 4 * sizeof(float), (const void *)0);
    st_mobile_glutil_unbind_object(mhGLUtil, vbo);

    glDrawArrays(GL_POINTS, 0, num);

    st_mobile_glutil_unbind_object(mhGLUtil, program);
}

} // namespace mobile_wrapper

#if DESKTOP_DEBUG

int main()
{

    st_mobile_set_sse_only(true);
    mobile_wrapper::STMobileWrapper wrapper(mobile_wrapper::INNER_CONTEXT, nullptr);

    const std::string configJson = R"(
        {
            "license": "license_online.lic",
            "config": 1,
            "models": [
                "./models/M_SenseME_Face_Video_Template_p_4.0.0.model",
                "./models/M_SenseME_Segment_Figure_p_4.14.1.1.model",
                "./models/M_SenseME_Face_Extra_Advanced_Template_p_2.2.1.model",
                "./models/M_SenseME_FaceOcclusion_p_1.0.7.1.model"
            ]
        }
    )"; 
    wrapper.Initialize(configJson.c_str(), configJson.size());

    wrapper.addAnimalSubModel("./models/M_SenseME_DogFace_p_2.0.0.1.model");
    wrapper.addAnimalSubModel("./models/M_SenseME_CatFace_p_3.2.0.1.model");

    wrapper.addPackage("../stickers/hudie.zip");
    //wrapper.addPackage("../stickers/CatCircle.zip");
    //wrapper.addPackage("../stickers/DogCircle.zip");

    //wrapper.setBeautyPackage(EFFECT_BEAUTY_MAKEUP_CHEEK, "../makeups/cheek.zip");
    //wrapper.setBeautyStrength(EFFECT_BEAUTY_MAKEUP_CHEEK, 0.5);

#if 0
    int width = 1920, height = 1200;

    const std::string filePath("test2.yuv");
    std::ifstream file(filePath.c_str(), std::ios::binary | std::ios::ate);
    //std::streamsize size = file.tellg();
    int size = width * height * 3 / 2;
    file.seekg(0, std::ios::beg);

    std::vector<char> buffer(size);
    if (!file.read(buffer.data(), size))
    {
        LOGE("failed to load img: %s", filePath.c_str());
        return 1;
    }

    st_image_t p_src {};
    p_src.data = (unsigned char *)buffer.data();
    p_src.width = width;
    p_src.height = height;
    p_src.stride = width;
    p_src.pixel_format = ST_PIX_FMT_NV12;
#else
    cv::Mat img = cv::imread("../02.png", cv::IMREAD_UNCHANGED);
    //cv::Mat img = cv::imread("../cat.png", cv::IMREAD_UNCHANGED);
    int width = img.cols, height = img.rows;
    st_image_t p_src {}; 
    p_src.data = (unsigned char *)img.data;
    p_src.width = width;
    p_src.height = height;
    p_src.stride = width * 3;
    p_src.pixel_format = ST_PIX_FMT_RGB888;

    std::unique_ptr<unsigned char []> dst(new unsigned char[width * height * 3]);
    mobile_wrapper::trimImagePadding(img.data, width, height, width * 3, ST_PIX_FMT_RGB888, dst.get());
    mobile_wrapper::writeFile((const char *)dst.get(), width * height * 3, "remove_padding.rgba");

#endif

    st_image_t p_dst {};
    //p_dst.pixel_format = ST_PIX_FMT_RGBA8888;
    p_dst.pixel_format = ST_PIX_FMT_NV21;

    st_effect_in_image_t p_effect_src {};
    p_effect_src.image = p_src;
    p_effect_src.rotate = ST_CLOCKWISE_ROTATE_0;

    int i = 0;
    do {
        wrapper.process(&p_effect_src, &p_dst, ST_CLOCKWISE_ROTATE_0, false);
        i += 1;
    } while(i < 10);

    //mobile_wrapper::writeFile((char *)p_dst.data, width * height * 4, "ret.rgba");
    mobile_wrapper::writeFile((char *)p_dst.data, width * height * 3 / 2, "ret.yuv");
    
    //wrapper.makeEmpty();

    return 0;
}

#endif 
