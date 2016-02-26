# Docker files for OpenMS tools

This repository contains Docker files for the majority of the OpenMS tools. 
The files has been created by [CreateDockersForOpenMSTools.sh](https://github.com/PayamE/Containers/blob/master/CreateDockersForOpenMSTools.sh)
## OpenMS Docker using "apt-get"
Briefly, a OpenMS Docker file (Dockerfile) can be created using
```sh
FROM ubuntu:14.04
MAINTAINER YOUR NAME, YOUR EMAIL
RUN apt-get update && apt-get install --yes openms
ENTRYPOINT ["NAME OF THE EXECUTABLE"]
```
Here, we fully install OpenMS but set the entry pointing to one tool in OpenMS.

## OpenMS Docker by compiling the source code
Alternatively, you can make a Docker file using the following code:
```sh
FROM ubuntu:14.04
MAINTAINER YOUR NAME, YOUR EMAIL
RUN apt-get update && apt-get install cmake g++ autoconf qt4-dev-tools patch libtool make git --yes
RUN    apt-get install libboost-regex-dev libboost-iostreams-dev         libboost-date-time-dev libboost-math-dev \
libsvm-dev libglpk-dev libzip-dev zlib1g-dev libxerces-c-dev libbz2-dev --yes
RUN git clone https://github.com/OpenMS/OpenMS.git 
RUN git clone  https://github.com/OpenMS/contrib.git 
RUN mkdir contrib-build 
RUN cd /contrib-build && \
cmake -DBUILD_TYPE=LIST ../contrib && \
cmake -DBUILD_TYPE=SEQAN ../contrib && \
cmake -DBUILD_TYPE=WILDMAGIC ../contrib && \
cmake -DBUILD_TYPE=EIGEN ../contrib
RUN mkdir OpenMS-build
RUN cd OpenMS-build && \
cmake -DCMAKE_PREFIX_PATH="/contrib-build;/usr;/usr/local" -DBOOST_USE_STATIC=OFF ../OpenMS && \
make TARGET
ENV LD_LIBRARY_PATH /OpenMS-build/lib:$LD_LIBRARY_PATH
ENV PATH $PATH:/OpenMS-build/bin
ENTRYPOINT ["NAME OF THE TARGET"]
```
Using this method, we only target one OpenMS tool at the time.
## Building A Docker image
Please visit [here](https://github.com/phnmnl/workflow-demo/) to learn how to build, run, and share a Docker image.
