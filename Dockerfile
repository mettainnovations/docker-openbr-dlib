FROM nvidia/cuda:8.0-cudnn5-devel

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y build-essential cmake cmake-curses-gui wget unzip git libavcodec-dev libavutil-dev libavutil-ffmpeg54 libavformat-dev libavfilter-dev libavdevice-dev libjpeg8-dev libpng16-dev libtiff5-dev libx264-dev libgstreamer1.0-dev libboost-all-dev qt5-default libqt5svg5-dev qtcreator && \
    apt-get clean -y

RUN mkdir -p /home/developer
ENV HOME /home/developer
WORKDIR /home/developer

# Download OpenCV
RUN wget -nv -O opencv-2.4.13.zip https://github.com/Itseez/opencv/archive/2.4.13.zip && \
    unzip -q opencv-2.4.13.zip

# Install OpenCV
RUN cd opencv-2.4.13 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DWITH_QT=YES -DWITH_OPENMP=YES -DWITH_CUDA=YES -DCMAKE_CXX_FLAGS="-Wno-deprecated-declarations" -DCUDA_ARCH_BIN="30 35" .. && \
    make -j4 && \
    make install && \
    cd ../.. && \
    rm -rf opencv-2.4.13*

# Download OpenBR
RUN git clone https://github.com/biometrics/openbr.git && \
    cd openbr && \
    git checkout v1.1.0 && \
    git submodule init && \
    git submodule update

# Build OpenBR
RUN cd openbr && \
    mkdir build &&  cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBR_WITH_OPENCV_NONFREE=OFF -DCUDA_USE_STATIC_CUDA_RUNTIME=OFF .. && \
    make -j4 && \
    make install

# Download DLIB
RUN cd ~ && \
    apt-get -y install libopenblas-dev liblapack-dev && \
    wget -nv -O dlib.tar.bz2 http://dlib.net/files/dlib-19.4.tar.bz2 && \
    tar xf dlib.tar.bz2 && \
    cd dlib-19.4 && \
    cp -R dlib /usr/local/include

# Build DLIB
RUN cd ~/dlib-19.4 && \
    mkdir build &&  cd build && \
    cmake -DDLIB_USE_CUDA=1 -DDLIB_USE_BLAS=1 -DDLIB_PNG_SUPPORT=1 -DDLIB_JPEG_SUPPORT=1 -DUSE_AVX_INSTRUCTION=1 .. && \
    make -j4

# Clean up
RUN apt-get remove --purge -y wget unzip

# Casa Blanca
RUN apt-get install -y libcpprest-dev

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer && \
    adduser developer video
USER developer
