# Copyright 2014-2015 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Generate setup files in share folder of the current package.
#
# @public
#
function(ament_generate_package_environment)
  if(ARGN)
    message(FATAL_ERROR "ament_generate_package_environment() called with "
      "unused arguments: ${ARGN}")
  endif()

  # mark that ament_generate_package_environment() was called
  # in order to detect wrong order of calling
  set(_${PROJECT_NAME}_AMENT_GENERATE_PACKAGE_ENVIRONMENT TRUE PARENT_SCOPE)

  set(all_hooks "")

  # configure and install setup files for the package
  foreach(file ${ament_cmake_package_templates_PACKAGE_LEVEL})
    # check if the file is a template
    string_ends_with("${file}" ".in" is_template)
    if(is_template)
      # cut of the path and the .in extension
      get_filename_component(name "${file}" NAME)
      string(LENGTH "${name}" length)
      math(EXPR offset "${length} - 3")
      string(SUBSTRING "${name}" 0 ${offset} name)

      # extract the extension
      string(FIND "${name}" "." index REVERSE)
      if(index EQUAL -1)
        message(FATAL_ERROR "ament_generate_package_environment() called with "
          "the template '${file}' which doesn't have a file extension")
      endif()
      math(EXPR index "${index} + 1")
      string(SUBSTRING "${name}" ${index} -1 extension)

      # collect package hooks to be sourced for this extension
      set(ENVIRONMENT_HOOKS "")
      if(DEFINED _AMENT_CMAKE_ENVIRONMENT_HOOKS_${extension})
        list(SORT _AMENT_CMAKE_ENVIRONMENT_HOOKS_${extension})
        foreach(hook ${_AMENT_CMAKE_ENVIRONMENT_HOOKS_${extension}})
          set(all_hooks "${all_hooks}source;${hook}\n")
          set(native_hook "/${hook}")
          file(TO_NATIVE_PATH "${native_hook}" native_hook)
          if(WIN32)
            set(ENVIRONMENT_HOOKS
                "${ENVIRONMENT_HOOKS}call:ament_append_value AMENT_ENVIRONMENT_HOOKS[${PROJECT_NAME}] \"%AMENT_CURRENT_PREFIX%${native_hook}\"\n")
          else()
            set(ENVIRONMENT_HOOKS
                "${ENVIRONMENT_HOOKS}ament_append_value AMENT_ENVIRONMENT_HOOKS \"$AMENT_CURRENT_PREFIX${native_hook}\"\n")
          endif()
        endforeach()
      endif()

      # expand template
      configure_file(
        "${file}"
        "${CMAKE_BINARY_DIR}/ament_cmake_environment_hooks/${name}"
        @ONLY
      )
      set(file "${CMAKE_BINARY_DIR}/ament_cmake_environment_hooks/${name}")
    endif()

    install(
      FILES "${file}"
      DESTINATION "share/${PROJECT_NAME}"
    )
  endforeach()

  set(dsv_file "${CMAKE_BINARY_DIR}/ament_cmake_environment_hooks/local_setup.dsv")
  file(WRITE "${dsv_file}" "${all_hooks}")
  install(
    FILES "${dsv_file}"
    DESTINATION "share/${PROJECT_NAME}"
  )
endfunction()
