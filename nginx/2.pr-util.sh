#!/bin/sh


cd apr-util-1.3.12
./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr/bin/apr-1-config --with-lib=/usr/local/apr/lib

