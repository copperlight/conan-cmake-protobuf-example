#!/usr/bin/env bash

# usage: ./build.sh [clean|clean --confirm|skiptest]

set -e

BUILD_DIR=cmake-build
# Choose: Debug, Release, RelWithDebInfo, MinSizeRel. Use Debug for asan checking locally.
BUILD_TYPE=Debug

BLUE="\033[0;34m"
NC="\033[0m"

if [[ -f /etc/lsb-release ]]; then
  . /etc/lsb-release
  if [ "$DISTRIB_CODENAME" = "jammy" ]; then
    echo "==== fix kernel mmap rnd bits on ubuntu 22.04 to allow asan ===="
    sudo sysctl vm.mmap_rnd_bits=28
  fi
fi

if [[ "$1" == "clean" ]]; then
  echo -e "${BLUE}==== clean ====${NC}"
  rm -rf $BUILD_DIR
  rm animal.pb.cc
  rm animal.pb.h
  if [[ "$2" == "--confirm" ]]; then
    # remove all packages from the conan cache, to allow swapping between Release/Debug builds
    conan remove "*" --confirm
  fi
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export CC=gcc-13
  export CXX=g++-13
fi

if [[ ! -f "$HOME/.conan2/profiles/default" ]]; then
  echo -e "${BLUE}==== create default profile ====${NC}"
  conan profile detect
fi

if [[ ! -d $BUILD_DIR ]]; then
  echo -e "${BLUE}==== install required dependencies ====${NC}"
  if [[ "$BUILD_TYPE" == "Debug" ]]; then
    conan install . --output-folder=$BUILD_DIR --build="*" --settings=build_type=$BUILD_TYPE --profile=./sanitized
  else
    conan install . --output-folder=$BUILD_DIR --build=missing
  fi
fi

pushd $BUILD_DIR

echo -e "${BLUE}==== configure conan environment to access tools ====${NC}"
source conanbuild.sh

if [[ $OSTYPE == "darwin"* ]]; then
  export MallocNanoZone=0
fi

echo -e "${BLUE}==== generate build files ====${NC}"
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE

echo -e "${BLUE}==== build ====${NC}"
cmake --build .

echo -e "${BLUE}==== test ====${NC}"
BINARY="bin/pb-example"

if [[ "$1" != "skiptest" ]]; then
  if [[ -f $BINARY ]] && [[ -x $BINARY ]]; then
    ./$BINARY
  else
    echo "binary $BINARY does not exist"
  fi
fi

popd
