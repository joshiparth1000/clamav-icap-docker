FROM mk0x/docker-clamav:alpine

ARG VERSION=0.5.5
ARG PLUGINS_VERSION=0.5.3

RUN apk update && \
    apk add --no-cache gcc musl-dev zlib-dev file bzip2-dev git bc sed autoconf automake libtool tree make

RUN git clone https://github.com/google/brotli.git && \
    cd brotli && ./bootstrap && ./configure && make && make install && cd $HOME && rm -r /brotli

RUN wget -O c-icap.tar.gz https://sourceforge.net/projects/c-icap/files/c-icap/0.5.x/c_icap-$VERSION.tar.gz/download && \
    tar zxfv c-icap.tar.gz && \
    cd c_icap-$VERSION && ./configure --prefix=/usr/local/c-icap && make && make install && cd $HOME && rm -r /c_icap-$VERSION /c-icap.tar.gz

RUN wget -O c-icap-plugins.tar.gz https://sourceforge.net/projects/c-icap/files/c-icap-modules/0.5.x/c_icap_modules-$PLUGINS_VERSION.tar.gz/download && \
    tar zxfv c-icap-plugins.tar.gz && \
    cd c_icap_modules-$PLUGINS_VERSION && ./configure --with-c-icap=/usr/local/c-icap --prefix=/usr/local/c-icap && make && make install && \
    cd $HOME && rm -r /c_icap_modules-$PLUGINS_VERSION /c-icap-plugins.tar.gz && \
    libtool --finish /usr/local/c-icap/lib/c_icap/

RUN apk del gcc musl-dev git autoconf automake make tree sed bc

COPY c-icap.conf /usr/local/c-icap/etc/
COPY virus_scan.conf /usr/local/c-icap/etc/
COPY clamd_mod.conf /usr/local/c-icap/etc/
COPY bootstrap.py /

RUN chmod +x /bootstrap.py

EXPOSE 1344

CMD ["/bootstrap.py"]