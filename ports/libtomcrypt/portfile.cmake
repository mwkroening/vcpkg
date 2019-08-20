include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtom/libtomcrypt
    REF v1.18.2
    SHA512 53accb4f92077ff1c52102bece270e77c497e599c392aa0bf4dbc173b6789e7e4f1012d8b5f257c438764197cb7bac8ba409a9d4e3a70e69bec5863b9495329e
    HEAD_REF master
)
