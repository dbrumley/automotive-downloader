FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y \
  autoconf \ 
  automake \
  build-essential \
  ca-certificates \ 
  clang \
  libdbus-1-dev \
  libglib2.0-dev \
  libgnutls28-dev \
  libreadline-dev \
  libxtables-dev \
  libtool \
  vim \
  wget
WORKDIR /build
COPY . .
RUN ./build.sh
CMD {}
