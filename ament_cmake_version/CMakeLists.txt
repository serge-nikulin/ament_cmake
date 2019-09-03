cmake_minimum_required(VERSION 3.10)

project(ament_cmake_version NONE)

find_package(ament_cmake_core REQUIRED)

ament_package(CONFIG_EXTRAS "ament_cmake_version-extras.cmake")

if(BUILD_TESTING)
    find_package(ament_cmake_lint_cmake REQUIRED)
    ament_lint_cmake(${CMAKE_CURRENT_SOURCE_DIR})
endif()

install(
  DIRECTORY cmake
  DESTINATION share/${PROJECT_NAME}
)
