# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(myNpmLib)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

add_subdirectory(boundscheck)

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(stplayer SHARED
    MediaPlayer.cpp
    MediaRecorder.cpp
    napi_init.cpp
    utils/tools.cpp
    )


target_link_libraries(stplayer PUBLIC
    libace_napi.z.so
    libhilog_ndk.z.so
    libnative_media_adec.so
    libnative_media_aenc.so
    libnative_media_codecbase.so
    libnative_media_core.so
    libnative_media_vdec.so
    libnative_media_venc.so
    libnative_media_avdemuxer.so
    libnative_media_avsource.so
    libnative_media_avmuxer.so
    uv)
