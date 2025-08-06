//
// Created on 2024/3/19.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_TOOLS_H
#define EFFECTSHARMONY_TOOLS_H

#include <multimedia/player_framework/native_avcodec_base.h>
#include <mutex>
#include <queue>
#include <sys/stat.h>

using namespace std;

typedef struct DemuxElement{
    OH_AVMemory* mem;
    OH_AVCodecBufferAttr attr;
}DemuxElement;

class Tools {
public:
    static void ClearIntQueue(std::queue<uint32_t> &q);
    static void ClearBufferQueue(std::queue<OH_AVCodecBufferAttr> &q);
    static void ClearMemoryBufferQueue(std::queue<OH_AVMemory *> &q);
};

#endif //EFFECTSHARMONY_TOOLS_H
