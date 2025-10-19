# Generate a basic CMakeLists.txt for a C++ project with a main.cpp file that builds a "main" executable.


cmake_minimum_required(VERSION 3.14)
project(main VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(main main.cpp)