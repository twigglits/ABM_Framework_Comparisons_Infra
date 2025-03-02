# FLAME GPU 2 ABM Comparison Benchmarks

This directory contains the implementation of several ABMs used to compare agent based models, including:

+ `boids2D` - a 2D spatial implementation of boids flocking model
+ `schelling` - an implementation of Schelling's Model of Segregation

[FLAMEGPU/FLAMEGPU2](https://github.com/FLAMEGPU/FLAMEGPU2) is downloaded via CMake and configured as a dependency of the project.

The version of FLAME GPU fetched is pinned to a specific release of FLAME GPU, in case of API breaking changes.
This is controlled using the `FLAMEGPU_VERSION` CMake variable, which can be modified in `CMakeLists.txt`, or as a configuration argument.

For details on how to develop a model using FLAME GPU 2, refer to the [userguide & API documentation](https://docs.flamegpu.com/).

## Requirements

Building FLAME GPU has the following requirements. There are also optional dependencies which are required for some components, such as Documentation or Python bindings.

+ [CMake](https://cmake.org/download/) `>= 3.18`
  + `>= 3.20` if building python bindings using a multi-config generator (Visual Studio, Eclipse or Ninja Multi-Config)
+ [CUDA](https://developer.nvidia.com/cuda-downloads) `>= 11.0` and a [Compute Capability](https://developer.nvidia.com/cuda-gpus) `>= 3.5` NVIDIA GPU.
+ C++17 capable C++ compiler (host), compatible with the installed CUDA version
  + [Microsoft Visual Studio 2019 or 2022](https://visualstudio.microsoft.com/) (Windows)
    + *Note:* Visual Studio must be installed before the CUDA toolkit is installed. See the [CUDA installation guide for Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html) for more information.
  + [make](https://www.gnu.org/software/make/) and [GCC](https://gcc.gnu.org/) `>= 8.1` (Linux)
+ [git](https://git-scm.com/)

Optionally:

+ [cpplint](https://github.com/cpplint/cpplint) for linting code
+ [Doxygen](http://www.doxygen.nl/) to build the documentation
+ [Python](https://www.python.org/) `>= 3.7` for python integration
  + With `setuptools`, `wheel`, `build` and optionally `venv` python packages installed
+ [swig](http://www.swig.org/) `>= 4.0.2` for python integration
  + Swig `4.x` will be automatically downloaded by CMake if not provided (if possible).
+ [FLAMEGPU2-visualiser](https://github.com/FLAMEGPU/FLAMEGPU2-visualiser) dependencies
  + [SDL](https://www.libsdl.org/)
  + [GLM](http://glm.g-truc.net/) *(consistent C++/GLSL vector maths functionality)*
  + [GLEW](http://glew.sourceforge.net/) *(GL extension loader)*
  + [FreeType](http://www.freetype.org/)  *(font loading)*
  + [DevIL](http://openil.sourceforge.net/)  *(image loading)*
  + [Fontconfig](https://www.fontconfig.org/)  *(Linux only, font detection)*

## Building with CMake

Building via CMake is a three step process, with slight differences depending on your platform.

1. Create a build directory for an out-of tree build
2. Configure CMake into the build directory
    + Using the CMake GUI or CLI tools
    + Specifying build options such as the CUDA Compute Capabilities to target, the inclusion of Visualisation or Python components, or performance impacting features such as `SEATBELTS`. See [CMake Configuration Options](#CMake-Configuration-Options) for details of the available configuration options
      + For benchmarking, please use a `Release` configuration, and set `SEATBELTS=OFF`. `USE_NVTX=ON` can be useful for profiling purposes.
3. Build compilation targets using the configured build system
    + See [Available Targets](#Available-targets) for a list of available targets.

### Linux

To build under Linux using the command line, you can perform the following steps.

For example, to configure CMake for `Release` builds, for Volta GPUs (Compute Capability `70`) with `SEATBELTS` disabled

```bash
# Create the build directory and change into it
mkdir -p build && cd build

# Configure CMake from the command line passing configure-time options. 
cmake .. -DCMAKE_BUILD_TYPE=Release -DCUDA_ARCH=70 -DSEATBELTS=OFF

# Build the target(s)
cmake --build . --target all -j `nproc`
```

### Windows

Under Windows, you must instruct CMake on which Visual Studio and architecture to build for, using the CMake `-A` and `-G` options.
This can be done through the GUI or the CLI.

For Example, to configure CMake for `Release` builds, for Volta GPUs (Compute Capability `70`) with `SEATBELTS` disabled

```cmd
REM Create the build directory 
mkdir build
cd build

REM Configure CMake from the command line, specifying the -A and -G options. Alternatively use the GUI
cmake .. -A x64 -G "Visual Studio 16 2019" DCUDA_ARCH=70 -DSEATBELTS=OFF

REM You can then open Visual Studio manually from the .sln file, or via:
cmake --open . 
REM Alternatively, build from the command line specifying the build configuration
cmake --build . --config Release --target ALL_BUILD --verbose
```

#### CMake Configuration Options

| Option                   | Value             | Description                                                                                                |
| ------------------------ | ----------------- | ---------------------------------------------------------------------------------------------------------- |
| `CMAKE_BUILD_TYPE`       | `Release`/`Debug` | Select the build configuration for single-target generators such as `make`                                 |
| `SEATBELTS`              | `ON`/`OFF`        | Enable / Disable additional runtime checks which harm performance but increase usability. Default `ON`     |
| `CUDA_ARCH`              | `"52 60 70 80"`   | Select [CUDA Compute Capabilities](https://developer.nvidia.com/cuda-gpus) to build/optimise for, as a space or `;` separated list. Defaults to `""` |
| `VISUALISATION`          | `ON`/`OFF`        | Enable Visualisation. Default `OFF`.                                                                       |
| `VISUALISATION_ROOT`     | `path/to/vis`     | Provide a path to a local copy of the [FLAMEGPU/FLAMEGPU2-visualiser](https://github.com/FLAMEGPU/FLAMEGPU2-visualiser) repository |
| `USE_NVTX`               | `ON`/`OFF`        | Enable NVTX markers for improved profiling. Default `OFF`                                                  |
| `WARNINGS_AS_ERRORS`     | `ON`/`OFF`        | Promote compiler/tool warnings to errors are build time. Default `OFF`                                     |
| `FLAMEGPU_VERSION`       | `v2.0.0-alpha.2`  | Git tag or commit hash of the [FLAMEGPU/FLAMEGPU2](https://github.com/FLAMEGPU/FLAMEGPU2) repository to be fetched |
| `FLAMEGPU_ROOT`          | `path/to/FLAMEGPU2` | Path to local copy of [FLAMEGPU/FLAMEGPU2](https://github.com/FLAMEGPU/FLAMEGPU2), to be used rather than fetching from github during CMake configuration. Use `-DFLAMEGPU_ROOT=` to revert to fetching from GitHub.

See the [FLAMEGPU/FLAMEGPU2 Readme](https://github.com/FLAMEGPU/FLAMEGPU2#cmake-configuration-options) for a full list of CMake options for the main repository.

For a list of available CMake configuration options, run the following from the `build` directory:

```bash
cmake -LH ..
```

### Available Targets

| Target         | Description                                                                                                   |
| -------------- | ------------------------------------------------------------------------------------------------------------- |
| `all`          | Linux target containing default set of targets, including everything but the documentation and lint targets   |
| `ALL_BUILD`    | The windows equivalent of `all`                                                                               |
| `all_lint`     | Run all available Linter targets                                                                              |
| `example`      | The `example` target created by the `CMakeLists.txt` in the root of this repository                           |
| `lint_example` | Lint the `example` target.                                                                                    |
| `flamegpu`     | Build the FLAME GPU static library                                                                                |
| `docs`         | The FLAME GPU API documentation (if available)                                                                |

For a full list of available targets, run the following after configuring CMake:

```bash
cmake --build . --target help
```
