# Docker image
## Building
The image is can be built both by using the command `docker build .` or by using the script `rebuild`. The script also purges old images and containers and runs the container.

## Docker hub
Built image available at https://hub.docker.com/repository/docker/nereyser/andersen_py_helloworld or as tagged: `nereyser/andersen_py_helloworld`

## Run
The image is uses 5000 port. The command `docker run -d -p 5000:5000 nereyser/andersen_py_helloworld` is can be used to run image

## Result
There is HelloWorld page available at http://0.0.0.0:5000 (http://127.0.0.1:5000)

# TIL
Today I've learned basic information about containerization, its positive and negative sides in comparition with a virtual machines. I've seen work with Docker as example of such system. Also I got some information about DockerHub and how to work with it.

_03.12.2021_
