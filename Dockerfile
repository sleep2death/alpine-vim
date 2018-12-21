# by aspirin2d
FROM alpine:latest as builder

MAINTAINER aspirin2d <sleep2death@gmail.com>

# Thanks for MaYun Baba
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

WORKDIR /tmp

# Install dependencies
RUN apk add --no-cache \
    build-base \
    ctags \
    git \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    make \
    ncurses-dev \
    python \
    python-dev

# Build vim from git source
RUN git clone --depth 1 https://github.com/vim/vim \
 && cd vim \
 && ./configure \
    --disable-gui \
    --disable-netbeans \
    --enable-multibyte \
    --enable-pythoninterp \
    --with-features=big \
    --with-python-config-dir=/usr/lib/python2.7/config \
 && make install

FROM alpine:latest

# Thanks for MaYun Baba
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

ENV YcmPATH="/usr/local/share/vim/vimfiles/pack/plugins/start/YouCompleteMe"

COPY --from=builder /usr/local/bin/ /usr/local/bin
COPY --from=builder /usr/local/share/vim/ /usr/local/share/vim/
# NOTE: man page is ignored

RUN apk add --no-cache \
    diffutils \
    libice \
    libsm \
    libx11 \
    libxt \
    libstdc++ \
    ncurses \
    python \
    git \
    && apk add --virtual build-deps \
    build-base \
    cmake \
    llvm \
    perl \
    python-dev \
# Download Ycm
    && git clone --depth 1 https://github.com/Valloric/YouCompleteMe.git $YcmPATH \
    && cd $YcmPATH && git submodule update --init --recursive \
    && python install.py \
# Cleanup
    && apk del build-deps \
    && rm -rf \
    $YcmPATH/third_party/ycmd/clang_includes \
    $YcmPATH/third_party/ycmd/cpp \
    /var/cache/* \
    /var/log/* \
    /var/tmp/* \
    && find . | grep "\.git/" | xargs rm -rf \

