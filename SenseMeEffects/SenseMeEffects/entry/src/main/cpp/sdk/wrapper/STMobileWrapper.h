#ifndef _ST_MOBILE_WRAPPER_H_
#define _ST_MOBILE_WRAPPER_H_

#include "st_mobile_effect.h"
#include "st_mobile_human_action.h"
#include "st_mobile_color_convert.h"
#include "st_mobile_face_attribute.h"
#include <cstdint>
#include <vector>
#include <array>
#include <memory>
#include <chrono>

namespace mobile_wrapper
{

extern bool trimImagePadding(const st_image_t *p_src, unsigned char *p_dst);
extern bool trimImagePadding(const unsigned char *p_src, int width, int height, int stride, st_pixel_format format, unsigned char *p_dst);

enum HandleConfig
{
    NONE          = 0x0,
    INNER_CONTEXT = 0x1,
};

enum RenderingResizingMode
{
    Stretch,
    AspectFit,
    AspectFill
};

class STMobileWrapper
{
public:
    STMobileWrapper(HandleConfig config, void *window);
    ~STMobileWrapper();

    enum class EffectsMode 
    {
        PREVIEW = 0, 
        PHOTO,
        VIDEO
    };

    bool Initialize(const char *buffer, unsigned int length);
    bool Initialize(EffectsMode mode);

    static bool checkLicense(const char *licensePath);
    static bool checkLicense(const char *buffer, unsigned int length);
   
    bool addSubModel(const char *path);
    bool addSubModel(const unsigned char *buffer, unsigned int length);
    bool addAnimalSubModel(const char *path);
    bool addAnimalSubModel(const unsigned char *buffer, unsigned int length);
    bool resetHumanAction();

    bool setParam(st_effect_param_t param, float value);
    bool setParam(st_human_action_param_type param, float value);
    
    int addPackage(const char *packagePath);
    int addPackage(const char *buffer, unsigned int length);

    int changePackage(const char *packagePath);
    int changePackage(const char *buffer, unsigned int length);

    bool removePackage(int packageId);

    bool clearPackages();

    bool setPackageBeautyStrength(int packageId, st_effect_beauty_group_t type, float strength);
    bool replayPackage(int packageId);

    uint64_t getDetectConfig() const;
    uint64_t getCustomEventConfig() const;
    uint64_t getTriggerActions() const;
    uint64_t getAnimalDetectConfig() const;

    bool setBeautyPackage(st_effect_beauty_type_t type, const char *path);
    bool setBeautyPackage(st_effect_beauty_type_t type, const char *buffer, unsigned int length);
    bool setBeautyMode(st_effect_beauty_type_t type, int mode);
    bool setBeautyStrength(st_effect_beauty_type_t type, float strength);
    bool setBeautyParam(st_effect_beauty_param_t type, float value);

    std::vector<st_effect_beauty_info_t> getOverlappedBeautyInfo() const;

    bool process(const st_effect_in_image_t *p_src, st_image_t *p_dst, st_rotate_type orientation, bool origin = false, bool immediately = false);

    bool makeCurrent();
    bool makeEmpty();

    bool resetPixelReader();

    void updateWindowSize(int width, int height) { mWndWidth = width; mWndHeight = height; }
    void setResizingMode(RenderingResizingMode mode) { mResizingMode = mode; }

    static bool isAuthorized() { return mbAuth; }

    // for render
    bool process(const st_effect_render_in_param_t *p_in_param, st_effect_render_out_param_t *p_out_param);

    // for human action
    bool process(const st_image_t *p_src, st_rotate_type orientation, uint64_t detectConfig, st_mobile_human_action_t *p_human_action);

    // for animal
    bool process(const st_image_t *p_src, st_rotate_type orientation, uint64_t detectConfig, st_mobile_animal_result_t *p_animal_result);

    // for face attribute
    bool addFaceAttributeModel(const char *path);
    bool addFaceAttributeModel(const unsigned char *buffer, unsigned int length);

    bool process(const st_image_t *p_src, const st_mobile_human_action_t *p_human_action, st_mobile_attributes_t **p_attributes);
    bool process(const st_image_t *p_src, const st_mobile_face_t *p_faces, int face_count, st_mobile_attributes_t **p_attributes);

protected:
    std::array<float, 24> verticesForOrientation(st_rotate_type orientation, bool vMirror) const; 

    void drawPoints(const st_pointf_t *p_points, int num, int width, int height, int outTex);

private:
    bool processImpl(const st_effect_in_image_t *p_src, st_image_t *p_dst, st_rotate_type orientation, bool origin = false, bool immediately = false);

    void destoryGLResources();

    st_result_t createTexture(int width, int height, int &name, st_mobile_texture_t *p_tex);
    class GLContextGuard
    {
        STMobileWrapper *mWrapper;
    public:
        GLContextGuard(STMobileWrapper *wrapper)
            : mWrapper(wrapper)
        {
            mWrapper->makeCurrent();
        }

        ~GLContextGuard()
        {
            mWrapper->makeEmpty();
        }
    };

private:
    st_handle_t mhEffect = nullptr;
    st_handle_t mhDetect = nullptr;
    st_handle_t mhGLUtil = nullptr;
    st_handle_t mhColorConvert = nullptr;
    st_handle_t mhAnimal = nullptr;
    st_handle_t mhFaceAttribute = nullptr;

    static bool mbAuth;

    void *mWindow = nullptr;
    int mWndWidth = 0;
    int mWndHeight = 0;
    RenderingResizingMode mResizingMode = RenderingResizingMode::Stretch;

    int mTexName = 0;
    int mMidTexName = 0;
    int mProgram = 0;
    int mVbo = 0;
    int mReadPixel = 0;
    int mMid2TexName = 0;
    int mFboName = 0;

    EffectsMode mMode = EffectsMode::PREVIEW;
    HandleConfig mHandleConfig = HandleConfig::NONE;

    int mFrameIndex = 0;
    std::chrono::time_point<std::chrono::high_resolution_clock> mTimeStart;

    unsigned int mFbo = 0;
    unsigned int mMSAAFbo = 0;
    unsigned int mTexId = 0;
    unsigned int mRboId = 0;

    std::shared_ptr<st_image_t> mCacheImage;
    std::shared_ptr<st_image_t> mSrcImg;
};

}

#endif
