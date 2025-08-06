//
// Created on 2024/3/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "MediaRecorder.h"
#include "common/common.h"
#include "../utils/log.h"
#include <multimedia/player_framework/native_averrors.h>
#include <netinet/ip.h>
#include <thread>
#include "./utils/tools.h"


namespace MediaRecorderContext {

const char* RECORDTAG = "RECORCD_TAG";

int64_t g_timeStamp = 0;

R_RESULT MediaRecorder::setRecordPath(){
    if (recordBean == nullptr) {
        LOGE(RECORDTAG, "please set record bean first");
        return RECORDER_FILE_ERROR;
    }
    
    m_muxer = OH_AVMuxer_Create(recordBean->m_fd, AV_OUTPUT_FORMAT_MPEG_4);
    if (m_muxer== nullptr) {
        LOGE(RECORDTAG, "muxer create error");
        release();
        return RECORDER_MUXER_ERROR;
    }
    
    if (recordBean->m_videoMime.data() == nullptr) {
        LOGE(RECORDTAG,"please set recordder paramters");
        release();
        return RECORDER_FILE_ERROR;
    }
    
    OH_AVFormat *formatVideo = OH_AVFormat_CreateVideoFormat(recordBean->m_videoMime.data(), recordBean->m_width, recordBean->m_height);
    if (formatVideo == nullptr) {
        LOGE(RECORDTAG, "create video format error");
        release();
        return RECORDER_FILE_ERROR;
    }
    OH_AVMuxer_AddTrack(m_muxer, &recordBean->m_videoTrack, formatVideo);
    OH_AVFormat_Destroy(formatVideo);
    int orientation = 0;
    switch (recordBean->m_rotate) { 
        case 0:
            orientation = 0;
            break;
        case 1:
            orientation = 90;
            break;
        case 2:
            orientation = 180;
            break;
        case 3:
            orientation = 270;
            break;
    }
    OH_AVMuxer_SetRotation(m_muxer, orientation);
    if (OH_AVMuxer_Start(m_muxer) != AV_ERR_OK) {
        LOGE(RECORDTAG, "muxer start error");
        release();
        return RECORDER_MUXER_ERROR;
    }
    return RECORDER_OK;
}

R_RESULT MediaRecorder::startRecord(){
    if (recordBean == nullptr) {
        LOGE(RECORDTAG, "please set record bean first");
        return RECORDER_FILE_ERROR;
    }
    if (createVideoEncoder() != RECORDER_OK) {
        LOGE(RECORDTAG, "create video encoder error");
        return RECORDER_FILE_ERROR;
    }
    if (configVideoEncoder() != RECORDER_OK) {
        LOGE(RECORDTAG, "config video encoder error");
        release();
        return RECORDER_ENCODE_ERROR;
    }
    if(startEncode() != RECORDER_OK){
        LOGE(RECORDTAG, "start muxe error");
        release();
        return RECORDER_ENCODE_ERROR;
    }
    return RECORDER_OK;
}

void MediaRecorder::stopRecord(){
    stopEncode();
    stopOutLoop();
    release();
}

R_RESULT MediaRecorder::createVideoEncoder(){
    m_videoEncoder = OH_VideoEncoder_CreateByMime(recordBean.get()->m_videoMime.data());
    if(m_videoEncoder == nullptr ){
        return RECORDER_ENCODE_ERROR;
    }
    return RECORDER_OK;
}

R_RESULT MediaRecorder::configVideoEncoder(){
    OH_AVFormat* format = OH_AVFormat_Create();
    if (format == nullptr) {
        LOGE(RECORDTAG, "create video encoder error");
        release();
        return RECORDER_ENCODE_ERROR;
    }
    int32_t rateMode = static_cast<int32_t>(OH_VideoEncodeBitrateMode::CBR);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_WIDTH, recordBean.get()->m_width);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_HEIGHT, recordBean.get()->m_height);
    m_width = recordBean.get()->m_width; m_height = recordBean.get()->m_height;
    OH_AVCapability *cap = OH_AVCodec_GetCapability(recordBean.get()->m_videoMime.data(), true);
    string name = OH_AVCapability_GetName(cap);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PIXEL_FORMAT, recordBean.get()->m_pixelFormat);
    OH_AVFormat_SetDoubleValue(format, OH_MD_KEY_FRAME_RATE, recordBean.get()->m_frameRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_BITRATE, recordBean.get()->m_bitRate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_VIDEO_ENCODE_BITRATE_MODE, rateMode);
    int32_t profile = static_cast<int32_t>(OH_AVCProfile::AVC_PROFILE_BASELINE);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PROFILE, profile);
    int ret = OH_VideoEncoder_Configure(m_videoEncoder, format);
    if(ret != AV_ERR_OK){
        LOGE(RECORDTAG, "config video encoder error");
        return RECORDER_ENCODE_ERROR;
    }
    OH_AVFormat_Destroy(format);
    OH_VideoEncoder_Prepare(m_videoEncoder);
    return setRecordCallback();
}

