cmake_minimum_required(VERSION 3.24)

set(WADDEN_SEA_DICTIONARY 1)
if(WADDEN_SEA_DICTIONARY)
    set(PROJECT WaddenSeaDictionary)
else()
    set(PROJECT Buchmaal)
endif()

project(${PROJECT} VERSION 1.1.0 LANGUAGES CXX)
message("${PROJECT_NAME} ${CMAKE_PROJECT_VERSION}")

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

if(ANDROID OR WINDOWS_PHONE OR IOS)
    add_compile_definitions(MOBILE)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Core QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

set(BASE_DIR Base)
set(BASE_URI Dictionary)

macro(addHeadersAndSources DIR)
    file(GLOB FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${DIR}/include/*.h")
    list(APPEND HEADERS ${FILES})
    file(GLOB FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${DIR}/src/*.cpp")
    list(APPEND SOURCES ${FILES})
    include_directories(${DIR}/include)
endmacro()

macro(addResources)
    cmake_parse_arguments(RSC "" DIR RESOURCE_DIRS ${ARGN})

    file(GLOB RSC_QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${RSC_DIR}/qml/*.qml")
    list(APPEND QML_FILES ${RSC_QML_FILES})

    foreach(DIR_EXTENSIONS IN ITEMS ${RSC_RESOURCE_DIRS})
        separate_arguments(EXTENSIONS UNIX_COMMAND ${DIR_EXTENSIONS})
        list(POP_FRONT EXTENSIONS DIR)
        foreach(EXTENSION IN LISTS EXTENSIONS)
            file(GLOB_RECURSE FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${RSC_DIR}/${_DIR}/${EXTENSION}")
            list(APPEND RESOURCES ${FILES})
            list(APPEND RSC_RESOURCES ${FILES})
        endforeach()
    endforeach()

    foreach(FILE IN ITEMS ${RSC_QML_FILES} ${RSC_RESOURCES})
        file(RELATIVE_PATH FILE_NAME ${CMAKE_SOURCE_DIR}/${RSC_DIR} ${CMAKE_SOURCE_DIR}/${FILE})
        set_source_files_properties(${FILE} PROPERTIES QT_RESOURCE_ALIAS ${FILE_NAME})
    endforeach()
    unset(RSC_QML_FILES)
    unset(RSC_RESOURCES)
endmacro()

addHeadersAndSources(${BASE_DIR})
addHeadersAndSources(${PROJECT_NAME})

qt_add_executable(${PROJECT_NAME} ${HEADERS} ${SOURCES})

list(APPEND RESOURCES LICENSE.md README.md)
addResources(DIR ${BASE_DIR} RESOURCE_DIRS "images *.svg *.jpg")
addResources(DIR ${PROJECT_NAME} RESOURCE_DIRS "images *.svg *.jpg" "txt *.csv")

qt_add_qml_module(${PROJECT_NAME}
    URI ${BASE_URI}
    VERSION ${CMAKE_PROJECT_VERSION}
    QML_FILES ${QML_FILES}
    SOURCES ${SOURCES}
    RESOURCES ${RESOURCES}
    PREFIX /qt/qml
)

foreach(VAR IN ITEMS HEADERS SOURCES QML_FILES RESOURCES)
    message("\n${VAR}")
    foreach(FILE IN LISTS ${VAR})
        message("    ${FILE}")
    endforeach()
endforeach()

if(${WADDEN_SEA_DICTIONARY} EQUAL 1) # Wadden Sea Dictionary
    add_compile_definitions(WADDEN_SEA_DICTIONARY)
    set(PACKAGE no.fjellvannet.wadden_sea_dictionary)

    if(ANDROID)
        set(ANDROID_VERSION_NUMBER 1)
    endif()

    # iOS
    if(IOS)
        file(GLOB_RECURSE app_icons CONFIGURE_DEPENDS "${PLUGIN_DIR}/ios/AppIcon*.png")
        if(IOS AND app_icons)
            target_sources(app PRIVATE ${app_icons})
            set_source_files_properties(
                ${app_icons}
                PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
        endif()
        qt_target_qml_sources(
            ${PROJECT_NAME}
            RESOURCES
                ${PLUGIN_DIR}/ios/app_icon.png
            PREFIX /qt/qml
        )
        set(asset_catalog_path "${PLUGIN_DIR}/ios/app_icon.xcassets")
        target_sources(${PROJECT_NAME} PRIVATE "${asset_catalog_path}")
        set_source_files_properties(
            ${asset_catalog_path}
            PROPERTIES MACOSX_PACKAGE_LOCATION Resources
        )
        set_target_properties(${PROJECT_NAME} PROPERTIES QT_IOS_LAUNCH_SCREEN "${PLUGIN_DIR}/ios/Launch.storyboard")
    endif()

else() # Buchmål
    set(PACKAGE no.fjellvannet.buchmaal)
endif()

# macOS
if(APPLE AND NOT IOS)
    set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "Wadden Sea Dictionary")
    set(MACOSX_BUNDLE_ICON_FILE app_icon.icns)
    set(APP_ICON_MACOS "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}/macos/${MACOSX_BUNDLE_ICON_FILE}")
    set_source_files_properties(
        ${APP_ICON_MACOS}
        LICENSE.md
        README.md
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )
    target_sources(${PROJECT_NAME} PUBLIC ${APP_ICON_MACOS} LICENSE.md README.md)
endif()

# Android
if(ANDROID)
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}/android)
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_VERSION_NAME ${CMAKE_PROJECT_VERSION})
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_VERSION_NUMBER ${ANDROID_VERSION_NUMBER})
endif()

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_GUI_IDENTIFIER ${PACKAGE})
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt6::Quick Qt6::Core Qt6::Qml Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
