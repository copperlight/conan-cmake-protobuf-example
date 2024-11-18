[![Build](https://github.com/copperlight/conan-cmake-protobuf-example/actions/workflows/build.yml/badge.svg)](https://github.com/copperlight/conan-cmake-protobuf-example/actions/workflows/build.yml)

# Conan 2.X + CMake + Protobuf Build Example

I was trying to figure out how to use [protobuf] with a [Conan] 2.X + [CMake] project, and I found the following blog
post.

* [C++ Protobuf: Project Setup With Conan and CMake]

The initial advice to use the [`bincrafters`] distribution is no longer viable, so I had to find another way. The
2022 edit gets closer to my final solution, but I think my variation here of using [`add_custom_command`] is a bit
more clear, because it establishes a direct dependency on the named generated files.

The `conan install` step builds `protobuf` from source (or uses a pre-built binary fetched from Artifactory), and as
a part of this work, we get a copy of `protoc` built for the current platform and matching the library version.
All we need to do is call this binary during the `cmake` build, to generate the files we need.

With the 2.X version, Conan provides a `tool_requires` configuration and a `conanbuild.sh` file in the build output
directory. The combination of these two things results in modifying the `PATH` to include the binary specified in the
`tool_requires` configuration. If you need to revert to your previous environment, there is a `deactivate_conanbuild.sh`
script.

With the locally compiled `protoc` binary available on the `PATH`, all we have to do is specify the output locations.
We need copies of the generated files in both the source directory and the binary directory.

[CMakeLists.txt#L19-L23](https://github.com/copperlight/conan-cmake-protobuf-example/blob/main/CMakeLists.txt#L21-L25)

After building the project, you can test the resulting executable as follows:

```
./cmake-build/pb-example

created proto message with animal:
species: Cat
name: Tiffany
age: 12
```

You can see this output in the GitHub Actions `build` job under the `Test` step.

The main caveat here is that this is written for Conan 1.X. At some point, I will need to update this approach for
Conan 2.X. No fancy source directory structure was created here, because there are only two source files, plus the
generated files. This technique can be applied to more complex directory structures, as needed.

[protobuf]: https://conan.io/center/recipes/protobuf?version=5.27.0
[Conan]: https://conan.io/
[CMake]: https://cmake.org/
[C++ Protobuf: Project Setup With Conan and CMake]: https://www.codingwiththomas.com/blog/protobuf-project-setup-with-conan-and-cmake
[`bincrafters`]: https://bincrafters.github.io/
[`add_custom_command`]: https://cmake.org/cmake/help/latest/command/add_custom_command.html

## Local & IDE Configuration

```shell
# setup python venv and activate, to gain access to conan cli
./setup-venv.sh
source venv/bin/activate

./build.sh  # [clean|clean --confirm|skiptest]
```

* Install the Conan plugin for CLion.
    * CLion > Settings > Plugins > Marketplace > Conan > Install
* Configure the Conan plugin.
    * The easiest way to configure CLion to work with Conan is to build the project first from the command line.
        * This will establish the `$PROJECT_HOME/CMakeUserPresets.json` file, which will allow you to choose the custom
          CMake configuration created by Conan when creating a new CMake project. Using this custom profile will ensure
          that sources are properly indexed and explorable.
    * Open the project. The wizard will show three CMake profiles.
        * Disable the default Cmake `Debug` profile.
        * Enable the CMake `conan-debug` profile.
    * CLion > View > Tool Windows > Conan > (gear) > Conan Executable: `$PROJECT_HOME/venv/bin/conan`
