#!/usr/bin/env bash
set -ex

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

# Surelog & SV plugin
make install@surelog
make install@systemverilog-plugin

# Yosys
if [ "$SKIP_YOSYS" -eq "0" ]; then
make install@yosys
fi

#sv2v
if [ $BUILD_SV2V -eq 1 ]; then
cd third_party
wget -qO- https://get.haskellstack.org/ | sh -s - -f -d $INSTALL_PATH/bin
make -j$(nproc) -C $PWD/sv2v && cp $PWD/sv2v/bin/sv2v $INSTALL_PATH/bin
cd ..
fi
