//
// Created on 2024/3/13.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "MediaPlayer.h"
#include "./common/common.h"
#include "./utils/log.h"
#include "utils/tools.h"
#include <multimedia/player_framework/native_averrors.h>
#include <multimedia/player_framework/native_avcapability.h>
#include <multimedia/player_framework/native_avcodec_base.h>
#include <multimedia/player_framework/native_avformat.h>
#include <queue>
#include <chrono>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

namespace MediaPlayerContext {

MediaPlayer *g_player = nullptr;

const char *PLAYERTAG = "MEDIAPLAYER";

chrono::high_resolution_clock::time_point begin = chrono::high_resolution_clock::now();

MediaPlayer::~MediaPlayer() {
    LOGD(PLAYERTAG, "MediaPlaye dealloc");
    Release();
    ReleaseResource();
}

void  MediaPlayer::ReleaseResource(){
    if (m_source != nullptr) {
        OH_AVSource_Destroy(m_source);
        m_source = nullptr;
    }
    if (m_demuxer != nullptr) {
        OH_AVDemuxer_Destroy(m_demuxer);
        m_demuxer = nullptr;
    }
}

P_RESULT MediaPlayer::setDataSource(string &filePath, int fd, int size){
    int fileFd = open(filePath.c_str(), O_RDONLY);
    struct stat fileStatus {};
    size_t fileSize = 0;
    if (stat(filePath.c_str(), &fileStatus) == 0) {
        fileSize = static_cast<size_t>(fileStatus.st_size);
    } else {
        LOGE(PLAYERTAG, "get stat failed");
    }
    if(fileFd <= 0 || fileSize == 0){
        fileFd = fd;
        fileSize = size;
    }
    OH_AVSource *source = OH_AVSource_CreateWithFD(fileFd, 0, fileSize);
    if (source == nullptr) {
        LOGE(PLAYERTAG, "oh avsource creat failed");
        return PLAYER_FILE_ERROR;
    }
    m_source = source;
    P_RESULT ret = createDemuxer(source);
    if(ret != PLAYER_OK) {
        ReleaseResource();
        return ret;
    }
    ret = getAVtracks(source);
    if (ret != PLAYER_OK) {
        ReleaseResource();
        return ret;
    }
    ret = getAVtrackIndexs();
    if (ret != PLAYER_OK){
        ReleaseResource();
        return ret;
    }
    g_player = this;
    return PLAYER_OK;
}

P_RESULT MediaPlayer::createDemuxer(OH_AVSource *source){
    if (source == nullptr) {
        LOGE(PLAYERTAG, "av source is empty");
        return PLAYER_DEMUXER_ERROR;
    }
    OH_AVDemuxer *demuxer = OH_AVDemuxer_CreateWithSource(source);
    if (demuxer == nullptr) {
        LOGE(PLAYERTAG,"create demuxer failed");
        return PLAYER_DEMUXER_ERROR;
    }
    m_demuxer = demuxer;
    return PLAYER_OK;
}


void MediaPlayer::getTrackFormat(OH_AVFormat *trackFormat) {
    const int uint32Size = 11;
    const char *uint32Key[uint32Size] = {OH_MD_KEY_MAX_INPUT_SIZE,
                                         OH_MD_KEY_WIDTH,
                                         OH_MD_KEY_HEIGHT,
                                         OH_MD_KEY_PIXEL_FORMAT,
                                         OH_MD_KEY_AUDIO_SAMPLE_FORMAT,
                                         OH_MD_KEY_PROFILE,
                                         OH_MD_KEY_AUD_CHANNEL_COUNT,
                                         OH_MD_KEY_AUD_SAMPLE_RATE,
                                         OH_MD_KEY_VIDEO_ENCODE_BITRATE_MODE,
                                         OH_MD_KEY_I_FRAME_INTERVAL,
                                         OH_MD_KEY_ROTATION};
    for (int i = 0; i < uint32Size; i++) {
        int32_t res = 0;
        OH_AVFormat_GetIntValue(trackFormat, uint32Key[i], &res);
        LOGE(PLAYERTAG, "track info %{public}s %{public}d", uint32Key[i], res);
    }
    const int doubleSize = 1;
    const char *doubleKey[doubleSize] = {OH_MD_KEY_FRAME_RATE};
    for (int i = 0; i < doubleSize; i++) {
        double res = 0;
        OH_AVFormat_GetDoubleValue(trackFormat, doubleKey[i], &res);
        LOGE(PLAYERTAG, "track info %{public}s %{public}f", doubleKey[i], res);
    }
}


void MediaPlayer::getCodeInfos(OH_AVFormat *format) {

    const int intSize = 22;
    const char *intKey[intSize] = {OH_MD_KEY_RANGE_FLAG,
                                   OH_MD_KEY_COLOR_PRIMARIES,
                                   OH_MD_KEY_TRANSFER_CHARACTERISTICS,
                                   OH_MD_KEY_MATRIX_COEFFICIENTS,
                                   OH_MD_KEY_REQUEST_I_FRAME,
                                   OH_MD_KEY_QUALITY,
                                   OH_MD_KEY_CODEC_CONFIG,
                                   OH_MD_KEY_TRACK_COUNT,
                                   OH_MD_KEY_CHANNEL_LAYOUT,
                                   OH_MD_KEY_BITS_PER_CODED_SAMPLE,
                                   OH_MD_KEY_AAC_IS_ADTS,
                                   OH_MD_KEY_SBR,
                                   OH_MD_KEY_COMPLIANCE_LEVEL,
                                   OH_MD_KEY_SCALING_MODE,
                                   OH_MD_MAX_INPUT_BUFFER_COUNT,
                                   OH_MD_MAX_OUTPUT_BUFFER_COUNT};
    for (int i = 0; i < intSize; i++) {
        int res = 0;
        OH_AVFormat_GetIntValue(format, intKey[i], &res);
        LOGE(PLAYERTAG, "video info %{public}s %{public}d", intKey[i], res);
    }

    const int stringSize = 11;
    const char *stirngKey[stringSize] = {OH_MD_KEY_TITLE,        OH_MD_KEY_ARTIST,    OH_MD_KEY_ALBUM,
                                         OH_MD_KEY_ALBUM_ARTIST, OH_MD_KEY_DATE,      OH_MD_KEY_COMMENT,
                                         OH_MD_KEY_GENRE,        OH_MD_KEY_COPYRIGHT, OH_MD_KEY_LANGUAGE,
                                         OH_MD_KEY_DESCRIPTION,  OH_MD_KEY_LYRICS};
    for (int i = 0; i < stringSize; i++) {
        const char *res = nullptr;
        OH_AVFormat_GetStringValue(format, stirngKey[i], &res);
        LOGE(PLAYERTAG, "video info %{public}s %{public}s", stirngKey[i], res);
    }

    const int pointSize = 3;
    const char *pointKey[pointSize] = {OH_MD_KEY_CODEC_CONFIG, OH_MD_KEY_IDENTIFICATION_HEADER, OH_MD_KEY_SETUP_HEADER};
    for (int i = 0; i < pointSize; i++) {
        uint8_t *config = nullptr;
        size_t size = 0;
        OH_AVFormat_GetBuffer(format, pointKey[i], &config, &size);
        LOGE(PLAYERTAG, "video info %{public}s %{public}d", pointKey[i], (int)size);
        for (int j = 0; j < size; j++) {
            LOGE(PLAYERTAG, "video info %{public}s  result %{public}d", pointKey[i], config[j]);
        }
    }
}

P_RESULT MediaPlayer::getAVtracks(OH_AVSource *source) {
    if (source == nullptr) {
        LOGE(PLAYERTAG, "av source is empty");
        return PLAYER_MEDIAO_TYPE_UNSUPPORT;
    }
    OH_AVFormat *sourceFormat = OH_AVSource_GetSourceFormat(source);
    if (sourceFormat == nullptr) {
        LOGE(PLAYERTAG,"get source format failed");
        return  PLAYER_MEDIAO_TYPE_UNSUPPORT;
    }
    int32_t trackCount = 0;
    OH_AVFormat_GetIntValue(sourceFormat, OH_MD_KEY_TRACK_COUNT, &trackCount);
    OH_AVFormat_Destroy(sourceFormat);
    sourceFormat = nullptr;
    m_trackCount = trackCount;
    return PLAYER_OK;
}
P_RESULT MediaPlayer::getAVtrackIndexs(){
    if (m_trackCount <= 0) {
        LOGE(PLAYERTAG, "get source format failed");
        return PLAYER_MEDIAO_TYPE_UNSUPPORT;
    }
    int32_t trackType;
    for (uint32_t index = 0; index < (static_cast<uint32_t>(m_trackCount)); index++) {
       // 获取轨道信息
       OH_AVFormat *trackFormat = OH_AVSource_GetTrackFormat(m_source, index);
        if (trackFormat == nullptr) {
          LOGE(PLAYERTAG, "get track format failed");
          return PLAYER_MEDIAO_TYPE_UNSUPPORT;
        }
        OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_TRACK_TYPE, &trackType);
        int32_t profile = 0;
        OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_PROFILE, &profile);
        OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_RANGE_FLAG, &m_fullRange);
        if (profile == HEVC_PROFILE_MAIN_10) {
          LOGE(PLAYERTAG, "player not support 10bits pixel data");
          return PLAYER_MEDIAO_TYPE_UNSUPPORT;
        }
