# Copyright: (C) 2009 RobotCub Consortium
# Authors: Lorenzo Natale
# CopyPolicy: Released under the terms of the GNU GPL v2.0.
# Based on code from yarp.

macro(checkandset_dependency package)
  if(${package}_FOUND)
    set(ICUB_HAS_${package} TRUE CACHE BOOL "Package ${package} found" FORCE)
    set(ICUB_USE_${package} TRUE CACHE BOOL "Use package ${package}")
    message(STATUS "${package}: found")
  else()
    set(ICUB_HAS_${package} FALSE CACHE BOOL "" FORCE)
    set(ICUB_USE_${package} FALSE CACHE BOOL "Use package ${package}")
    message(STATUS "${package}: NOT found")
  endif()
  mark_as_advanced(ICUB_HAS_${package})

  if(NOT ${package}_FOUND AND ICUB_USE_${package})
    message(WARNING "You requested to use the package ${package}, but it is unavailable (or was not found). This might lead to build errors. Thus, we recommend that you turn off the ICUB_USE_${package} flag.")
  endif()

  #store all dependency flags for later export
  set_property(GLOBAL APPEND PROPERTY ICUB_DEPENDENCIES_FLAGS ICUB_USE_${package})
endmacro()


message(STATUS "Detecting required libraries")
message(STATUS "CMake modules directory: ${CMAKE_MODULE_PATH}")

find_package(icub_firmware_shared QUIET)
find_package(GSL)
find_package(GLUT)
find_package(OpenCV)
find_package(OpenGL)
find_package(SDL)
find_package(ACE)
find_package(IPOPT)
find_package(Qt5 COMPONENTS Core Widgets OpenGL Quick Qml Concurrent PrintSupport QUIET)

message(STATUS "OpenCV version is ${OpenCV_VERSION_MAJOR}.${OpenCV_VERSION_MINOR}")
if (OpenCV_FOUND)
  # check version of openCV
  if (OpenCV_VERSION_MAJOR GREATER 1)
    message(STATUS "OpenCV is at least version 2")
    set(ICUB_OpenCV_LEGACY false CACHE BOOL "Legacy version of OpenCV detected" FORCE)
    mark_as_advanced(ICUB_OpenCV_LEGACY)
  else()
    set(ICUB_OpenCV_LEGACY true CACHE BOOL "Legacy version of OpenCV detected" FORCE)
    message(STATUS "OpenCV is previous 2.0 (some modules will be skipped)")
    message(STATUS "Setting ICUB_OpenCV_LEGACY true")
  endif()

  set(ICUB_LINK_DIRECTORIES ${ICUB_LINK_DIRECTORIES} ${OpenCV_LIB_DIR})
endif()
message(STATUS "I have found the following libraries:")

checkandset_dependency(icub_firmware_shared)
checkandset_dependency(GSL)
checkandset_dependency(GLUT)
checkandset_dependency(OpenGL)
checkandset_dependency(SDL)
checkandset_dependency(ACE)
checkandset_dependency(IPOPT)
checkandset_dependency(OpenCV)
checkandset_dependency(Qt5)

set(MINIMUM_REQUIRED_icub_firmware_shared_VERSION 1.43.0)

if(icub_firmware_shared_FOUND AND ICUB_USE_icub_firmware_shared)
  if(icub_firmware_shared_VERSION VERSION_LESS ${MINIMUM_REQUIRED_icub_firmware_shared_VERSION})
    message(FATAL_ERROR "An old version of icub-firmware-shared has been detected: at least ${MINIMUM_REQUIRED_icub_firmware_shared_VERSION} is required")
  endif()
endif()

if(YARP_HAS_LIBMATH)
  set(ICUB_HAS_YARPMATH true)
  message(STATUS "found yarp math library")
endif()
