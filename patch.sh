#!/bin/sh
cd Surelog
for i in ../patches/surelog-*.patch; do
  patch -p1 -i $i
done
