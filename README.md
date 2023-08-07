[![Build](https://github.com/copperlight/conan-cmake-protobuf-example/actions/workflows/build.yml/badge.svg)](https://github.com/copperlight/conan-cmake-protobuf-example/actions/workflows/build.yml)

# Conan 1.X + CMake + Protobuf Build Example

I was trying to figure out how to use [protobuf] with a [Conan] 1.X + [CMake] project, and I found the following blog
post:

* [C++ Protobuf: Project Setup With Conan and CMake]

The initial advice to use the [`bincrafters`] distribution is no longer viable, so I had to find another way. The
2022 edit gets closer to my final solution, but I think my variation here of using [`add_custom_command`] is a bit
more clear, because it establishes a direct dependency on the named generated files.

The Conan `install` step builds protobuf from source (or uses a pre-built binary fetched from Artifactory), and as
a part of this work, we get a copy of [`protoc`] built for the current platform and matching the library version.
All we need to do is call this binary to generate the files we need. Conan provides a [CMake variable],
`CONAN_PROTOBUF_ROOT`, which makes it easy to locate the binary, and then all we have to do is specify the output
locations. We need copies of the generated files in both the source directory and the binary directory.

[CMakeLists.txt#L19-L23](https://github.com/copperlight/conan-cmake-protobuf-example/blob/main/CMakeLists.txt#L19-L23)

After building the project, you can test the resulting executable as follows:

```
./cmake-build/bin/pb-example
created proto message with animal:
species: Cat
name: Tiffany
age: 12
```

You can see this output in the GitHub Actions `build` job under the `Test` step.

The main caveat here is that this is written for Conan 1.X. At some point, I will need to update this approach for
Conan 2.X. No fancy source directory structure was created here, because there are only two source files, plus the
generated files. This technique can be applied to more complex directory structures, as needed.

[protobuf]: https://conan.io/center/recipes/protobuf?version=3.21.12
[Conan]: https://conan.io/
[CMake]: https://cmake.org/
[C++ Protobuf: Project Setup With Conan and CMake]: https://www.codingwiththomas.com/blog/protobuf-project-setup-with-conan-and-cmake
[`bincrafters`]: https://bincrafters.github.io/
[`add_custom_command`]: https://cmake.org/cmake/help/latest/command/add_custom_command.html
[`protoc`]: https://github.com/conan-io/conan-center-index/blob/master/recipes/protobuf/all/conanfile.py#L97
[CMake variable]: https://docs.conan.io/1/reference/generators/cmake.html

## Local Development

```shell
./setup-venv.sh
source venv/bin/activate
./build.sh  # [clean]
```

* CLion version 2022.1.3 required until the Conan plugin is updated
* CLion > Preferences > Plugins > Marketplace > Conan > Install
* CLion > Preferences > Build, Execution, Deploy > Conan > Conan Executable: $PROJECT_HOME/venv/bin/conan
* CLion > Bottom Bar: Conan > Left Button: Match Profile > CMake Profile: Debug, Conan Profile: default
