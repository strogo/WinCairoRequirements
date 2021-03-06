include(vcpkg_common_functions)

set(LIBPNG_VERSION 1.6.35)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libpng-${LIBPNG_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/libpng/libpng16/${LIBPNG_VERSION}/libpng-${LIBPNG_VERSION}.tar.gz"
    FILENAME "libpng-${LIBPNG_VERSION}.tar.gz"
    SHA512 e4312a4b33e02ad975864d8f1b0c29427625257983962ddd043f258643c18ddcb15a118405282f04d1310817e454a95111e2d4569de494d01d649c7171fd3127
)
vcpkg_extract_source_archive(${ARCHIVE})

# Apply patches
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/patches/0001-Skip-install-symlink.patch
        ${CMAKE_CURRENT_LIST_DIR}/patches/0002-Do-not-append-static-to-library-name.patch
        ${CMAKE_CURRENT_LIST_DIR}/patches/0003-Remove-m-library-when-not-found.patch
)

# Run CMake build
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PNG_STATIC_LIBS OFF)
    set(PNG_SHARED_LIBS ON)
else()
    set(PNG_STATIC_LIBS ON)
    set(PNG_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPNG_STATIC=${PNG_STATIC_LIBS}
        -DPNG_SHARED=${PNG_SHARED_LIBS}
        -DPNG_TESTS=OFF
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
        -DSKIP_INSTALL_SYMLINK=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Prepare distribution
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libpng ${CURRENT_PACKAGES_DIR}/debug/lib/libpng)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpng RENAME copyright)
