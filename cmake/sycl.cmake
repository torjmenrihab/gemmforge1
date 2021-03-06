add_library(${GPU_TARGET} SHARED ${GPU_TARGET_SOURCE_FILES})

if (${DEVICE_BACKEND} STREQUAL "hipsycl")
    set(HIPSYCL_TARGETS "cuda:${DEVICE_ARCH}")

    find_package(hipSYCL CONFIG REQUIRED)
    add_sycl_to_target(TARGET ${GPU_TARGET}  SOURCES ${DEVICE_SOURCE_FILES})
else()
    if("$ENV{PREFERRED_DEVICE_TYPE}" STREQUAL "FPGA")
        message(NOTICE "FPGA is used as target device, compilation will take several hours to complete!")
        target_compile_options(${GPU_TARGET}  PRIVATE "-fsycl" "-fintelfpga" "-fsycl-unnamed-lambda")
        set_target_properties(${GPU_TARGET}  PROPERTIES LINK_FLAGS "-fsycl -fintelfpga -Xshardware")
    elseif("$ENV{PREFERRED_DEVICE_TYPE}" STREQUAL "GPU")
        if(${DEVICE_ARCH} MATCHES "sm_*")
            target_compile_options(${GPU_TARGET}  PRIVATE "-fsycl" "-fsycl-targets=nvptx64-nvidia-cuda-sycldevice" "-fsycl-unnamed-lambda" "-Xsycl-target-backend" "--cuda-gpu-arch=${DEVICE_ARCH}")
            set_target_properties(${GPU_TARGET}  PROPERTIES LINK_FLAGS "-fsycl -fsycl-targets=nvptx64-nvidia-cuda-sycldevice -Xs \"-device ${DEVICE_ARCH}\"")
        else()
            target_compile_options(${GPU_TARGET}  PRIVATE "-fsycl" "-fsycl-targets=spir64_gen-unknown-unknown-sycldevice" "-fsycl-unnamed-lambda")
            set_target_properties(${GPU_TARGET}  PROPERTIES LINK_FLAGS "-fsycl -fsycl-targets=spir64_gen-unknown-unknown-sycldevice -Xs \"-device ${DEVICE_ARCH}\"")
        endif()
    elseif("$ENV{PREFERRED_DEVICE_TYPE}" STREQUAL "CPU")
        target_compile_options(${GPU_TARGET}  PRIVATE "-fsycl" "-fsycl-targets=spir64_x86_64-unknown-unknown-sycldevice" "-fsycl-unnamed-lambda")
        set_target_properties(${GPU_TARGET}  PROPERTIES LINK_FLAGS "-fsycl -fsycl-targets=spir64_x86_64-unknown-unknown-sycldevice -Xs \"-march=${DEVICE_ARCH}\"")
    else()
        target_compile_options(${GPU_TARGET}  PRIVATE "-fsycl" "-fsycl-unnamed-lambda")
        message(WARNING "No device type specified for compilation, AOT and other platform specific details may be disabled")
    endif()
endif()

target_compile_options(${GPU_TARGET} PRIVATE "-std=c++17" "-O3")
target_compile_definitions(${GPU_TARGET} PRIVATE DEVICE_${DEVICE_BACKEND}_LANG REAL_SIZE=${REAL_SIZE})
target_link_libraries(${GPU_TARGET} PUBLIC stdc++fs)