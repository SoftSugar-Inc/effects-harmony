//
// Created on 2024/3/13.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_COMMON_H
#define EFFECTSHARMONY_COMMON_H

typedef enum VIDEO_FORMAT {
    RGBA = 1,
    NV21 = 2,
}VIDEO_FORMAT;

typedef enum  VIDEO_ROTATE{
    ROTATE_0 = 0,
    ROTATE_90 = 1,
    ROTATE_180 = 2,
    ROTATE_270 = 3,
}VIDEO_ROTATE;

typedef enum P_RESULT {
    PLAYER_OK = 0,
    PLAYER_FILE_ERROR = 1,
    PLAYER_DEMUXER_ERROR = 2,
    PLAYER_MEDIAO_TYPE_UNSUPPORT = 3,
    PLAYER_DECODE_ERROR = 4,
}P_RESULT;

typedef enum P_STATE {
    PLAYER_NODE = 0,
    PLAYER_PLAYING = 1,
    PLAYER_PAUSE = 2,
    PLAYER_STOP = 3,
}P_STATE;

typedef enum R_RESULT {
    RECORDER_OK = 0,
    RECORDER_FILE_ERROR = 1,
    RECORDER_MUXER_ERROR = 2,
    RECORDER_MEDIAO_TYPE_UNSUPPORT = 3,
    RECORDER_ENCODE_ERROR = 4,
    RECORDER_PARAM_ERROR = 5
} R_RESULT;

typedef enum R_STATE {
    RECORDER_NODE = 0,
    RECORDER_START = 1,
    RECORDER_PLAYINT = 2,
    RECORDER_STOP = 3,
    RECORDER_COMPLETE = 4,
} R_STATE;


#endif //EFFECTSHARMONY_COMMON_H