/*        static_cast<OH_MediaType>(trackType) == OH_MediaType::MEDIA_TYPE_AUD ? m_audioTrackIndex = index
                                                                             : m_videoTrackIndex = index;*/
        // 获取视频轨宽高
        if (trackType == OH_MediaType::MEDIA_TYPE_VID) {
          int32_t w = 0, h = 0;
          OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_WIDTH, &w);
          OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_HEIGHT, &h);
            
          SetImageSize(w, h);

          int32_t rotate = 0;
          OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_ROTATION, &rotate);

          switch (rotate) {
          case 0:
              m_rotate = ROTATE_0;
              break;
          case 90:
              m_rotate = ROTATE_90;
              break;
          case 180:
              m_rotate = ROTATE_180;
              break;
          case 270:
              m_rotate = ROTATE_270;
              break;
          }

          OH_AVFormat_GetStringValue(trackFormat,OH_MD_KEY_CODEC_MIME, &codeMime);
            is_hevc = (strcmp(codeMime, OH_AVCODEC_MIMETYPE_VIDEO_HEVC) == 0);
             m_videoTrackIndex = index;
       }else if (trackType == OH_MediaType::MEDIA_TYPE_AUD) {
            m_audioTrackIndex = index;
        }
       OH_AVFormat_Destroy(trackFormat);
    }
    if (OH_AVDemuxer_SelectTrackByID(m_demuxer, m_audioTrackIndex) != AV_ERR_OK) {
       LOGE(PLAYERTAG, "select audio track failed: %{public}d", m_audioTrackIndex);
       return PLAYER_MEDIAO_TYPE_UNSUPPORT;
    }
    if (OH_AVDemuxer_SelectTrackByID(m_demuxer, m_videoTrackIndex) != AV_ERR_OK) {
       LOGE(PLAYERTAG, "select video track failed: %{public}d", m_videoTrackIndex);
       return PLAYER_MEDIAO_TYPE_UNSUPPORT;
    }
    OH_AVDemuxer_SeekToTime(m_demuxer, 0, OH_AVSeekMode::SEEK_MODE_CLOSEST_SYNC);
    return PLAYER_OK;
}

