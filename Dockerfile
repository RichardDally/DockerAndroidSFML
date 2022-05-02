FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

# DEV tools
RUN apt-get -y install -qq \
    build-essential \
    emacs-nox \
    wget \
    git \
    cmake \
    unzip \
    default-jdk \
    clang

# SFML dependencies
RUN apt-get -y install -qq \
    libgl1-mesa-dev \
    libudev-dev \
    libopenal-dev \
    libvorbis-dev \
    libflac-dev \
    libx11-dev \
    libxrandr-dev \
    libx11-xcb-dev \
    libxcb-randr0-dev \
    libxcb-image0-dev \
    libjpeg-dev \
    libfreetype6-dev

# Turn the detached message off
RUN git config --global advice.detachedHead false

# Libraries versions
ENV SFML_TAG_VERSION=2.5.1
ENV TGUI_TAG_VERSION=0.10

WORKDIR /workspace

# Compile SFML static release libraries
RUN git clone --branch ${SFML_TAG_VERSION} -q https://github.com/SFML/SFML sfml
RUN mkdir -p /opt/sfml
# RUN cmake -Wno-dev -S sfml -B sfml_build \
#     	  -DCMAKE_INSTALL_PREFIX:string=/opt/sfml \
# 	  -DBUILD_SHARED_LIBS=OFF
# RUN cmake --build sfml_build --config release --parallel 8 --target install

# Compile TGUI static release libraries
RUN git clone --branch ${TGUI_TAG_VERSION} -q https://github.com/texus/TGUI tgui
RUN mkdir -p /opt/tgui
# RUN cmake -Wno-dev -S tgui -B tgui_build \
#     	  -DCMAKE_INSTALL_PREFIX:string=/opt/tgui \
# 	  -DSFML_DIR:string=/opt/sfml/lib/cmake/SFML \
# 	  -DTGUI_BACKEND=SFML_GRAPHICS \
# 	  -DTGUI_SHARED_LIBS=OFF \
# 	  -DTGUI_BUILD_EXAMPLES=OFF \
# 	  -DTGUI_BUILD_GUI_BUILDER=OFF
# RUN cmake --build tgui_build --config release --parallel 8 --target install


# Android
# ENV ANDROID_NDK_VERSION=24
# ENV ANDROID_ZIP_NAME=android-ndk-r${ANDROID_NDK_VERSION}-linux.zip
# ENV NDK_PATH=android_ndk

# RUN wget --no-verbose --directory-prefix ${NDK_PATH} https://dl.google.com/android/repository/${ANDROID_ZIP_NAME}
# RUN unzip -q -d ${NDK_PATH} ${NDK_PATH}/${ANDROID_ZIP_NAME}
# RUN rm -rf ${NDK_PATH}/${ANDROID_ZIP_NAME}

# ./build-sfml.sh ${NDK_DOWNLOAD_PATH}/android-ndk-r${LATEST_NDK_VERSION}

# RUN cmake \
#     -Wno-dev \
#     -S sfml \
#     -B sfml_build \
#     -DANDROID_ABI=${CURRENT_ABI} \
#     -DANDROID_PLATFORM=android-21 \
#     -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake \
#     -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang \
#     -DCMAKE_SYSTEM_NAME=Android \
#     -DCMAKE_ANDROID_NDK=${NDK_PATH} \
#     -DCMAKE_ANDROID_STL_TYPE=c++_static \
#     -DCMAKE_BUILD_TYPE=Debug

#     -G "Generator of your choice" \
#     -DCMAKE_SYSTEM_VERSION=14 \

# RUN cmake \
#     -Wno-dev \
#     -S sfml \
#     -B sfml_build \
#     -DCMAKE_SYSTEM_NAME=Android \
#     -DCMAKE_SYSTEM_VERSION=${ANDROID_NDK_VERSION} \
#     -DCMAKE_ANDROID_NDK=${NDK_PATH} \
#     -DCMAKE_ANDROID_STL_TYPE=c++_static \
#     -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a


