FROM ubuntu:16.04

MAINTAINER tnds82

ENV BUILD_DEPS="build-essential cmake pkg-config libavahi-client-dev libssl-dev zlib1g-dev wget libcurl4-gnutls-dev git-core liburiparser-dev libdvbcsa-dev"

RUN apt update
RUN apt install -y --no-install-suggests --no-install-recomends \
    $BUILD_DEPS git dvb-apps -y

RUN git clone https://github.com/tvheadend/tvheadend.git /tvh-build && \
    cd /tvh-build && \
    git pull && \
    ./Autobuild.sh -o deps -t debian && \
    apt install ccache -y && \
    ./configure --prefix=/usr \
                --enable-ccache \
                --enable-ffmpeg_static \
                --enable-hdhomerun_static && \
    make && \
    make install && \
    rm -rf /tvh-build && \
    apt-get purge -y $BUILD_DEPS && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 10710 tvheadend && \
    useradd -u 10710 -g tvheadend tvheadend && \
    install -o tvheadend -g tvheadend -d /tvh-data

VOLUME /tvh-data
EXPOSE 9981 9982

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["-u", "tvheadend", "-g", "tvheadend", "-c", "/tvh-data/conf"]
