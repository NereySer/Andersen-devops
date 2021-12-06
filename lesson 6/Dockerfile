FROM alpine as builder

RUN apk add --no-cache python3 py3-pip zlib-dev gcc libc-dev && \
    pip3 install --no-cache flask pyinstaller

WORKDIR /opt/python/
ADD main.py .

RUN pyinstaller -F -s main.py

FROM alpine

COPY --from=builder /opt/python/dist/main /bin/

EXPOSE 5000
CMD ["/bin/main"]