ENV ANDROID_API=32
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_NDK_ROOT ${ANDROID_SDK_ROOT}/ndk-bundle
ENV PATH $PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin
ENV PATH $PATH:${ANDROID_SDK_ROOT}/platform-tools
ENV PATH $PATH:${ANDROID_SDK_ROOT}/ndk-bundle

# ENV PATH ${PATH}:${ANDROID_HOME}/platform-tools/${ANDROID_NDK_HOME}
# ENV PATH ${PATH}:${ANDROID_HOME}/ndk-bundle
# ENV PATH ${PATH}:${ANDROID_HOME}/tools/bin/


RUN wget --quiet  https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O /tmp/tools.zip

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools
RUN unzip -q /tmp/tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools
RUN mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest
RUN rm -v /tmp/tools.zip
RUN mkdir -p /root/.android/ && touch /root/.android/repositories.cfg

RUN yes | sdkmanager --licenses
RUN yes | sdkmanager --update
RUN yes | sdkmanager --install "platforms;android-${ANDROID_API}" platform-tools
RUN yes | sdkmanager --install ndk-bundle
RUN yes | sdkmanager --install "cmake;3.18.1"

# https://developer.android.com/ndk/guides/abis
# arm64-v8a
#ENV ANDROID_ABI=armeabi-v7a
# ENV ANDROID_ABI=x86
ENV ANDROID_ABI=x86_64

# RUN cmake \
#     -Wno-dev \
#     -S sfml \
#     -B sfml_build \
#     -DCMAKE_SYSTEM_NAME=Android \
#     -DCMAKE_SYSTEM_VERSION=${ANDROID_NDK_VERSION} \
#     -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
#     -DANDROID_ABI=${CURRENT_ABI} \
#     -DANDROID_PLATFORM=android-21 \
#     -DCMAKE_ANDROID_NDK=${ANDROID_NDK_ROOT} \
#     -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang \
#     -DCMAKE_ANDROID_STL_TYPE=c++_static \
#     -DCMAKE_ANDROID_ARCH_ABI=${ANDROID_ABI}


# cmake \
#       -DANDROID_ABI=${CURRENT_ABI} \
#       -DANDROID_PLATFORM=android-21 \
#       -stdlib=libc++ \
#       -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}build/cmake/android.toolchain.cmake \
#       -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang \
#       -DCMAKE_SYSTEM_NAME=Android \
#       -DCMAKE_ANDROID_NDK=${NDK_PATH} \
#       -DCMAKE_ANDROID_STL_TYPE=c++_static \
#       -DCMAKE_BUILD_TYPE=Debug \
#       -G "Unix Makefiles" \
#       ../..

COPY hello-jni hello-jni

#RUN ${ANDROID_SDK_ROOT}/cmake/3.18.1/bin/cmake \
RUN cmake \
    -Wno-dev \
    -Hhello-jni/app/src/main/cpp \
    -DCMAKE_FIND_ROOT_PATH=hello-jni/app/.cxx/cmake/universalDebug/prefab/armeabi-v7a/prefab \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=armeabi-v7a \
    -DANDROID_NDK=${ANDROID_NDK_ROOT} \
    -DANDROID_PLATFORM=android-23 \
    -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a \
    -DCMAKE_ANDROID_NDK=${ANDROID_NDK_ROOT} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=hello-jni/app/build/intermediates/cmake/universalDebug/obj/armeabi-v7a \
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=hello-jni/app/build/intermediates/cmake/universalDebug/obj/armeabi-v7a \
    -DCMAKE_MAKE_PROGRAM=${ANDROID_SDK_ROOT}/cmake/3.18.1/bin/ninja \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_VERSION=23 \
    -B hello_jni_build \
    -DCMAKE_INSTALL_PREFIX:string=/opt/hello-jni \
    -GNinja
RUN cmake --build hello_jni_build --config release --parallel 8