R_RESULT MediaRecorder::setRecordCallback(){
    if (m_width <= 0 || m_height <= 0) {
        LOGE(RECORDTAG, "parameters error");
        return RECORDER_PARAM_ERROR;
    }
    m_signal = make_unique<RSignal>();
    if(m_signal == nullptr){
        LOGE(RECORDTAG, "set video record calback error");
        release();
        return RECORDER_ENCODE_ERROR;
    }
    int dst_width;
    if (recordBean->m_width % 16) {
        dst_width = recordBean->m_width / 16 * 16 + 16;
    }
    else{
        dst_width = recordBean->m_width;
    }
    m_signal->m_inputBufferSize = dst_width * recordBean->m_height * 3/2;
    m_signal->m_stopInput.store(false);
    m_cb.onError = [](OH_AVCodec *codec, int32_t errorCode, void *userData){
        LOGE(RECORDTAG, "video encode error");
    };
    m_cb.onStreamChanged = [](OH_AVCodec *codec, OH_AVFormat *format, void *userData) {
        LOGE(RECORDTAG, "video encode stream changed");
    };
    m_cb.onNeedInputData = [](OH_AVCodec *codec, uint32_t index, OH_AVMemory *data, void *userData) {
        RSignal *signal = static_cast<RSignal*>(userData);
        unique_lock<mutex> lock(signal->m_inputMutex);
        signal->m_inputCond.wait(lock, [&signal]{return signal->m_inputBufferQueue.size() > 0 || signal->m_stopInput;});
        int pts = g_timeStamp;// * 40 / 25 ;
        g_timeStamp += 1000 * 1000 * 1.0 / 30.0f;
        OH_AVCodecBufferAttr attr = { 
          .pts = pts,
          .size = 0,
          .offset = 0,
        };
        if(signal->m_stopInput){
            attr.flags = AVCODEC_BUFFER_FLAGS_EOS;
            int32_t ret = OH_VideoEncoder_PushInputData(codec, index, attr);
            if (ret != AV_ERR_OK) {
                LOGE(RECORDTAG, "video encoder push input data error");
            }
            LOGE(RECORDTAG, "stop vidoe encode");
            return;
        }
        if (signal->m_inputBufferQueue.empty()) {
            return;
        }
        attr.size = signal->m_inputBufferSize;
        attr.flags = AVCODEC_BUFFER_FLAGS_CODEC_DATA;
        OH_AVMemory* raw = signal->m_inputBufferQueue.front();
        memcpy(OH_AVMemory_GetAddr(data), OH_AVMemory_GetAddr(raw), signal->m_inputBufferSize);
        int32_t ret = OH_VideoEncoder_PushInputData(codec, index, attr);
        if (ret != AV_ERR_OK) {
            LOGE(RECORDTAG, "stop vidoe encode");
        }
        signal->m_inputBufferQueue.pop();
        OH_AVMemory_Destroy(raw);
    };
    m_cb.onNeedOutputData = [](OH_AVCodec *codec, uint32_t index, OH_AVMemory *data,
                                          OH_AVCodecBufferAttr *attr, void *userData) {
        RSignal *signal = static_cast<RSignal*>(userData);
        unique_lock<mutex> lock(signal->m_outputMutex);
        signal->m_outputIndexQueue.push(index);
        signal->m_outputBufferQueue.push(data);
        if (!attr) {
            LOGE(RECORDTAG, "m_outputArrQueue attr is null");
        } else {
            if (attr->flags == AVCODEC_BUFFER_FLAGS_EOS) {
                LOGE(RECORDTAG, "attr is EOS");
            }
            signal->m_outputArrQueue.push(*attr);
        }
        signal->m_outputCond.notify_all();
    };
    return OH_VideoEncoder_SetCallback(m_videoEncoder, m_cb, static_cast<void *>(m_signal.get())) != AV_ERR_OK ? RECORDER_ENCODE_ERROR:RECORDER_OK;
}