void MediaPlayer::SetImageSize(int32_t w, int32_t h)
{
    m_w = m_wstride = w;
    m_h = m_hstride = h;
    m_buffer.reset();
}

P_RESULT MediaPlayer::createVideoDecoder(){
    OH_AVCapability *capability = OH_AVCodec_GetCapability(is_hevc ? OH_AVCODEC_MIMETYPE_VIDEO_HEVC:OH_AVCODEC_MIMETYPE_VIDEO_AVC, false);
    const char *name = OH_AVCapability_GetName(capability);
    LOGE(PLAYERTAG, "ConfigureVideoDecoder g_codecName:%{public}s", name);
    OH_AVCodec *videoDec = OH_VideoDecoder_CreateByName(name);
    if (videoDec == nullptr) {
       LOGE(PLAYERTAG, "create videoDec error");
       return PLAYER_DECODE_ERROR;
    }
    m_videoDecoder = videoDec;
    int ret = SetVideoDecoderCallback();
    if(ret != AV_ERR_OK){
        LOGE(PLAYERTAG, "set video frame callback error");
        Release();
        return PLAYER_DECODE_ERROR;
    }
    OH_AVFormat *format = OH_AVFormat_Create();
    // 写入format
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_WIDTH, m_w);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_HEIGHT, m_h);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PIXEL_FORMAT, AV_PIXEL_FORMAT_NV21);
    OH_AVFormat_SetDoubleValue(format, OH_MD_KEY_FRAME_RATE, m_defaultFrameRate);
    
    // 配置解码器
    ret = OH_VideoDecoder_Configure(m_videoDecoder, format);
    if (ret != AV_ERR_OK) {
        Release();
        LOGE(PLAYERTAG, "videoDec configure error %{public}d", ret);
        return PLAYER_DECODE_ERROR;
    }
    OH_AVFormat_Destroy(format);
    return PLAYER_OK;
}

