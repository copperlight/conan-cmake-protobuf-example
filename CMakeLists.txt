cmake_minimum_required(VERSION 3.23)

project(conan-cmake-protobuf-example)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS OFF)

add_compile_options(-fno-rtti -pedantic -Werror -Wall -Wno-missing-braces -fno-omit-frame-pointer "$<$<CONFIG:Debug>:-fsanitize=address>")

find_package(Protobuf REQUIRED)

add_executable(pb-example
    "animal.pb.cc"
    "animal.pb.h"
    "main.cc"
)
target_link_libraries(pb-example PRIVATE protobuf::protobuf)

#-- protobuf generated files must exist in both the SOURCE_DIR and the BINARY_DIR
add_custom_command(
    OUTPUT animal.pb.cc animal.pb.h
    COMMAND protoc --proto_path=${CMAKE_CURRENT_SOURCE_DIR} --cpp_out=${CMAKE_CURRENT_SOURCE_DIR} animal.proto
    COMMAND protoc --proto_path=${CMAKE_CURRENT_SOURCE_DIR} --cpp_out=${CMAKE_CURRENT_BINARY_DIR} animal.proto
)
