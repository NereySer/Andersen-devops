FROM alpine
RUN apk add --no-cache python3 py3-pip && \
    pip3 install --no-cache flask && \
    apk del py3-pip
ADD main.py /opt/python/
EXPOSE 5000
CMD ["python3", "/opt/python/main.py"]
