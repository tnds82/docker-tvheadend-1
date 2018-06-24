FROM ubuntu:16.04

MAINTAINER tnds82

RUN apt-get update
RUN apt-get install git dvb-apps ccache libva-dev -y

RUN git clone https://github.com/intel/libva.git /libva && \
    cd /libva && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make install

RUN git clone https://github.com/tvheadend/tvheadend.git /tvh-build && \
    cd /tvh-build && \
    ./Autobuild.sh -o deps -t debian && \
    ./configure --prefix=/usr \ 
                --enable-ccache \
                --enable-ffmpeg_static\ 
                --enable-hdhomerun_static \
                --enable-libav \
                --enable-vaapi \
                --enable-nvenc \
                --enable-nonfree && \
    make -j$(nproc) && \
    make -j$(nproc) install
RUN rm -rf /tvh-build
    
RUN groupadd -g 10710 tvheadend && \
    useradd -u 10710 -g tvheadend tvheadend && \
    install -o tvheadend -g tvheadend -d /config

VOLUME /tvh-data
EXPOSE 9981 9982

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["-u", "tvheadend", "-g", "tvheadend", "-c", "/config"]