R_RESULT MediaRecorder::pushFrameData(uint8_t *data, int width, int height){
    if (data == nullptr || m_width != width || m_height != height) {
        LOGE(RECORDTAG, "push frame data parameters error %{public}d %{public}d %{public}d %{public}d", m_width, m_height, width, height);
        return RECORDER_PARAM_ERROR;
    }
    if (!m_outputIsRuning) return RECORDER_PARAM_ERROR;
    unique_lock<mutex> lock(m_signal->m_inputMutex);
    uint32_t dataSize = m_signal->m_inputBufferSize;

    OH_AVMemory *memory = OH_AVMemory_Create(dataSize);
    if (width % 16)
    {
        int stride = width / 16 * 16 + 16;
        for (int i = 0; i < height * 3 / 2; i++) {
            memcpy(OH_AVMemory_GetAddr(memory) + i * stride, data + i * width, width);
        }
    }
    else
    {
        memcpy(OH_AVMemory_GetAddr(memory), data, dataSize);
    }

    m_signal->m_inputBufferQueue.push(memory);
    m_signal->m_inputCond.notify_one();
    return RECORDER_OK;
}

R_RESULT MediaRecorder::startEncode(){
    m_outputIsRuning.store(true);
    g_timeStamp = 0;
    int ret = OH_VideoEncoder_Start(m_videoEncoder);
    if (ret != AV_ERR_OK) {
        LOGE(RECORDTAG, "videoDec start error");
        m_outputIsRuning.store(false);
        release();
        return RECORDER_ENCODE_ERROR;
    }
    m_takethread = make_unique<thread>(&MediaRecorder::takeFunc, this);
    if(m_takethread == nullptr){
        LOGE(RECORDTAG, "videoDec start error");
        m_outputIsRuning.store(false);
        OH_VideoEncoder_Stop(m_videoEncoder);
        release();
        return RECORDER_ENCODE_ERROR;
    }
    return RECORDER_OK;
}

void MediaRecorder::takeFunc(){
    uint32_t errCount = 0;
    int64_t enCount = 0;
    while(true){
        if (!m_outputIsRuning.load()) {
            break;
        }
        unique_lock<mutex> lock(m_signal->m_outputMutex);
        m_signal->m_outputCond.wait(lock, [this]() {
            return m_signal->m_outputIndexQueue.size() > 0;
        });
        if(!m_outputIsRuning.load()) {
            break;
        }
        uint32_t index = m_signal->m_outputIndexQueue.front();
        OH_AVCodecBufferAttr attr = m_signal->m_outputArrQueue.front();
        if(attr.flags == AVCODEC_BUFFER_FLAGS_EOS){
            m_outputIsRuning.store(false);
            m_signal->m_outputCond.notify_all();
            LOGE(RECORDTAG, "video record finish");
            break;
        }
        OH_AVMemory *memory = m_signal->m_outputBufferQueue.front();
        if(OH_AVMuxer_WriteSample(m_muxer, recordBean->m_videoTrack, memory, attr) != AV_ERR_OK){
            LOGE(RECORDTAG, "write video data error");
        }
        if(OH_VideoEncoder_FreeOutputData(m_videoEncoder, index) != AV_ERR_OK){
            LOGE(RECORDTAG, "free output data error");
            errCount += 1;
        }
        if(errCount > 0){
            LOGE(RECORDTAG, "encode error");
            m_outputIsRuning.store(false);
            m_signal->m_outputCond.notify_all();
            release();
            break;
        }
        m_signal->m_outputIndexQueue.pop();
        m_signal->m_outputArrQueue.pop();
        m_signal->m_outputBufferQueue.pop();
        enCount += 1;
    }
}

void MediaRecorder::stopEncode(){
    if (m_signal) {
        unique_lock<mutex> lock(m_signal->m_inputMutex);
        m_signal->m_stopInput.store(true);
        m_signal->m_inputCond.notify_one();
    }
}

void MediaRecorder::stopOutLoop(){
    if(m_takethread != nullptr && m_takethread->joinable()){
        unique_lock<mutex> lock(m_signal->m_outputMutex);
        Tools::ClearIntQueue(m_signal->m_outputIndexQueue);
        Tools::ClearBufferQueue(m_signal->m_outputArrQueue);
        Tools::ClearMemoryBufferQueue(m_signal->m_outputBufferQueue);
        lock.unlock();
        m_takethread->join();
    }
}

void MediaRecorder::release(){
    if (m_muxer != nullptr) {
        OH_AVMuxer_Stop(m_muxer);
        OH_AVMuxer_Destroy(m_muxer);
        m_muxer = nullptr;
    }
    int32_t ret = AV_ERR_OK;
    if(m_videoEncoder != nullptr){
        ret = OH_VideoEncoder_Flush(m_videoEncoder);
        ret = OH_VideoEncoder_Stop(m_videoEncoder);
        ret = OH_VideoEncoder_Destroy(m_videoEncoder);
        m_videoEncoder = nullptr;
    }
    if(m_signal != nullptr){
        m_signal = nullptr;
    }
}

}