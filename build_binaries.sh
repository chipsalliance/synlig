#!/bin/bash
set -ex

if [ -z "$INSTALL_PATH" ]; then
    INSTALL_PATH=$PWD/image
fi

SKIP_YOSYS=0
BUILD_SV2V=0

for arg in $@; do
  echo $arg
  case "$arg" in
    -y|--skip-yosys)
      SKIP_YOSYS=1
      ;;
    -s|--build-sv2v)
      BUILD_SV2V=1
      ;;
    *)
      if [ ${CASTOR} -eq 1 ]; then
        CASTOR_PATH=${arg}
      else
        echo "Usage: build_binaries [-y|--skip-yosys] [-s|--build-sv2v]"
        exit 1
      fi
      ;;
  esac
done

#Surelog
cd Surelog
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DCMAKE_POSITION_INDEPENDENT_CODE=ON -S . -B build
cmake --build build -j $(nproc)
cmake --install build
cd ..
#Yosys
if [ "$SKIP_YOSYS" -eq "0" ]; then
cd yosys
make CONFIG=gcc PREFIX=$INSTALL_PATH install -j $(nproc)
cd ..
fi
#UHDM plugin
if [ "$PLUGIN_ASAN" -eq "1" ]; then
  PLUGIN_LDFLAGS="-fsanitize=address -fcheck-new -fno-omit-frame-pointer -static-libasan"
fi
export PATH=$INSTALL_PATH/bin:${PATH}
UHDM_INSTALL_DIR=$INSTALL_PATH LDFLAGS=$PLUGIN_LDFLAGS make -C $PWD/yosys-symbiflow-plugins/ install -j$(nproc)
#sv2v
if [ "$BUILD_SV2V" -eq "1" ]; then
wget -qO- https://get.haskellstack.org/ | sh -s - -f -d $INSTALL_PATH/bin
make -C $PWD/sv2v && cp $PWD/sv2v/bin/sv2v $INSTALL_PATH/bin
fi
