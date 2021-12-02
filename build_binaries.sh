#!/bin/bash
set -ex

if [ -z "$INSTALL_PATH" ]; then
    INSTALL_PATH=$PWD/image
fi

#Surelog
cd Surelog
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_POSITION_INDEPENDENT_CODE=ON -S . -B build
cmake --build build -j $(nproc)
cmake --install build
cd ..
#Yosys
if [ "$1" != "--skip-yosys" ]; then
cd yosys
make CONFIG=gcc PREFIX=$INSTALL_PATH install -j $(nproc)
cd ..
fi
#UHDM plugin
export PATH=$INSTALL_PATH/bin:${PATH}
UHDM_INSTALL_DIR=$INSTALL_PATH make -C $PWD/yosys-symbiflow-plugins/ install -j$(nproc)
#sv2v
wget -qO- https://get.haskellstack.org/ | sh -s - -f -d $INSTALL_PATH/bin
make -C $PWD/sv2v && cp $PWD/sv2v/bin/sv2v $INSTALL_PATH/bin
