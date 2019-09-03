################################################################################
# `ament_cmake_version` function creates and installs a version header file.
# The version is taken from `package.xml` file's `<version>` tag
# The function uses an existing "resource/version.h.in" template file to generate
# the destination `version.h` file and installs that generated file into `DESTINATION include`.
# The generated file is being (re-)created if:
# - the file does not exist
# - the file does exists but contains a version that differs from the version in `package.xml` file
################################################################################
# Example of a template file for `rcutils` project:
# // Copyright 2015 Open Source Robotics Foundation, Inc.
# //
# // Licensed under the Apache License, Version 2.0 (the "License");
# // you may not use this file except in compliance with the License.
# // You may obtain a copy of the License at
# //
# //     http://www.apache.org/licenses/LICENSE-2.0
# //
# // Unless required by applicable law or agreed to in writing, software
# // distributed under the License is distributed on an "AS IS" BASIS,
# // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# // See the License for the specific language governing permissions and
# // limitations under the License.
#
# #ifndef RCUTILS__VERSION_H_
# #define RCUTILS__VERSION_H_
#
# /// \def RCUTILS_VERSION_MAJOR
# /// Defines RCUTILS major version number
# #define RCUTILS_VERSION_MAJOR (@rcutils_VERSION_MAJOR@)
#
# /// \def RCUTILS_VERSION_MINOR
# /// Defines RCUTILS minor version number
# #define RCUTILS_VERSION_MINOR (@rcutils_VERSION_MINOR@)
#
# /// \def RCUTILS_VERSION_PATCH
# /// Defines RCUTILS version patch number
# #define RCUTILS_VERSION_PATCH (@rcutils_VERSION_PATCH@)
#
# /// \def RCUTILS_VERSION_STR
# /// Defines RCUTILS version string
# #define RCUTILS_VERSION_STR "@rcutils_VERSION@"
#
# #endif  // RCUTILS__VERSION_H_"

function(ament_cmake_version)
  include_directories(${CMAKE_CURRENT_BINARY_DIR}/ament_cmake_version/include)
  set(TMP_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/ament_cmake_version/include/${PROJECT_NAME})

  set(${PROJECT_NAME}_VERSION_FILE_NAME ${TMP_INCLUDE_DIR}/version.h)
  set(NEED_TO_CREATE_VERSION_FILE FALSE)

  # retrieve verson information from <package>.xml file
  # call ament_package_xml() if it has not been called before
  if(NOT _AMENT_PACKAGE_NAME)
    ament_package_xml()
  endif()

  # parse version information from the version string
  string(REGEX MATCH "([0-9]+\).([0-9]+)\.([0-9]+)" "" dummy ${${PROJECT_NAME}_VERSION})
  set(${PROJECT_NAME}_VERSION_MAJOR ${CMAKE_MATCH_1})
  set(${PROJECT_NAME}_VERSION_MINOR ${CMAKE_MATCH_2})
  set(${PROJECT_NAME}_VERSION_PATCH ${CMAKE_MATCH_3})

  # sanity checks
  if("${${PROJECT_NAME}_VERSION_MAJOR}" STREQUAL "")
    message(FATAL_ERROR "${PROJECT_NAME}_VERSION_MAJOR is empty or non-numeric, check <package>.XML")
  endif()
  if("${${PROJECT_NAME}_VERSION_MINOR}" STREQUAL "")
    message(FATAL_ERROR "${PROJECT_NAME}_VERSION_MINOR is empty or non-numeric, check <package>.XML")
  endif()
  if("${${PROJECT_NAME}_VERSION_PATCH}" STREQUAL "")
    message(FATAL_ERROR "${PROJECT_NAME}_VERSION_PATCH is empty or non-numeric, check <package>.XML")
  endif()

  # Check if the version file exist
  if(EXISTS "${${PROJECT_NAME}_VERSION_FILE_NAME}")
    # The file exists
    # Check if it contains the same version
    file(STRINGS ${${PROJECT_NAME}_VERSION_FILE_NAME} VERSION_FILE_STRINGS REGEX "#define ${PROJECT_NAME}_VERSION_STR")
    if(VERSION_FILE_STRINGS STREQUAL "")
      set(NEED_TO_CREATE_VERSION_FILE TRUE)
    else()
      string(REGEX MATCH "^#define[ \t]+${PROJECT_NAME}_VERSION_STR[ \t]+\"([0-9]+\.[0-9]+\.[0-9]+)\"" "" dummy ${VERSION_FILE_STRINGS})
      if(NOT (${CMAKE_MATCH_1} STREQUAL ${${PROJECT_NAME}_VERSION}))
        # Create new file if file version != ${PROJECT_NAME}_VERSION
        set(NEED_TO_CREATE_VERSION_FILE TRUE)
      endif()
    endif()
  else()
    # if the version file does not exist, create it
    set(NEED_TO_CREATE_VERSION_FILE TRUE)
  endif()

  if(${NEED_TO_CREATE_VERSION_FILE})
    message(STATUS "Create new version file for version ${${PROJECT_NAME}_VERSION}")
    file(MAKE_DIRECTORY ${TMP_INCLUDE_DIR})
    # create the version.h file
    configure_file("resource/version.h.in" ${${PROJECT_NAME}_VERSION_FILE_NAME} NEWLINE_STYLE UNIX)
  else()
      message(STATUS "Skip version file creation")
  endif()

  install(
    DIRECTORY ${TMP_INCLUDE_DIR}
    DESTINATION include)
endfunction()
