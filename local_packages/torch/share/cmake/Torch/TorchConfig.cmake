# FindTorch
# -------
#
# Finds the Torch library
#
# This will define the following variables:
#
#   TORCH_FOUND        -- True if the system has the Torch library
#   TORCH_INCLUDE_DIRS -- The include directories for torch
#   TORCH_LIBRARIES    -- Libraries to link against
#   TORCH_CXX_FLAGS    -- Additional (required) compiler flags
#
# and the following imported targets:
#
#   torch
macro(append_torchlib_if_found)
  foreach (_arg ${ARGN})
    find_library(${_arg}_LIBRARY ${_arg} PATHS "${TORCH_INSTALL_PREFIX}/lib")
    if(${_arg}_LIBRARY)
      list(APPEND TORCH_LIBRARIES ${${_arg}_LIBRARY})
    else()
      message(WARNING "static library ${${_arg}_LIBRARY} not found.")
    endif()
  endforeach()
endmacro()

macro(append_wholearchive_lib_if_found)
  foreach (_arg ${ARGN})
    find_library(${_arg}_LIBRARY ${_arg} PATHS "${TORCH_INSTALL_PREFIX}/lib")
    if(${_arg}_LIBRARY)
      if(APPLE)
        list(APPEND TORCH_LIBRARIES "-Wl,-force_load,${${_arg}_LIBRARY}")
      elseif(MSVC)
        list(APPEND TORCH_LIBRARIES "-WHOLEARCHIVE:${${_arg}_LIBRARY}")
      else()
        # Linux
        list(APPEND TORCH_LIBRARIES "-Wl,--whole-archive ${${_arg}_LIBRARY} -Wl,--no-whole-archive")
      endif()
    else()
      message(WARNING "static library ${${_arg}_LIBRARY} not found.")
    endif()
  endforeach()
endmacro()

include(FindPackageHandleStandardArgs)

if(DEFINED ENV{TORCH_INSTALL_PREFIX})
  set(TORCH_INSTALL_PREFIX $ENV{TORCH_INSTALL_PREFIX})
else()
  # Assume we are in <install-prefix>/share/cmake/Torch/TorchConfig.cmake
  get_filename_component(CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
  get_filename_component(TORCH_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)
endif()

# Include directories.
if(EXISTS "${TORCH_INSTALL_PREFIX}/include")
  set(TORCH_INCLUDE_DIRS
    ${TORCH_INSTALL_PREFIX}/include
    ${TORCH_INSTALL_PREFIX}/include/torch/csrc/api/include)
else()
  set(TORCH_INCLUDE_DIRS
    ${TORCH_INSTALL_PREFIX}/include
    ${TORCH_INSTALL_PREFIX}/include/torch/csrc/api/include)
endif()

# Library dependencies.
if(ON)
  find_package(Caffe2 REQUIRED PATHS ${CMAKE_CURRENT_LIST_DIR}/../Caffe2)
  set(TORCH_LIBRARIES torch ${Caffe2_MAIN_LIBS})
  append_torchlib_if_found(c10)
else()
  add_library(torch STATIC IMPORTED) # set imported_location at the bottom
  #library need whole archive
  append_wholearchive_lib_if_found(torch torch_cpu)
  if(ON)
    append_wholearchive_lib_if_found(torch_cuda c10_cuda)
  endif()
  if(OFF)
    append_wholearchive_lib_if_found(torch_xpu c10_xpu)
  endif()

  # We need manually add dependent libraries when they are not linked into the
  # shared library.
  # TODO: this list might be incomplete.
  append_torchlib_if_found(c10)

  if(ON)
    append_torchlib_if_found(nnpack)
  endif()

  if(ON)
    append_torchlib_if_found(pytorch_qnnpack)
  endif()

  if(ON)
    append_torchlib_if_found(XNNPACK)
    append_torchlib_if_found(microkernels-prod)
  endif()

  if(OFF)
    append_torchlib_if_found(kleidiai)
  endif()

  append_torchlib_if_found(caffe2_protos protobuf-lite protobuf protoc)
  append_torchlib_if_found(onnx onnx_proto)

  append_torchlib_if_found(fmt)
  append_torchlib_if_found(cpuinfo clog)

  append_torchlib_if_found(eigen_blas)
  append_torchlib_if_found(pthreadpool)

  if(ON)
    append_torchlib_if_found(fbgemm)
  endif()

  if(ON)
    append_torchlib_if_found(dnnl mkldnn)
  endif()

  append_torchlib_if_found(sleef asmjit)
endif()

if(1)
  append_torchlib_if_found(kineto)
endif()

if(ON)
  if(MSVC)
    find_library(CAFFE2_NVRTC_LIBRARY caffe2_nvrtc PATHS "${TORCH_INSTALL_PREFIX}/lib")
    list(APPEND TORCH_CUDA_LIBRARIES ${CAFFE2_NVRTC_LIBRARY})
  else()
    set(TORCH_CUDA_LIBRARIES ${CUDA_NVRTC_LIB})
  endif()
  if(TARGET torch::nvtoolsext)
    list(APPEND TORCH_CUDA_LIBRARIES torch::nvtoolsext)
  endif()

  if(ON)
    find_library(C10_CUDA_LIBRARY c10_cuda PATHS "${TORCH_INSTALL_PREFIX}/lib")
    list(APPEND TORCH_CUDA_LIBRARIES ${C10_CUDA_LIBRARY} ${Caffe2_PUBLIC_CUDA_DEPENDENCY_LIBS})
  endif()
  list(APPEND TORCH_LIBRARIES ${TORCH_CUDA_LIBRARIES})
endif()

if(OFF AND ON)
    append_torchlib_if_found(c10_xpu torch_xpu)
endif()

# When we build libtorch with the old libstdc++ ABI, dependent libraries must too.
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(TORCH_CXX_FLAGS "-D_GLIBCXX_USE_CXX11_ABI=1")
endif()

find_library(TORCH_LIBRARY torch PATHS "${TORCH_INSTALL_PREFIX}/lib")
# the statements below changes target properties on
# - the imported target from Caffe2Targets.cmake in shared library mode (see the find_package above)
#    - this is untested whether it is the correct (or desired) methodology in CMake
# - the imported target created in this file in static library mode
if(NOT ON)
  # do not set this property on the shared library target, as it will cause confusion in some builds
  # as the configuration specific property is set in the Caffe2Targets.cmake file
  set_target_properties(torch PROPERTIES
      IMPORTED_LOCATION "${TORCH_LIBRARY}"
  )
endif()
set_target_properties(torch PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${TORCH_INCLUDE_DIRS}"
    CXX_STANDARD 17
)
if(TORCH_CXX_FLAGS)
  set_property(TARGET torch PROPERTY INTERFACE_COMPILE_OPTIONS "${TORCH_CXX_FLAGS}")
endif()

find_package_handle_standard_args(Torch DEFAULT_MSG TORCH_LIBRARY TORCH_INCLUDE_DIRS)
