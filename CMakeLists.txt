project (com.github.rsaprun.code)
cmake_minimum_required (VERSION 2.6)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/com.github.rsaprun.code")
set (EXEC_NAME "com.github.rsaprun.code")
set (RELEASE_NAME "Code Editor")
set (VERSION "0.1")
set (VERSION_INFO "Release")
find_package(PkgConfig)
pkg_check_modules(GRANITE REQUIRED granite)
pkg_check_modules(GTK REQUIRED gtk+-3.0)
pkg_check_modules(LIBSOURCE REQUIRED gtksourceview-3.0)
add_definitions(${GTK_CFLAGS} ${LIBSOURCE_CFLAGS} ${GRANITE_CFLAGS})
link_libraries(${GTK_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GRANITE_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GRANITE_LIBRARY_DIRS})
find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.22" MINIMUM)
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    src/Application.vala
    src/DocumentTab.vala
    src/MainWindow.vala
PACKAGES
    gtksourceview-3.0
    gtk+-3.0
    granite)
add_executable(${EXEC_NAME} ${VALA_C})
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.rsaprun.code.desktop DESTINATION ${DATADIR}/applications/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.rsaprun.code.appdata.xml DESTINATION ${DATADIR}/metainfo/)

