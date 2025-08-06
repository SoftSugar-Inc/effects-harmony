//
// Created on 2024/3/19.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "tools.h"
#include "log.h"
#include "boundscheck/third_party_bounds_checking_function/include/securec.h"

void Tools::ClearIntQueue(std::queue<uint32_t> &q) {
    std::queue<uint32_t> empty;
    swap(empty, q);
}

void Tools::ClearBufferQueue(std::queue<OH_AVCodecBufferAttr> &q) {
    std::queue<OH_AVCodecBufferAttr> empty;
    swap(empty, q);
}

void Tools::ClearMemoryBufferQueue(std::queue<OH_AVMemory *> &q) {
    std::queue<OH_AVMemory *> empty;
    swap(empty, q);
}
