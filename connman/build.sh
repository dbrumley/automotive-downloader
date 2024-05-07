#!/bin/sh
wget -O -  https://git.kernel.org/pub/scm/network/connman/connman.git/snapshot/connman-1.37.tar.gz | tar zx
cp -R connman-1.37 b
cd connman-1.37
patch -p1 < ../harness.patch
autoreconf --install
CC=clang ./configure && CFLAGS="-fsanitize=address,fuzzer -DFUZZ=1 -g" make

