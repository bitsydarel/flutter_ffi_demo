cmake_minimum_required(VERSION 3.4.1)

add_library(
    lmdb SHARED
    mdb.c
    midl.c
)