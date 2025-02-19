cmake_minimum_required(VERSION 3.16)
project(gtsam_playground VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)

find_package(GTSAM REQUIRED)
find_package(Eigen3 REQUIRED)

file(GLOB SOURCES ${CMAKE_CURRENT_LIST_DIR}/src/*.cpp)
add_executable(gtsam_playground ${SOURCES})

target_include_directories(gtsam_playground PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/include)
target_link_libraries(gtsam_playground
    Eigen3::Eigen
    gtsam)