OH_AVErrCode MediaPlayer::SetVideoDecoderCallback(){
    m_signal = make_unique<VDecSignal>();
    if (m_signal == nullptr) {
       OH_LOG_ERROR(LOG_APP, "Failed to new VDecSignal");
       return AV_ERR_UNKNOWN;
    }
    m_cb.onError = [](OH_AVCodec *codec, int32_t errorCode, void *userData) {
        LOGE(PLAYERTAG, "callback Error");
        g_player->Release();
    };
    m_cb.onStreamChanged = [](OH_AVCodec *codec, OH_AVFormat *format, void *userData) {
        LOGE(PLAYERTAG, "onStreamChanged");
        int32_t current_width = 0;
        int32_t current_height = 0;
        OH_AVFormat_GetIntValue(format, OH_MD_KEY_WIDTH, &current_width);
        OH_AVFormat_GetIntValue(format, OH_MD_KEY_HEIGHT, &current_height);
        
        g_player->SetImageStride(current_width, current_height);
    };
    m_cb.onNeedInputData = [](OH_AVCodec *codec, uint32_t index, OH_AVMemory *data, void *userData) {
//         LOGE(PLAYERTAG, "onNeedInputData");
        VDecSignal *signal = static_cast<VDecSignal*>(userData);
        unique_lock<mutex> lock(signal->m_inMutex);
        signal->m_inIdxQueue.push(index);
        signal->m_inBufferQueue.push(data);
        signal->m_inCond.notify_all();
    };
    m_cb.onNeedOutputData = [](OH_AVCodec *codec, uint32_t index, OH_AVMemory *data, OH_AVCodecBufferAttr *attr,
                               void *userData) {
//         LOGE(PLAYERTAG, "onNeedInputData");
        chrono::high_resolution_clock::time_point now = chrono::high_resolution_clock::now();
        chrono::milliseconds interval = chrono::duration_cast<chrono::milliseconds>(now - begin);
        begin = now;
//         LOGE(PLAYERTAG, "interval %{public}lu", interval);
        VDecSignal *signal = static_cast<VDecSignal *>(userData);
        unique_lock<mutex> lock(signal->m_outMutex);
        signal->m_outCond.wait(lock, [signal]() { return signal->m_outIdxQueue.size() <= 5; });
        signal->m_outIdxQueue.push(index);
        signal->m_outBufferQueue.push(data);
        signal->m_attrQueue.push(*attr);
        signal->m_outCond.notify_all();
    };
    return OH_VideoDecoder_SetCallback(m_videoDecoder, m_cb, static_cast<void *>(m_signal.get()));
}

P_STATE MediaPlayer::getPlayerState(){
    return m_state;
}

P_RESULT MediaPlayer::start(){
    int ret = createVideoDecoder();
    if (ret != PLAYER_OK){
        return PLAYER_DECODE_ERROR;
    }
    ret = startDecode();
    m_state = PLAYER_PLAYING;
    if (stateCallback)
        stateCallback(m_state);
    if (ret != PLAYER_OK) {
        return PLAYER_DECODE_ERROR;
    }
    return PLAYER_OK;
}

P_RESULT MediaPlayer::pause() {
    m_state = PLAYER_PAUSE;
    if (stateCallback)
        stateCallback(m_state);
    unique_lock<mutex> lock(m_signal->m_inMutex);
    m_signal->m_paused = true;
    m_signal->m_inCond.notify_all();
    lock.unlock();
    return PLAYER_OK; 
}

P_RESULT MediaPlayer::resume() {
    m_state = PLAYER_PLAYING;
    if (stateCallback)
        stateCallback(m_state);
    unique_lock<mutex> lock(m_signal->m_inMutex);
    m_signal->m_paused = false;
    m_signal->m_inCond.notify_all();
    lock.unlock();
    return PLAYER_OK; 
}

P_RESULT MediaPlayer::setFrameCallback(Callback func){
    callback = func;
    return PLAYER_OK;
}

void MediaPlayer::setStateCallback(StateCallback func){
    stateCallback = func;
}

