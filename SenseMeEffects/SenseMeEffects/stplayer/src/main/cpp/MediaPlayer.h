//
// Created on 2024/3/13.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_MEDIAPLAYER_H
#define EFFECTSHARMONY_MEDIAPLAYER_H

#include <multimedia/player_framework/native_avdemuxer.h>
#include <multimedia/player_framework/native_avsource.h>
#include <multimedia/player_framework/native_avformat.h>
#include <multimedia/player_framework/native_avcodec_videodecoder.h>
#include "./common/common.h"
#include <string>
#include <queue>
#include <mutex>
#include <atomic>
#include <thread>

using namespace  std;

namespace MediaPlayerContext {

typedef void (*Callback)(void *data, int widht, int height, int rotate, int state);
typedef void (*StateCallback)(int state);

class VDecSignal {
public:
    mutex m_inMutex;
    mutex m_outMutex;
    condition_variable m_inCond;
    condition_variable m_outCond;
    condition_variable m_outMaxCond;
    queue<uint32_t> m_inIdxQueue;
    queue<uint32_t> m_outIdxQueue;
    queue<OH_AVMemory *> m_inBufferQueue;
    queue<OH_AVMemory *> m_outBufferQueue;
    queue<OH_AVCodecBufferAttr> m_attrQueue;
    bool m_paused{false};
};

struct VideoInfo{
    int width{};
    int height{};
    int rotate{};
};

class MediaPlayer {
public:
    MediaPlayer() = default;
    ~MediaPlayer();
    P_RESULT setDataSource(string& filePath, int fd, int size);
    P_RESULT start();
    P_RESULT pause();
    P_RESULT resume();
    P_RESULT stop();
    P_STATE getPlayerState();
    VideoInfo getVideoInfo(){
        return VideoInfo{.width=m_w, .height = m_h, .rotate = m_rotate};
    }
    int32_t Release();
    void ReleaseResource();
    void WaitForEos();
    P_RESULT setFrameCallback(Callback func);
    void setStateCallback(StateCallback func);


    int32_t m_rotate{};
    int32_t is_hevc{};
    const char *codeMime{};
    
    unique_ptr<VDecSignal> m_signal{};
    OH_AVDemuxer *m_demuxer = nullptr;
    OH_AVCodec *m_videoDecoder = nullptr;
    double m_defaultFrameRate = 30.0;
    void StopInLoop();
    void StopOutLoop();
    void InputFunc();
    void OutputFunc();
    void EndInput(OH_AVCodecBufferAttr attr, int index, int frameCount);
    
    void SetImageStride(int32_t wstride, int32_t hstride);
    void SetImageSize(int32_t w, int32_t h);
    
private:
    OH_AVSource* m_source = nullptr;
    int m_trackCount{};
    uint32_t m_audioTrackIndex{};
    uint32_t m_videoTrackIndex{};
    int m_fullRange{};
    OH_AVCodecAsyncCallback m_cb{};
    P_RESULT createDemuxer(OH_AVSource* source);
    P_RESULT createFormat(OH_AVSource* source);
    P_RESULT getAVtracks(OH_AVSource *source);
    P_RESULT getAVtrackIndexs();
    P_RESULT createVideoDecoder();
    P_RESULT startDecode();
    void getCodeInfos(OH_AVFormat* format);
    void getTrackFormat(OH_AVFormat *trackFormat);
    void PutElement(void *data);
    void TakeElement(void *data);
    OH_AVErrCode SetVideoDecoderCallback();
    atomic<bool> m_isRunning{false};
    unique_ptr<std::thread> m_inputLoop{};
    unique_ptr<std::thread> m_outputLoop{};
    StateCallback stateCallback = nullptr;
    Callback callback = nullptr;
    P_STATE m_state;
    
    int32_t m_w{};
    int32_t m_h{};
    int32_t m_wstride = 0;
    int32_t m_hstride = 0;
    std::unique_ptr<char[]> m_buffer;

    void DispatchVideoBuffer(OH_AVMemory *data, const OH_AVCodecBufferAttr& attr, int state);
};
} // namespace MediaPlayerContext

#endif //EFFECTSHARMONY_MEDIAPLAYER_H
