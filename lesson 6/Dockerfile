FROM debian as builder

RUN apt-get update && \
    apt-get -y install \
      python3 \
      python3-pip \
      zlib1g-dev \
      gcc libc-dev && \
    pip3 install \
      flask \
      pyinstaller \
      staticx \
      patchelf-wrapper

WORKDIR /opt/python/
ADD main.py .

RUN pyinstaller -F -s main.py && \
    staticx -l /lib/x86_64-linux-gnu/libgcc_s.so.1 --strip dist/main dist/main_app

RUN mkdir tmp


FROM scratch

COPY --from=builder /opt/python/dist/main_app /bin/
COPY --from=builder tmp /tmp

EXPOSE 5000
CMD ["/bin/main_app"]