void MediaPlayer::InputFunc(){
    uint32_t frameCount_ = 0;
    uint32_t errCount = 0;
    while (true) {
        if (!m_isRunning.load()) {
          break;
       }
        uint32_t index;
        unique_lock<mutex> lock(m_signal->m_inMutex);
        m_signal->m_inCond.wait(lock, [this](){
            return m_signal->m_inIdxQueue.size() > 0 && !m_signal->m_paused;
        });
        if (!m_isRunning.load()) {
          break;
        }
        index = m_signal->m_inIdxQueue.front();
        auto buffer = m_signal->m_inBufferQueue.front();
        OH_AVCodecBufferAttr attr;
        OH_AVDemuxer_ReadSample(m_demuxer, m_videoTrackIndex, buffer, &attr);
        if (attr.flags == AVCODEC_BUFFER_FLAGS_EOS) {
            EndInput(attr, index, frameCount_);
            break;
        }
        if(OH_VideoDecoder_PushInputData(m_videoDecoder, index, attr)){
            errCount++;
            LOGE(PLAYERTAG, "video push input data error");
        }
        m_signal->m_inIdxQueue.pop();
        m_signal->m_inBufferQueue.pop();
        frameCount_++;
        this_thread::sleep_for(chrono::milliseconds(static_cast<int>(30)));
    }
}

void MediaPlayer::EndInput(OH_AVCodecBufferAttr attr, int index, int frameCount) {
    attr.pts = 0;
    attr.size = 0;
    attr.offset = 0;
    OH_VideoDecoder_PushInputData(m_videoDecoder, index, attr);
    OH_LOG_ERROR(LOG_APP, "video decode input eos %{public}d", frameCount);
}

void MediaPlayer::OutputFunc(){
    uint32_t decCount = 0;
    while (true) {
        if (!m_isRunning.load()) {
            break;
        }
        unique_lock<mutex> lock(m_signal->m_outMutex);
        m_signal->m_outCond.wait(lock, [this]() { return m_signal->m_outIdxQueue.size() > 0 && !m_signal->m_paused;});
        if (!m_isRunning.load()) {
          break;
        }
        uint32_t index = m_signal->m_outIdxQueue.front();
        OH_AVCodecBufferAttr attr = m_signal->m_attrQueue.front();
        OH_AVMemory *data = m_signal->m_outBufferQueue.front();
        if (attr.flags == AVCODEC_BUFFER_FLAGS_EOS) {
            WaitForEos();
            OH_LOG_ERROR(LOG_APP, "video output decode frameSize:eos%{public}d", decCount);
            DispatchVideoBuffer(data, attr, -1);
//             if (callback) callback(OH_AVMemory_GetAddr(data), m_w, m_h, m_rotate, -1);
            break;
        }
            
        DispatchVideoBuffer(data, attr, 0);
//         if (callback) callback(OH_AVMemory_GetAddr(data), m_w, m_h, m_rotate, 0);

        int ret = OH_VideoDecoder_FreeOutputData(m_videoDecoder, index);
        if (ret != AV_ERR_OK) {
            LOGE(PLAYERTAG, "free FreeOutputDat error");
        }
        m_signal->m_outIdxQueue.pop();
        m_signal->m_attrQueue.pop();
        m_signal->m_outBufferQueue.pop();
        decCount++;
        m_signal->m_outCond.notify_all();
    }
}

void MediaPlayer::SetImageStride(int32_t wstride, int32_t hstride)
{
    m_wstride = wstride;
    m_hstride = hstride;
}

void MediaPlayer::DispatchVideoBuffer(OH_AVMemory *data, const OH_AVCodecBufferAttr& attr, int state)
{
    if (nullptr == callback) return;
    
    uint8_t* pbuffer = OH_AVMemory_GetAddr(data) + attr.offset;
    int32_t bufferSize = attr.size - attr.offset;
    
    const int32_t expBufferSz = m_wstride * m_hstride * 3 / 2;
    if (expBufferSz != bufferSize)
    {
        OH_LOG_ERROR(LOG_APP, "video buffer size mismatch, input: %{public}d, while expected: %{public}d (%{public}d X %{public}d)", bufferSize, expBufferSz, m_wstride, m_hstride);
        return ;
    }
    
    if (m_w == m_wstride && m_h == m_hstride)
    {
        callback(pbuffer, m_w, m_h, m_rotate, state);
        return;
    }
    
    if (!m_buffer)
    {
        m_buffer.reset(new char[m_w * m_h * 3 / 2]);    
    }
    
    // trim padding.
    if (m_w != m_wstride)
    {
        char* pdst = m_buffer.get();
        for (int32_t i=0; i<m_h; ++i)
        {
            memcpy(pdst + i*m_w, pbuffer + i * m_wstride, m_w);
        }
        
        pdst += m_h * m_w;
        pbuffer += m_hstride * m_wstride;
        
        for (int32_t i=0; i<m_h/2; ++i)
        {
            memcpy(pdst + i*m_w, pbuffer + i * m_wstride, m_w);
        }
    }
    else
    {
        // copy y.
        memcpy(m_buffer.get(), pbuffer, m_w * m_h);
        
        memcpy(m_buffer.get() + m_w * m_h, pbuffer + m_w * m_hstride, m_w * m_h / 2);
    }
    
    callback(m_buffer.get(), m_w, m_h, m_rotate, state);
}

