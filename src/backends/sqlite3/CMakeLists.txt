###############################################################################
#
# This file is part of CMake configuration for SOCI library
#
# Copyright (C) 2010 Mateusz Loskot <mateusz@loskot.net>
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)
#
###############################################################################

#soci_backend(SQLite3
#  DEPENDS SQLite3
#  DESCRIPTION "SOCI backend for SQLite 3"
#  AUTHORS "Maciej Sobczak, Stephen Hutton, David Courtney"
#  MAINTAINERS "Maciej Sobczak, Mateusz Loskot")

# Backend name variants utils
set(NAME SQLite3)
set(PROJECT_NAME SOCI)

string(TOLOWER "${PROJECT_NAME}" PROJECTNAMEL)
string(TOLOWER "${NAME}" NAMEL)
string(TOUPPER "${NAME}" NAMEU)

get_directory_property(THIS_INCLUDE_DIRS INCLUDE_DIRECTORIES)
get_directory_property(THIS_COMPILE_DEFS COMPILE_DEFINITIONS)

# Backend-specific depedencies
set(THIS_BACKEND_DEPENDS_INCLUDE_DIRS ${SQLITE3_INCLUDE_DIR})
set(THIS_BACKEND_DEPENDS_LIBRARIES ${SQLITE3_LIBRARY})
set(THIS_BACKEND_DEPENDS_DEFS ${SQLITE3_DEPS_DEFS})

# Collect include directories
list(APPEND THIS_INCLUDE_DIRS ${SOCI_SOURCE_DIR}/include/private)
list(APPEND THIS_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/vendor/sqlite3)
# Collect compile definitions
list(APPEND THIS_COMPILE_DEFS ${THIS_BACKEND_DEPENDS_DEFS})

set_directory_properties(PROPERTIES
  INCLUDE_DIRECTORIES "${THIS_INCLUDE_DIRS}"
  COMPILE_DEFINITIONS "${THIS_COMPILE_DEFS}")

# Backend target
set(THIS_BACKEND_VAR SOCI_${NAMEU})
set(THIS_BACKEND_TARGET ${PROJECTNAMEL}_${NAMEL})
set(THIS_BACKEND_TARGET_VAR ${THIS_BACKEND_VAR}_TARGET)
set(${THIS_BACKEND_TARGET_VAR} ${THIS_BACKEND_TARGET})

target_output_name(${THIS_BACKEND_TARGET} ${THIS_BACKEND_VAR}_OUTPUT_NAME)

set(THIS_BACKEND_OUTPUT_NAME ${${THIS_BACKEND_VAR}_OUTPUT_NAME})
set(THIS_BACKEND_OUTPUT_NAME_VAR ${THIS_BACKEND_VAR}_OUTPUT_NAME)

set(${THIS_BACKEND_VAR}_COMPILE_DEFINITIONS ${THIS_COMPILE_DEFS})
set(THIS_BACKEND_COMPILE_DEFINITIONS_VAR ${THIS_BACKEND_VAR}_COMPILE_DEFINITIONS)

set(${THIS_BACKEND_VAR}_INCLUDE_DIRECTORIES ${THIS_INCLUDE_DIRS})
set(THIS_BACKEND_INCLUDE_DIRECTORIES_VAR ${THIS_BACKEND_VAR}_INCLUDE_DIRECTORIES)

# Backend installable headers and sources
file(GLOB THIS_BACKEND_HEADERS ${SOCI_SOURCE_DIR}/include/soci/sqlite3/*.h)
file(GLOB THIS_BACKEND_SOURCES *.cpp)
set(THIS_BACKEND_HEADERS_VAR SOCI_SQLITE3_HEADERS)
set(${THIS_BACKEND_HEADERS_VAR} ${THIS_BACKEND_HEADERS})
# Group source files for IDE source explorers (e.g. Visual Studio)
source_group("Header Files" FILES ${THIS_BACKEND_HEADERS})
source_group("Source Files" FILES ${THIS_BACKEND_SOURCES})
source_group("CMake Files" FILES CMakeLists.txt)

# TODO: Extract as macros: soci_shared_lib_target and soci_static_lib_target --mloskot
# Shared library target
if (BUILD_WITH_SHARED_LIBS)
	add_library(${THIS_BACKEND_TARGET}
	  SHARED
	  ${THIS_BACKEND_SOURCES}
	  ${THIS_BACKEND_HEADERS})

  add_dependencies(${THIS_BACKEND_TARGET} SQLite3)

	target_link_libraries(${THIS_BACKEND_TARGET}
	  ${SOCI_CORE_TARGET}
	  ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/SQLite3${CMAKE_IMPORT_LIBRARY_SUFFIX})

	if(WIN32)
	  set_target_properties(${THIS_BACKEND_TARGET}
		PROPERTIES
		OUTPUT_NAME ${THIS_BACKEND_OUTPUT_NAME}
		DEFINE_SYMBOL SOCI_DLL)
	else()
	  set_target_properties(${THIS_BACKEND_TARGET}
		PROPERTIES
		SOVERSION ${${PROJECT_NAME}_SOVERSION}
		INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/lib)
	endif()

	set_target_properties(${THIS_BACKEND_TARGET}
	  PROPERTIES
	  VERSION ${${PROJECT_NAME}_VERSION}
	  CLEAN_DIRECT_OUTPUT 1)
endif()

# Static library target
if(BUILD_WITH_STATIC_LIBS)
	set(THIS_BACKEND_TARGET_STATIC ${THIS_BACKEND_TARGET}_static)

	add_library(${THIS_BACKEND_TARGET_STATIC}
	  STATIC
	  ${THIS_BACKEND_SOURCES}
	  ${THIS_BACKEND_HEADERS})

  add_dependencies(${THIS_BACKEND_TARGET} SQLite3_static)

	# Still need to link the libraries for tests to work
	target_link_libraries (${THIS_BACKEND_TARGET_STATIC}
	  ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/SQLite3_static${CMAKE_IMPORT_LIBRARY_SUFFIX})

	set_target_properties(${THIS_BACKEND_TARGET_STATIC}
	  PROPERTIES
	  OUTPUT_NAME ${THIS_BACKEND_OUTPUT_NAME}
	  PREFIX "lib"
	  CLEAN_DIRECT_OUTPUT 1)
endif()

# Backend installation
install(FILES ${THIS_BACKEND_HEADERS}
		DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECTNAMEL}/${NAMEL})

if (BUILD_WITH_SHARED_LIBS)
	install(TARGETS ${THIS_BACKEND_TARGET}
	  EXPORT SOCI
	  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
	  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
	  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
	 )
endif()

if (BUILD_WITH_STATIC_LIBS)
	install(TARGETS ${THIS_BACKEND_TARGET_STATIC}
	  EXPORT SOCI
	  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
	  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
	  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
	 )
endif()
