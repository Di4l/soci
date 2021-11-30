################################################################################
# SociDependencies.cmake - part of CMake configuration of SOCI library
#
# Based on BoostExternals.cmake from CMake configuration for Boost
################################################################################
# Copyright (C) 2010 Mateusz Loskot <mateusz@loskot.net>
# Copyright (C) 2009 Troy Straszheim
#
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)
################################################################################
# Macros in this module:
#
#   soci_backend - defines a database backend for SOCI library
#
################################################################################

#
# List of SOCI dependncies
#
set(SOCI_CORE_DEPENDENCIES Threads)
set(SOCI_BACKENDS_DB_DEPENDENCIES)
set(SOCI_ALL_DEPENDENCIES
  ${SOCI_CORE_DEPENDENCIES}
  ${SOCI_BACKENDS_DB_DEPENDENCIES})

#
# Perform checks
#
colormsg(_HIBLUE_ "Looking for SOCI dependencies:")

#
# Detect available dependencies
#
foreach(external ${SOCI_ALL_DEPENDENCIES})
  string(TOUPPER "${external}" EXTERNAL)
  option(WITH_${EXTERNAL} "Attempt to find and configure ${external}" ON)
  if(WITH_${EXTERNAL})
    colormsg(HICYAN "${external}:")
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/dependencies/${external}.cmake)
  else()
    set(${EXTERNAL}_FOUND FALSE CACHE BOOL "${external} found" FORCE)
    colormsg(HIRED "${external}:" RED "disabled, since WITH_${EXTERNAL}=OFF")
  endif()
endforeach()
