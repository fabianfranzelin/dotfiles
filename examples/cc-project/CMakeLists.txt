cmake_minimum_required(VERSION 3.16)
project(cc-project LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_BUILD_TYPE Debug)

add_executable(main
  main.cpp
)
