###############################################################################
#
# This file is part of CMake configuration for SOCI library
#
# Copyright (C) 2009-2013 Mateusz Loskot <mateusz@loskot.net>
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)
#
###############################################################################
# General settings
###############################################################################
cmake_minimum_required(VERSION 3.1 FATAL_ERROR)


project(SOCI)

###############################################################################
# Build features and variants
##############################################################################

set(SOCI_VISIBILITY ON)

if(SOCI_VISIBILITY)
    # Test whether visibility is supported
    include(CheckCSourceCompiles)
    check_c_source_compiles(
        "
            __attribute__ (( visibility(\"default\") )) int f1() { return 0; }
            __attribute__ (( visibility(\"hidden\") ))  int f2() { return 1; }

            int main(int argc, char* argv[]) { f1(); f2(); return 0; }
        "
        SOCI_HAVE_VISIBILITY_SUPPORT
    )

    if (SOCI_HAVE_VISIBILITY_SUPPORT)
        message(STATUS "gcc / clang visibility enabled")
        set(CMAKE_CXX_VISIBILITY_PRESET hidden)
        cmake_policy(SET CMP0063 NEW)
    endif()
else()
    set(SOCI_HAVE_VISIBILITY_SUPPORT off)
endif()

###############################################################################
# SOCI CMake modules
###############################################################################

# Path to additional CMake modules
set(CMAKE_MODULE_PATH ${SOCI_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
set(CMAKE_MODULE_PATH ${SOCI_SOURCE_DIR}/cmake/modules ${CMAKE_MODULE_PATH})

include(SociConfig)
include(SociUtilities)

colormsg(_HIBLUE_ "Configuring SOCI:")

###############################################################################
# SOCI version information
###############################################################################
include(SociVersion)

soci_version()

# Put the libaries and binaries that get built into directories at the
# top of the build tree rather than in hard-to-find leaf
# directories. This simplifies manual testing and the use of the build
# tree rather than installed Boost libraries.
#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
#set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

###############################################################################
# Find SOCI dependencies
###############################################################################

set(SOCI_CORE_TARGET)
set(SOCI_CORE_TARGET_STATIC)
set(SOCI_CORE_DEPS_LIBS)

include(SociDependencies)

get_property(SOCI_INCLUDE_DIRS DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  PROPERTY INCLUDE_DIRECTORIES)

if(Threads_FOUND)
  list(APPEND SOCI_CORE_DEPS_LIBS ${CMAKE_THREAD_LIBS_INIT})
else()
  message(FATAL_ERROR "No thread library found")
endif()

if(NOT MSVC)
  set(DL_FIND_QUIETLY TRUE)
  find_package(DL)
  if(DL_FOUND)
    list(APPEND SOCI_CORE_DEPS_LIBS ${DL_LIBRARY})
    set_directory_properties(PROPERTIES INCLUDE_DIRECTORIES ${DL_INCLUDE_DIR})
    add_definitions(-DHAVE_DL=1)
  endif()
endif()

# Disable boost
#set(SOCI_HAVE_BOOST OFF)
#set(SOCI_HAVE_BOOST_DATE_TIME OFF)

#set(SOCI_HAVE_BOOST ${SOCI_HAVE_BOOST} CACHE INTERNAL "Boost library")
#set(SOCI_HAVE_BOOST_DATE_TIME ${SOCI_HAVE_BOOST_DATE_TIME} CACHE INTERNAL "Boost date_time library")

list(APPEND SOCI_INCLUDE_DIRS ${CMAKE_CURRENT_BINARY_DIR})

set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  PROPERTY
  INCLUDE_DIRECTORIES ${SOCI_INCLUDE_DIRS})

###############################################################################
# Installation
###############################################################################

include(GNUInstallDirs)

###############################################################################
# Configuration files
###############################################################################
set(CONFIG_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/include)
install(DIRECTORY ${CONFIG_INCLUDE_DIR}/soci DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
set(CONFIG_FILE_IN "include/soci/soci-config.h.in")
set(CONFIG_FILE_OUT "${SOCI_SOURCE_DIR}/include/soci/soci-config.h")



###############################################################################
# Build configured components
###############################################################################

include_directories(${SOCI_SOURCE_DIR}/include ${CONFIG_INCLUDE_DIR})
add_subdirectory(src)

###############################################################################
# build config file
###############################################################################

get_cmake_property(ALL_VARIABLES CACHE_VARIABLES)
set(CONFIGURED_VARIABLES)
foreach(v ${ALL_VARIABLES})
    if (v MATCHES "^SOCI_HAVE.*")
	get_property(CACHE_HELPSTRING CACHE ${v} PROPERTY HELPSTRING)
		set(CONFIGURED_VARIABLES "${CONFIGURED_VARIABLES}\n// ${CACHE_HELPSTRING}\n")
        if (${${v}})
            set(CONFIGURED_VARIABLES "${CONFIGURED_VARIABLES}#define ${v}\n")
        else()
            set(CONFIGURED_VARIABLES "${CONFIGURED_VARIABLES}/* #undef ${v} */\n")
        endif()
    endif()
endforeach()
configure_file("${CONFIG_FILE_IN}" "${CONFIG_FILE_OUT}")

message(STATUS "")
