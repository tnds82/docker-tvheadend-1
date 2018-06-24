FROM ubuntu:16.04

MAINTAINER tnds82

RUN apt-get update
RUN apt-get install -y git dvb-apps ccache \

RUN git clone https://github.com/tvheadend/tvheadend.git /tvh-build && \
    cd /tvh-build && \
RUN bash Autobuild.sh -o deps -t debian && \
RUN AUTOBUILD_CONFIGURE_EXTRA="--enable-ccache --enable-ffmpeg_static --enable-hdhomerun_static" ./Autobuild.sh -t xenail-amd64 -j$(nproc) && \
    make && \
    make install && \
    rm -rf /tvh-build && \
    
RUN groupadd -g 10710 tvheadend && \
    useradd -u 10710 -g tvheadend tvheadend && \
    install -o tvheadend -g tvheadend -d /config

VOLUME /tvh-data
EXPOSE 9981 9982

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["-u", "tvheadend", "-g", "tvheadend", "-c", "/config"]
