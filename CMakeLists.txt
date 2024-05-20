cmake_minimum_required(VERSION 2.8.12)

# Set extension name here
set(TARGET_NAME cypher)

# GraphDB with JNI
find_package(JNI REQUIRED)

set(EXTENSION_NAME ${TARGET_NAME}_extension)
set(LOADABLE_EXTENSION_NAME ${TARGET_NAME}_loadable_extension)

project(${TARGET_NAME})
include_directories(src/include)

# GraphDB with JNI
include_directories("$ENV{MINIREL_HOME}/h")
include_directories(${JNI_INCLUDE_DIRS})

set(EXTENSION_SOURCES src/cypher_extension.cpp src/read_graph.cpp)

build_static_extension(${TARGET_NAME} ${EXTENSION_SOURCES})
build_loadable_extension(${TARGET_NAME} " " ${EXTENSION_SOURCES})

# GraphDB with JNI
target_link_libraries(${EXTENSION_NAME}
  "$ENV{MINIREL_HOME}/lib/libfe.a"
  "$ENV{MINIREL_HOME}/lib/libtrv.a"
  "$ENV{MINIREL_HOME}/lib/libhf.a"
  "$ENV{MINIREL_HOME}/lib/libpf.a"
  "$ENV{MINIREL_HOME}/lib/libbf.a"
  ${JNI_LIBRARIES})
target_link_libraries(${LOADABLE_EXTENSION_NAME}
  "$ENV{MINIREL_HOME}/lib/libfe.a"
  "$ENV{MINIREL_HOME}/lib/libtrv.a"
  "$ENV{MINIREL_HOME}/lib/libhf.a"
  "$ENV{MINIREL_HOME}/lib/libpf.a"
  "$ENV{MINIREL_HOME}/lib/libbf.a"
  ${JNI_LIBRARIES})

install(
  TARGETS ${EXTENSION_NAME}
  EXPORT "${DUCKDB_EXPORT_SET}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}")
