# Python lite
FROM ubuntu:18.04 as BUILD

# Prevent unnecessary internal buffering
ENV PYTHONUNBUFFERED 1

# Add cmake to image - required to install openCV and dlib
RUN apt-get update && \
    apt-get install -y  \
    build-essential \
    nasm \
    cmake \
    gfortran \
    git \
    wget \
    curl \
    graphicsmagick \
    libgraphicsmagick1-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
    python3-dev \
    python3-numpy \
    python-pip\
    software-properties-common \
    unzip \
    qt5-default \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

RUN wget https://cmake.org/files/v3.8/cmake-3.8.1.tar.gz && \
    tar xf cmake-3.8.1.tar.gz && \
    cd cmake-3.8.1 && \
    apt-get install  -y openssl libssl-dev && \
    ./configure && \
    make && \
    make install

RUN mkdir -p ~/opencv cd ~/opencv && \
    wget https://github.com/Itseez/opencv/archive/4.1.1.zip && \
    unzip 4.1.1.zip && \
    rm 4.1.1.zip && \
    mv opencv-4.1.1 OpenCV && \
    cd OpenCV && \
    mkdir build && \
    cd build && \
    cmake \
    -DWITH_QT=ON \
    -DWITH_OPENGL=OFF \
    -DFORCE_VTK=ON \
    -DWITH_TBB=ON \
    -DWITH_GDAL=ON \
    -DWITH_XINE=ON \
    -DBUILD_EXAMPLES=OFF .. && \
    make -j4 && \
    make install && \
    ldconfig

RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/libjpeg-turbo_1.5.1.orig.tar.gz && \
    tar xvf libjpeg-turbo_1.5.1.orig.tar.gz && \
    cd libjpeg-turbo-1.5.1/ && \
    autoreconf -fiv && \
    mkdir build  && \
    cd build && \
    sh ../configure --prefix=/usr/libjpeg-turbo --mandir=/usr/share/man --with-jpeg8 --enable-static --docdir=/usr/share/doc/libjpeg-turbo-1.5.1 && \
    make install

RUN apt-get update && apt-get install -y --fix-broken && apt-get install -y python3-pip
RUN pip3 install --user dlib
RUN ls /root/.local/lib


FROM ubuntu:18.04 as ENGINE


RUN apt-get update && \
    apt-get install -y \
    python3-numpy \
    libavcodec-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    qt5-default \
    python3-dev \
    libatlas-base-dev

COPY --from=BUILD /usr/local/include /usr/local/include
COPY --from=BUILD /usr/local/lib /usr/local/lib
COPY --from=BUILD /usr/local/include/opencv4 /usr/local/include/opencv4
COPY --from=BUILD /usr/libjpeg-turbo /usr/libjpeg-turbo

COPY --from=BUILD /root/.local /root/.local
