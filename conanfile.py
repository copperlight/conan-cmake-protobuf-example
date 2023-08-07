from conans import ConanFile


class SpectatorDConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    requires = "protobuf/3.21.12"
    generators = "cmake"
    default_options = {}