P_RESULT MediaPlayer::startDecode(){
    m_isRunning.store(true);
    int ret = OH_VideoDecoder_Prepare(m_videoDecoder);
    if (ret != AV_ERR_OK) {
        LOGE(PLAYERTAG, "videoDec prepare error");
        m_isRunning.store(false);
        Release();
        return PLAYER_DECODE_ERROR;
    }
    ret = OH_VideoDecoder_Start(m_videoDecoder);
    if (ret != AV_ERR_OK) {
        LOGE(PLAYERTAG, "videoDec start error");
        m_isRunning.store(false);
        Release();
        return PLAYER_DECODE_ERROR;
    }
    
    m_inputLoop = make_unique<thread>(&MediaPlayer::InputFunc, this);
    if (m_inputLoop == nullptr) {
        LOGE(PLAYERTAG, "Failed to decode create input loop");
        m_isRunning.store(false);
        OH_VideoDecoder_Stop(m_videoDecoder);
        Release();
        return PLAYER_DECODE_ERROR;
    }

    m_outputLoop = make_unique<thread>(&MediaPlayer::OutputFunc, this);
    if (m_outputLoop == nullptr) {
        LOGE(PLAYERTAG, "Failed to decode create output loop");
        m_isRunning.store(false);
        OH_VideoDecoder_Stop(m_videoDecoder);
        Release();
        return PLAYER_DECODE_ERROR;
    }
    return PLAYER_OK; 
}

static void ConsumeElement(void *data) {
    auto signal = static_cast<VDecSignal *>(data);
    unique_lock<mutex> lock(signal->m_inMutex);
    signal->m_paused = false;
    signal->m_inCond.notify_all();
    lock.unlock();
}

P_RESULT MediaPlayer::stop(){
    if (m_videoDecoder == nullptr) {
        return PLAYER_DECODE_ERROR;
    }
    thread t(ConsumeElement, static_cast<void *>(m_signal.get()));
    t.join();
    Release();
    m_state = PLAYER_STOP;
    if (stateCallback)
        stateCallback(m_state);
    return PLAYER_OK;
}

void MediaPlayer::WaitForEos() {
    m_state = PLAYER_STOP;
    if (stateCallback)
        stateCallback(m_state);
}


int32_t MediaPlayer::Release(){
    m_isRunning.store(false);
    StopInLoop();
    StopOutLoop();
    int32_t ret = AV_ERR_OK;
    if (m_videoDecoder != nullptr) {
        ret = OH_VideoDecoder_Flush(m_videoDecoder);
        ret = OH_VideoDecoder_Stop(m_videoDecoder);
        ret = OH_VideoDecoder_Destroy(m_videoDecoder);
        m_videoDecoder = nullptr;
    }
    if (m_signal != nullptr) {
        m_signal = nullptr;
    }
    return ret;
}

void MediaPlayer::StopInLoop(){
    if (m_inputLoop != nullptr && m_inputLoop->joinable()) {
        unique_lock<mutex> lock(m_signal->m_inMutex);
        Tools::ClearIntQueue(m_signal->m_inIdxQueue);
        Tools::ClearMemoryBufferQueue(m_signal->m_inBufferQueue);
        m_signal->m_inCond.notify_all();
        lock.unlock();
        m_inputLoop->join();
    }
}

void MediaPlayer::StopOutLoop(){
    if (m_outputLoop != nullptr && m_outputLoop->joinable()) {
        unique_lock<mutex> lock(m_signal->m_outMutex);
        Tools::ClearIntQueue(m_signal->m_outIdxQueue);
        Tools::ClearBufferQueue(m_signal->m_attrQueue);
        Tools::ClearMemoryBufferQueue(m_signal->m_outBufferQueue);
        m_signal->m_outCond.notify_all();
        lock.unlock();
        m_outputLoop->join();
    }
}

}
