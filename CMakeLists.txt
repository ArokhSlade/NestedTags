cmake_minimum_required(VERSION 3.20)
project(nested_tags)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. Include godot-cpp CMake configuration (creates godot::cpp target)
add_subdirectory(godot-cpp)

# 2. Collect ONLY your project's source and header files
file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
        "nested_tags-cpp/*.cpp"
        "nested_tags-cpp/*.h"
        "nested_tags-cpp/*.hpp"
)

# 3. Create your shared library using only your sources
add_library(${PROJECT_NAME} SHARED ${SOURCES})

# 4. Link against godot::cpp (handles all godot-cpp headers and symbols)
target_link_libraries(${PROJECT_NAME} PRIVATE godot::cpp)

target_include_directories(${PROJECT_NAME} PRIVATE
        godot-cpp/include
        godot-cpp/gen/include
        godot-cpp/gdextension
)