cmake_minimum_required(VERSION 3.8)

# Name of the project
project(MultipleCells)

# Verilog files to be verilated
set(VTOP ${CMAKE_BINARY_DIR}/top.uhdm)
list(APPEND VERILATOR_ARGS --uhdm-ast)

# C/C++ source files to be compiled
set(CSOURCES main.cpp)

include(${CMAKE_BINARY_DIR}/../../verilator-config.cmake.in)
set(USER_VERILATOR_DIR ${CMAKE_BINARY_DIR}/../../)

set(COMP_LIB_ARGS -fPIC)

if(POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif()

# Hide not so usable variables from basic views of ccmake and cmake-gui
mark_as_advanced(CMAKE_INSTALL_PREFIX verilator_DIR VERILATOR_ROOT VERILATOR_BIN PERL)

if(IS_DIRECTORY "${USER_VERILATOR_DIR}" AND DEFINED ENV{VERILATOR_ROOT})
  # Verilator CMake logic prioritizes VERILATOR_ROOT environment variable
  message(STATUS "Using USER_VERILATOR_DIR over VERILATOR_ROOT env. var.")
  set(ENV{VERILATOR_ROOT} ${USER_VERILATOR_DIR})
endif()
find_package(verilator HINTS ${USER_VERILATOR_DIR} $ENV{VERILATOR_ROOT})
if(NOT verilator_FOUND)
  set(USER_VERILATOR_DIR CACHE PATH "Path to the Verilator's root directory.")
  message(FATAL_ERROR "There's no Verilator installed or its version is older than 4.022 (which introduced CMake support).\nEither install it or set the CMake's USER_VERILATOR_DIR variable to the Verilator's root directory.")
endif()

# Default arguments for compilation and linking
list(APPEND PROJECT_COMP_ARGS -Wall)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  set(LIBOPENLIBM CACHE PATH "Absolute (!) path to the OpenLibm library (<RENODE_VERILATOR_INTEGRATION_PATH>/lib/libopenlibm-Linux-<TARGET_ARCH>.a). Use it for enhanced portability.")
  # Link OpenLibm if LIBOPENLIBM is correctly set
  if(LIBOPENLIBM)
    if(EXISTS ${LIBOPENLIBM} AND IS_ABSOLUTE ${LIBOPENLIBM})
      # `-Wl,--as-needed` in case it isn't passed to the linker by default
      #   (e.g. Debian's g++ v8.3.0-6)
      list(APPEND PROJECT_LINK_ARGS ${LIBOPENLIBM} -Wl,--as-needed)
    else()
      message(FATAL_ERROR "LIBOPENLIBM ('${LIBOPENLIBM}') has to be an absolute path!")
    endif()
  else()
    message(WARNING "It is highly advised to use OpenLibm for portability reasons. To do so, run CMake with '-DLIBOPENLIBM=<REPOSITORY_ABSOLUTE_PATH>/lib/libopenlibm-Linux-<TARGET_ARCH>.a' or set LIBOPENLIBM variable through 'ccmake'/'cmake-gui'.")
  endif()
  if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    list(APPEND PROJECT_LINK_ARGS -static-libstdc++ -static-libgcc)
  endif()
endif()

set(FINAL_EXEC_COMP_ARGS ${PROJECT_COMP_ARGS} ${COMP_EXEC_ARGS} CACHE STRING "Extra arguments/switches for compilation.")
set(FINAL_LIB_COMP_ARGS ${PROJECT_COMP_ARGS} ${COMP_LIB_ARGS} CACHE STRING "Extra arguments/switches for compilation.")
set(FINAL_EXEC_LINK_ARGS ${PROJECT_LINK_ARGS} ${LINK_EXEC_ARGS} CACHE STRING "Extra arguments/switches for linking.")
set(FINAL_LIB_LINK_ARGS ${PROJECT_LINK_ARGS} ${LINK_LIB_ARGS} CACHE STRING "Extra arguments/switches for linking.")
set(FINAL_EXEC_VERI_ARGS ${VERI_EXEC_ARGS}                      CACHE STRING "Extra arguments/switches for Verilating.")
set(FINAL_LIB_VERI_ARGS ${VERI_LIB_ARGS}                      CACHE STRING "Extra arguments/switches for Verilating.")

# The actual executable configuration

if(NOT CSOURCES OR NOT VTOP)
  message(FATAL_ERROR "Both 'CSOURCES' and 'VTOP' variables have to be set!")
endif()

add_executable(Vtop ${CSOURCES} ${RENODE_SOURCES})
add_library(libVtop SHARED ${CSOURCES} ${RENODE_SOURCES})
target_include_directories(Vtop PRIVATE ${VIL_DIR})
target_include_directories(libVtop PRIVATE ${VIL_DIR})

target_compile_options(Vtop PRIVATE ${FINAL_EXEC_COMP_ARGS})
target_compile_options(libVtop PRIVATE ${FINAL_LIB_COMP_ARGS})
target_link_libraries(Vtop PRIVATE ${FINAL_EXEC_LINK_ARGS})
target_link_libraries(libVtop PRIVATE ${FINAL_LIB_LINK_ARGS})

if(${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
  # Clang defaults to -std=gnu++98 but it has to be at least c++11
  set_property(TARGET Vtop PROPERTY CXX_STANDARD 11)
  set_property(TARGET libVtop PROPERTY CXX_STANDARD 11)
  set_property(TARGET Vtop PROPERTY CXX_STANDARD_REQUIRED)
  set_property(TARGET libVtop PROPERTY CXX_STANDARD_REQUIRED)

  # Verilator for now only supports "clang", "gnu" and "msvc" in
  # "--compiler" and creates it from CMAKE_CXX_COMPILER_ID
  set(CMAKE_CXX_COMPILER_ID Clang)
endif()
set_target_properties(libVtop PROPERTIES OUTPUT_NAME Vtop)

separate_arguments(FINAL_EXEC_VERI_ARGS)
separate_arguments(FINAL_LIB_VERI_ARGS)
verilate(Vtop SOURCES ${VTOP} VERILATOR_ARGS ${FINAL_EXEC_VERI_ARGS})

