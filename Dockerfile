FROM ubuntu:18.04

MAINTAINER "tnds82 <tndsrepo@gmail.com>"

#Dependencies
ENV BUILD_DEPS="cmake git build-essential pkg-config gettext libavahi-client-dev libssl-dev zlib1g-dev wget bzip2 git-core liburiparser-dev libpcre2-dev libdvbcsa-dev python debhelper ccache libcurl4-gnutls-dev"

#Build Tvheadend
RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
        $BUILD_DEPS curl ca-certificates libva-dev \
        libssl1.0.0 zlib1g liburiparser1 libavahi-common3 libavahi-client3 libdbus-1-3 libselinux1 liblzma5 libgcrypt20 libpcre3 libgpg-error0 libdvbcsa1 && \
    git clone https://github.com/tvheadend/tvheadend.git /tvh-build && \
    cd /tvh-build && \
    ./Autobuild.sh -o deps -t debian && \
    ./configure --prefix=/usr \ 
                --enable-ccache \
                --enable-ffmpeg_static\ 
                --enable-hdhomerun_static \
                --enable-libav \
                --enable-nvenc \
                --enable-nonfree && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /tvh-build
    
RUN groupadd -g 10710 tvheadend && \
    useradd -u 10710 -g tvheadend tvheadend && \
    install -o tvheadend -g tvheadend -d /config

VOLUME /config
EXPOSE 9981 9982

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["-u", "tvheadend", "-g", "tvheadend", "-c", "/config"]
