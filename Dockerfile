FROM ubuntu:14.04
MAINTAINER Stephanie Herman, stephanie.herman.3820@student.uu.se

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install --yes texlive-binaries
RUN echo "deb http://ftp.acc.umu.se/mirror/CRAN/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN apt-get update --yes && apt-get install --yes --force-yes r-base

RUN mkdir -p /data 
WORKDIR /data
VOLUME /data

ADD BlankFilter.r ./
ENTRYPOINT ["Rscript", "BlankFilter.r"] 
