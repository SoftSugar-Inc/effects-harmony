//
// Created on 2024/3/29.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_RECORDBEAN_H
#define EFFECTSHARMONY_RECORDBEAN_H

#include <bits/alltypes.h>
#include <sys/types.h>
#include <multimedia/player_framework/native_avformat.h>
#include <multimedia/player_framework/native_avcodec_base.h>
#include <multimedia/player_framework/native_avformat.h>
#include <multimedia/player_framework/native_avcodec_videoencoder.h>
#include <string>

using namespace std;

namespace MediaRecorderContext{
class RecordBean {
    public:
      int32_t m_fd{};
      //video
      int32_t m_width{1920};
      int32_t m_height{1080};
      int32_t m_bitRate{4000000};
      uint32_t m_frameRate{25};
      int32_t m_iFrameInterval{2300};
      int32_t m_rotate{0};
      OH_AVPixelFormat m_pixelFormat{AV_PIXEL_FORMAT_NV21};
      string m_videoMime{OH_AVCODEC_MIMETYPE_VIDEO_AVC};
      int32_t m_videoTrack{0};
      //audio
      uint32_t m_sampleRate;
      string m_audioMine;
      int32_t m_audiotTrack{1};
};
}


#endif //EFFECTSHARMONY_RECORDBEAN_H
