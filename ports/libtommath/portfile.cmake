include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtom/libtommath
    REF v1.1.0
    SHA512 264942414033be70fb73590ec65912a3e8c6ee9c00fb0ce5b684a861af4804b6ccfb8d01821cc5c61348768b44c9c11fd58af0b54d654366329b01b56c644ea7
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(SEP ";")
    #We're assuming that if we're building for Windows we're using MSVC
    set(INCLUDE_VAR "INCLUDE")
    set(LIB_PATH_VAR "LIB")
else()
    set(SEP ":")
    set(INCLUDE_VAR "CPATH")
    set(LIB_PATH_VAR "LIBRARY_PATH")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(BUILD_SCRIPT ${CMAKE_CURRENT_LIST_DIR}\\build.sh)

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES perl gcc diffutils make)
    else()
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils make)
    endif()

    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
else()
    set(BASH /bin/bash)
    set(BUILD_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/build_linux.sh)
endif()

set(ENV{${INCLUDE_VAR}} "${CURRENT_INSTALLED_DIR}/include${SEP}$ENV{${INCLUDE_VAR}}")

set(_csc_PROJECT_PATH libtommath)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        message(FATAL_ERROR "Dynamic linkage not supported on Windows.")
    else()
        set(MAKEFILE makefile.msvc)
    endif()
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(MAKEFILE makefile.shared)
    else()
        set(MAKEFILE makefile)
    endif()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    # Configure release
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    file(COPY ${SOURCE_PATH} DESTINATION ${CURRENT_BUILDTREES_DIR})
    get_filename_component(SOURCE_DIRNAME ${SOURCE_PATH} NAME)
    file(RENAME ${CURRENT_BUILDTREES_DIR}/${SOURCE_DIRNAME} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
endif()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
    # Build release
    message(STATUS "Package ${TARGET_TRIPLET}-rel")
    vcpkg_execute_build_process(
        COMMAND ${BASH} --noprofile --norc -c "make -f ${MAKEFILE} -j ${VCPKG_CONCURRENCY}"
        NO_PARALLEL_COMMAND ${BASH} --noprofile --norc -c "make -f ${MAKEFILE}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME "make-build-${TARGET_TRIPLET}-rel"
    )
    vcpkg_execute_build_process(
        COMMAND ${BASH} --noprofile --norc -c "make -f ${MAKEFILE} \"PREFIX=${CURRENT_PACKAGES_DIR}\" install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        LOGNAME "make-install-${TARGET_TRIPLET}-rel"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtommath RENAME copyright)
