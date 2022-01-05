FROM python:3.6-slim

RUN apt-get update && \
    apt-get -y install \
      python3-pip \
      zlib1g-dev \
      gcc libc-dev \
      upx && \
    pip3 install --upgrade pip \
      flask \
      pyinstaller \
      staticx \
      patchelf-wrapper &&\
    mkdir -p /opt/python/tmp
