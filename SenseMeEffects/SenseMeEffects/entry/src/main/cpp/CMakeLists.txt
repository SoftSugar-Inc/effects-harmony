# the minimum version of CMake. this render PixelBuffer
cmake_minimum_required(VERSION 3.4.1)
project(EffectsHarmony)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
add_definitions(-DOHOS_PLATFORM)

include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/sdk/include
)

add_library(entry SHARED
    sdk/wrapper/json11.cpp
    sdk/wrapper/STMobileWrapper.cpp
    sdk/wrapper/STMobileWrapperNapi.cpp
    render/GLRender.cpp
    manager/GLManager.cpp
    log/ohos_log.cpp
    Index.cpp)

find_library(
    # Sets the name of the path variable.
    EGL-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    EGL
)

find_library(
    # Sets the name of the path variable.
    GLES-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    GLESv3
)

find_library(
    # Sets the name of the path variable.
    hilog-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    hilog_ndk.z
)

find_library(
    # Sets the name of the path variable.
    libace-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    ace_ndk.z
)

find_library(
    # Sets the name of the path variable.
    libnapi-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    ace_napi.z
)

find_library(
    # Sets the name of the path variable.
    libuv-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    uv
)
add_library(stmobile SHARED IMPORTED)
set_target_properties(stmobile PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/sdk/libs/libst_mobile.so)

target_link_libraries(entry PUBLIC stmobile)
target_link_libraries(entry PUBLIC
    ${EGL-lib} ${GLES-lib} ${hilog-lib} ${libace-lib} ${libnapi-lib} ${libuv-lib} ${NATIVERENDER_ROOT_PATH}/sdk/libs/libst_mobile.so)
