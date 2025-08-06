//
// Created on 2024/3/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_MEDIARECORDER_H
#define EFFECTSHARMONY_MEDIARECORDER_H

#include <multimedia/player_framework/native_avmuxer.h>
#include <multimedia/player_framework/native_avcapability.h>
#include <multimedia/player_framework/native_avcodec_base.h>
#include <multimedia/player_framework/native_avformat.h>
#include <multimedia/player_framework/native_avcodec_videoencoder.h>
#include <multimedia/player_framework/native_avmemory.h>

#include <mutex>
#include <queue>
#include <string>
#include "./common/common.h"
#include "RecordBean.h"
#include <memory>
#include <multimedia/player_framework/native_avmemory.h>

using namespace std;

namespace MediaRecorderContext {

class RSignal{
    public:
        mutex m_inputMutex;
        mutex m_outputMutex;
        condition_variable m_inputCond;
        condition_variable m_outputCond;
        queue<uint32_t> m_outputIndexQueue;
        queue<OH_AVCodecBufferAttr> m_outputArrQueue;
        queue<OH_AVMemory*> m_outputBufferQueue;
        queue<OH_AVMemory*> m_inputBufferQueue;
        uint32_t m_inputBufferSize;
        atomic<bool> m_stopInput{false};
};

class MediaRecorder {
    public:
        R_RESULT setRecordPath();
        R_RESULT startRecord();
        void stopRecord();
        unique_ptr<RecordBean> recordBean = nullptr;
        R_RESULT pushFrameData(uint8_t* data, int width, int height);
    private:
        OH_AVMuxer* m_muxer{};
        OH_AVCodec* m_videoEncoder{};
        R_RESULT addAudioTrack();
        R_RESULT addVideoTrack();
        R_RESULT createVideoEncoder();
        R_RESULT configVideoEncoder();
        R_RESULT setRecordCallback();
        R_RESULT startEncode();
        void stopEncode();
        void release();
        OH_AVCodecAsyncCallback m_cb{};
        unique_ptr<thread> m_takethread{};
        void takeFunc();
        void stopOutLoop();
        unique_ptr<RSignal> m_signal{};
        uint32_t m_width{};
        uint32_t m_height{};
        atomic<bool> m_outputIsRuning{false};
};

}

#endif //EFFECTSHARMONY_MEDIARECORDER_H
