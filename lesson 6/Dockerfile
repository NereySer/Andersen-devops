FROM alpine
RUN apk add --no-cache python3 py3-pip
RUN pip3 install --no-cache flask
RUN apk del py3-pip
ARG src="lesson 2/python/main.py"
ADD ${src} /opt/python/
EXPOSE 5000
CMD ["python3", "/opt/python/main.py"]
