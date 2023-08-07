cmake_minimum_required(VERSION 3.13)

project(conan-cmake-protobuf-example)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

add_executable(pb-example
    "animal.pb.cc"
    "animal.pb.h"
    "main.cc"
)
target_link_libraries(pb-example ${CONAN_LIBS})

#-- protobuf generated files must exist in both the SOURCE_DIR and the BINARY_DIR
add_custom_command(
    OUTPUT animal.pb.cc animal.pb.h
    COMMAND ${CONAN_PROTOBUF_ROOT}/bin/protoc --proto_path=${CMAKE_CURRENT_SOURCE_DIR} --cpp_out=${CMAKE_CURRENT_SOURCE_DIR} animal.proto
    COMMAND ${CONAN_PROTOBUF_ROOT}/bin/protoc --proto_path=${CMAKE_CURRENT_SOURCE_DIR} --cpp_out=${CMAKE_CURRENT_BINARY_DIR} animal.proto
)
