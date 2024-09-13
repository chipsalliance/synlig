# * * - mode : cmake - * -
cmake_minimum_required(VERSION 3.20 FATAL_ERROR)
# License : Apache - 2.0 This cmake enables this project to be built in a larger
# cmake based infrastructure. This is an alternative build system for Synlig
# when used in a cmake - based project. It also allows to use a different
# version of Yosys if provided by YOSYS_CONFIG variable. That alternate Yosys
# can either be installed on the system or simply part of the larger cmake
# project. In that case it won't compile the Yosys present in this repo. Surelog
# can also be installed on the system. This cmake is largely copied from the
# Surelog cmake

project(SYNLIG VERSION 1.82)

# Detect build type, fallback to release and throw a warning if use didn't
# specify any
if(NOT CMAKE_BUILD_TYPE)
  message(WARNING "Build type not set, falling back to Release mode.
 To specify build type use:
 -DCMAKE_BUILD_TYPE=<mode> where <mode> is Debug or Release.")
  set(CMAKE_BUILD_TYPE
      "Release"
      CACHE STRING "Choose the type of build, options are: Debug Release."
            FORCE)
endif(NOT CMAKE_BUILD_TYPE)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules" ${CMAKE_MODULE_PATH})

set(INSTALL_DIR ${PROJECT_SOURCE_DIR}/out/current)

option(
  WITH_LIBCXX
  "If buildling with clang++ and libc++(in Linux). To enable with: -DWITH_LIBCXX=On"
  OFF)

option(SYNLIG_USE_HOST_ALL
       "Default to using libraries from host instead of third_party" OFF)
option(SYNLIG_USE_HOST_SURELOG
       "Use Surelog library from host instead of third_party"
       ${SYNLIG_USE_HOST_ALL})
option(SYNLIG_USE_HOST_YOSYS "Use yosys from host instead of third_party"
       ${SYNLIG_USE_HOST_ALL})
option(
  SYNLIG_USE_HOST_CAPNP
  "Use capnproto from host system, not Surelog (if OFF, requires SYNLIG_USE_HOST_SURELOG=OFF)"
  OFF)
option(SYNLIG_USE_HOST_GTEST
       "Use googletest library from host instead of third_party"
       ${SYNLIG_USE_HOST_ALL})
option(SYNLIG_WITH_TCMALLOC "Use tcmalloc if installed" ON)
option(SYNLIG_PATHID_DEBUG_ENABLED "Enable PathId debugging" OFF)
option(SYNLIG_WITH_ZLIB "Use zlib if installed" ON)

option(SYNLIG_BUILD_TESTS "Enable testing." ON)

if(SYNLIG_USE_HOST_YOSYS)
  message("Using HOST YOSYS")
  find_package(yosys)
  get_target_property(YOSYS_INCLUDE_DIR yosys::yosys
                      INTERFACE_INCLUDE_DIRECTORIES)
else()
  if(DEFINED YOSYS_CONFIG AND NOT YOSYS_CONFIG STREQUAL "")
    # Use the Yosys custom location given
    set(YOSYS_INCLUDE_DIR ${YOSYS_PATH})
    message("Using YOSYS from ${YOSYS_PATH}")
  else()
    message("Using Vendored YOSYS")
    set(VENDORED_YOSYS 1)
    set(Yosys_BuildTests
        OFF
        CACHE INTERNAL "")
    set(YOSYS_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/third_party/yosys)
    set(YOSYS_CONFIG ${PROJECT_SOURCE_DIR}/third_party/yosys/yosys-config)
    # Build Vendored Yosys if not provided by upper cmake
    add_custom_target(yosys DEPENDS ${INSTALL_DIR}/bin/yosys)
    add_custom_command(
      OUTPUT ${INSTALL_DIR}/bin/yosys
      COMMAND echo "       Compiling Yosys"
      COMMAND make CONFIG=gcc PREFIX=${INSTALL_DIR} install -j${CPU_CORES}
      WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/third_party/yosys"
      DEPENDS ${PROJECT_SOURCE_DIR}/third_party/yosys/kernel/yosys.cc)
  endif()
endif()

message("YOSYS_CONFIG: ${YOSYS_CONFIG}")
message("YOSYS_INCLUDE_DIR: ${YOSYS_INCLUDE_DIR}")

# NOTE : Policy changes has to happen before adding any subprojects
cmake_policy(SET CMP0091 NEW)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set version from cmake and extract latest hash if available
set(SYNLIG_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(SYNLIG_VERSION_MINOR ${PROJECT_VERSION_MINOR})
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.git")
  # Get latest commit
  execute_process(
    COMMAND git rev-parse HEAD
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE SURELOG_VERSION_COMMIT_SHA)
  # strip newline
  string(REGEX REPLACE "\n$" "" SYNLIG_VERSION_COMMIT_SHA
                       "${SYNLIG_VERSION_COMMIT_SHA}")
else()
  set(SYNLIG_VERSION_COMMIT_SHA "release")
endif()

set(SYNLIG_BUILD_TYPE ${CMAKE_BUILD_TYPE})
message(
  "Building Synlig version v${SYNLIG_VERSION_MAJOR}.${SYNLIG_VERSION_MINOR} [${SYNLIG_VERSION_COMMIT_SHA}]"
)

if(WITH_LIBCXX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
endif()

set(YOSYS_CONFIG_FLAGS "-D_YOSYS_")

set(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${YOSYS_CONFIG_FLAGS} -Wno-unused-parameter -std=c++17")

set(WITH_STATIC_CRT
    OFF
    CACHE BOOL "Use Static CRT")

if(SYNLIG_USE_HOST_SURELOG)
  find_package(Surelog REQUIRED)
  find_package(UHDM REQUIRED)
  find_package(CapnProto)
  set(UHDM_LIBRARY uhdm::uhdm)
  set(SURELOG_LIBRARY surelog::surelog)
else()
  set(UHDM_USE_HOST_CAPNP ${SYNLIG_USE_HOST_CAPNP})
  set(SURELOG_BUILD_TESTS
      OFF
      CACHE BOOL "Skip Surelog tests")
  add_subdirectory(third_party/surelog)
  set(SURELOG_LIBRARY surelog)
  set(UHDM_LIBRARY uhdm)
  get_target_property(SURELOG_INCLUDE_DIRS surelog INCLUDE_DIRECTORIES)
  get_target_property(UHDM_INCLUDE_DIRS uhdm INCLUDE_DIRECTORIES)
endif()

if(SYNLIG_BUILD_TESTS)
  if(SYNLIG_USE_HOST_GTEST)
    find_package(GTest REQUIRED)
  else()
    add_subdirectory(third_party/surelog/third_party/googletest/
                     EXCLUDE_FROM_ALL)
    set(GTEST_INCLUDE_DIRS
        third_party/surelog/third_party/googletest/googletest/include
        third_party/surelog/third_party/googletest/googlemock/include)
  endif()
endif()

# Important Note Do not expliclty rely on a third party module,
# e.g.add_subdirectory(third_party / ...) as this is not acceptable for several
# registries and distribution systems.Instead, follow the pattern above to have
# optionality, which can be tested in.github / workflows /
# non_vendored.yml(Example in Surelog)

# NOTE : Set the global output directories after the subprojects have had their
# go at it
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  # Force all.lib and.dll into bin for windows
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
else()
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${INSTALL_DIR}/share/yosys/plugins)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${INSTALL_DIR}/share/yosys/plugins)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${INSTALL_DIR}/bin)
endif()

if(NO_TCMALLOC) # Leave this message in for a while, then remove.
  message(
    WARNING
      "-DNO_TCMALLOC has no effect, this option is now called -DSYNLIG_WITH_TCMALLOC=Off"
  )
endif()

# Use tcmalloc if requested and found on system.
if(SYNLIG_WITH_TCMALLOC)
  find_library(TCMALLOC_LIBRARY NAMES tcmalloc)
  if(TCMALLOC_LIBRARY)
    message(
      WARNING
        "Using tcmalloc; if this creates runtime issues, configure with -DSYNLIG_WITH_TCMALLOC=Off"
    )
    message("-- Found tcmalloc: ${TCMALLOC_LIBRARY}")
    set(TCMALLOC_COMPILE_OPTIONS
        "-fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free"
    )
  endif()
endif()

set(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${TCMALLOC_COMPILE_OPTIONS} ${MY_CXX_WARNING_FLAGS}")

if(MSVC)
  add_compile_definitions(_CRT_NONSTDC_NO_WARNINGS)

  set(CMAKE_CXX_FLAGS_DEBUG
      "${CMAKE_CXX_FLAGS_DEBUG} ${TCMALLOC_COMPILE_OPTIONS} /Zc:__cplusplus /W4 /bigobj ${MY_CXX_WARNING_FLAGS}"
  )
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO
      "${CMAKE_CXX_FLAGS_RELEASE} ${TCMALLOC_COMPILE_OPTIONS} /Zc:__cplusplus /W4 /bigobj ${MY_CXX_WARNING_FLAGS}"
  )
  set(CMAKE_CXX_FLAGS_RELEASE
      "${CMAKE_CXX_FLAGS_RELEASE} ${TCMALLOC_COMPILE_OPTIONS} /Zc:__cplusplus /W4 /bigobj ${MY_CXX_WARNING_FLAGS}"
  )
  set(CMAKE_EXE_LINKER_FLAGS /STACK:8388608) # 8MB stack size
elseif(WIN32 AND (CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
  # The stack size unnecessarily high here.Investigate and bring it back to
  # something more reasonable.
  set(CMAKE_EXE_LINKER_FLAGS
      "${CMAKE_EXE_LINKER_FLAGS} -Xclang --stack-size=33554432") # 32MB stack
                                                                 # size
else()
  if(DEFINED ENV{MSYSTEM})
    # Under MSYS some files are too large to build without additional flags
    set(MSYS_COMPILE_OPTIONS "-m64 -Wa,-mbig-obj")
  endif()
  set(CMAKE_CXX_FLAGS_DEBUG
      "${CMAKE_CXX_FLAGS_DEBUG} ${TCMALLOC_COMPILE_OPTIONS} -Wall -Wno-unused-parameter -O0 -g ${MSYS_COMPILE_OPTIONS} ${MY_CXX_WARNING_FLAGS} ${MEM_SANITIZER_FLAGS}"
  )
  set(CMAKE_CXX_FLAGS_RELEASE
      "${CMAKE_CXX_FLAGS_RELEASE} ${TCMALLOC_COMPILE_OPTIONS} -Wall -Wno-unused-parameter -O3 ${MSYS_COMPILE_OPTIONS} -DNDEBUG ${MY_CXX_WARNING_FLAGS} ${MEM_SANITIZER_FLAGS}"
  )
endif()

# This code contains warnings
string(REGEX REPLACE "\\-Werror" "" CMAKE_CXX_FLAGS_RELEASE
                     "${CMAKE_CXX_FLAGS_RELEASE}")
string(REGEX REPLACE "\\-Wfatal\\-errors" "" CMAKE_CXX_FLAGS_RELEASE
                     "${CMAKE_CXX_FLAGS_RELEASE}")
string(REGEX REPLACE "\\-Werror" "" CMAKE_CXX_FLAGS_DEBUG
                     "${CMAKE_CXX_FLAGS_DEBUG}")
string(REGEX REPLACE "\\-Wfatal\\-errors" "" CMAKE_CXX_FLAGS_DEBUG
                     "${CMAKE_CXX_FLAGS_DEBUG}")
string(REGEX REPLACE "\\-Werror" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REGEX REPLACE "\\-Wfatal\\-errors" "" CMAKE_CXX_FLAGS
                     "${CMAKE_CXX_FLAGS}")
message("SYNLIG CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message("SYNLIG CMAKE_CXX_FLAGS_RELEASE: ${CMAKE_CXX_FLAGS_RELEASE}")
message("SYNLIG CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")

if(WIN32)
  add_compile_definitions(WIN32_LEAN_AND_MEAN)
endif()

# Put source code here, files that are generated at build time in
# surelog_generated_SRC
set(synlig_SRC
    ${PROJECT_SOURCE_DIR}/src/frontends/systemverilog/compat_symbols.cc
    ${PROJECT_SOURCE_DIR}/src/frontends/systemverilog/uhdm_ast_frontend.cc
    ${PROJECT_SOURCE_DIR}/src/frontends/systemverilog/uhdm_surelog_ast_frontend.cc
    ${PROJECT_SOURCE_DIR}/src/frontends/systemverilog/uhdm_ast.cc
    ${PROJECT_SOURCE_DIR}/src/frontends/systemverilog/uhdm_common_frontend.cc
    ${PROJECT_SOURCE_DIR}/src/mods/yosys_ast/synlig_const2ast.cc
    ${PROJECT_SOURCE_DIR}/src/mods/yosys_ast/synlig_edif.cc
    ${PROJECT_SOURCE_DIR}/src/mods/yosys_ast/synlig_simplify.cc)

add_library(synlig SHARED ${synlig_SRC})

if(VENDORED_YOSYS)
  if(NOT EXISTS "${PROJECT_SOURCE_DIR}/third_party/surelog/.git"
     OR NOT EXISTS "${PROJECT_SOURCE_DIR}/third_party/yosys/.git")
    message(SEND_ERROR "The git submodules are not available. Please run
      git submodule sync
      git submodule update --init --recursive third_party/{surelog,yosys}")
  endif()
  add_dependencies(synlig yosys)
  add_dependencies(surelog yosys)
  add_dependencies(surelog-bin yosys)
  add_dependencies(antlr4_static yosys)
  add_dependencies(capnp yosys)
endif()

if(NOT SYNLIG_USE_HOST_SURELOG)
  add_dependencies(synlig surelog)
  add_dependencies(synlig uhdm)
endif()
target_link_libraries(synlig PUBLIC ${UHDM_LIBRARY})
target_link_libraries(synlig PUBLIC ${SURELOG_LIBRARY})

set_target_properties(
  synlig PROPERTIES SOVERSION "${SYNLIG_VERSION_MAJOR}.${SYNLIG_VERSION_MINOR}")
set_target_properties(synlig PROPERTIES OUTPUT_NAME "systemverilog")
set_target_properties(synlig PROPERTIES PREFIX "")
set_target_properties(synlig PROPERTIES SUFFIX ".so")

# Allow undefined symbols at link time on macOS. These symbols should already be
# present within yosys when the plugin is loaded.
if(APPLE)
  set_target_properties(synlig PROPERTIES LINK_FLAGS
                                          "-undefined dynamic_lookup")
endif()

target_include_directories(
  synlig
  PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/frontends/systemverilog/>
         $<INSTALL_INTERFACE:include>)
target_include_directories(
  synlig PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/mods/yosys_ast/>
                $<INSTALL_INTERFACE:include>)
target_include_directories(
  synlig PUBLIC $<BUILD_INTERFACE:${SURELOG_INCLUDE_DIRS}>
                $<INSTALL_INTERFACE:include>)
target_include_directories(synlig PUBLIC $<BUILD_INTERFACE:${UHDM_INCLUDE_DIRS}>
                                         $<INSTALL_INTERFACE:include>)
target_include_directories(synlig PUBLIC $<BUILD_INTERFACE:${JSON_INCLUDE_DIR}>
                                         $<INSTALL_INTERFACE:include>)
target_include_directories(synlig PUBLIC $<BUILD_INTERFACE:${YOSYS_INCLUDE_DIR}>
                                         $<INSTALL_INTERFACE:include>)

# Install library using normal shell script
install(CODE "execute_process(COMMAND ${CMAKE_SOURCE_DIR}/install_plugin.sh)")
