from conan import ConanFile


class ProtobufExampleConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    requires = (
        "protobuf/5.27.0",
    )
    tool_requires = (
        "protobuf/5.27.0",
    )
    generators = "CMakeDeps", "CMakeToolchain"
