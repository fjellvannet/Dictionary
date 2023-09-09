cmake_minimum_required(VERSION 3.24)

add_compile_definitions(WADDEN_SEA_DICTIONARY=1)
set(WADDEN_SEA_DICTIONARY 1)
project(Dictionary VERSION 1.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

if(ANDROID OR WINDOWS_PHONE OR IOS)
    add_compile_definitions(MOBILE)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Core QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(${PROJECT_NAME}
    MACOSX_BUNDLE
    Common/src/main.cpp
    Common/src/myqquickview.cpp
    Common/include/myqquickview.h

)

target_include_directories(${PROJECT_NAME} PUBLIC
    Common/include
)

qt_add_qml_module(${PROJECT_NAME}
    URI Dictionary
    VERSION ${CMAKE_PROJECT_VERSION}
    QML_FILES
        Common/qml/AppWindow.qml
        Common/qml/AdaptedImage.qml
        Common/qml/AdaptedScrollBar.qml
        Common/qml/AdaptedSwitch.qml
        Common/qml/AdaptedText.qml
        Common/qml/IconButton.qml
        Common/qml/TextButton.qml
    SOURCES
        Common/src/main.cpp
        Common/src/myqquickview.cpp
        Common/include/myqquickview.h
    RESOURCES
        Common/images/icons/alphabetic.svg
        Common/images/icons/arrow.svg
        Common/images/icons/cross_searchfield.svg
        Common/images/icons/magnifying_glass.svg
        Common/images/icons/settings.svg
        LICENSE.md
        README.md

)

if(${WADDEN_SEA_DICTIONARY} EQUAL 1) # Wadden Sea Dictionary
    set(PACKAGE no.fjellvannet.wadden_sea_dictionary)

    add_compile_definitions(WADDEN_SEA_DICTIONARY)


    target_include_directories(${PROJECT_NAME} PUBLIC
        WaddenSeaDictionary/include
    )
    target_sources(${PROJECT_NAME} PUBLIC
        WaddenSeaDictionary/include/dictionarymodel.h
        WaddenSeaDictionary/include/vocabularylistmodel.h
        WaddenSeaDictionary/include/vocabularymodel.h
        WaddenSeaDictionary/src/dictionarymodel.cpp
        WaddenSeaDictionary/src/vocabularylistmodel.cpp
        WaddenSeaDictionary/src/vocabularymodel.cpp
    )
    set_source_files_properties(WaddenSeaDictionary/qml/Constants.qml PROPERTIES QT_RESOURCE_ALIAS Dictionary/Common/qml/Constants.qml)
    set_source_files_properties(WaddenSeaDictionary/qml/DictionaryRow.qml PROPERTIES QT_RESOURCE_ALIAS Dictionary/Common/qml/DictionaryRow.qml)
    set_source_files_properties(WaddenSeaDictionary/qml/FlagImage.qml PROPERTIES QT_RESOURCE_ALIAS Dictionary/Common/qml/FlagImage.qml)
    set_source_files_properties(WaddenSeaDictionary/qml/ResultRow.qml PROPERTIES QT_RESOURCE_ALIAS Dictionary/Common/qml/ResultRow.qml)
    set_source_files_properties(WaddenSeaDictionary/qml/ResultView.qml PROPERTIES QT_RESOURCE_ALIAS Dictionary/Common/qml/ResultView.qml)
    set_source_files_properties(WaddenSeaDictionary/qml/WordDelegateText.qml PROPERTIES QT_RESOURCE_ALIAS Dictionary/Common/qml/WordDelegateText.qml)
    set_source_files_properties(WaddenSeaDictionary/images/background/background.jpg PROPERTIES QT_RESOURCE_ALIAS Dictionary/Common/images/background/background.jpg)

    qt_target_qml_sources(
        ${PROJECT_NAME}
        QML_FILES
            WaddenSeaDictionary/qml/Constants.qml
            WaddenSeaDictionary/qml/DictionaryRow.qml
            WaddenSeaDictionary/qml/FlagImage.qml
            WaddenSeaDictionary/qml/ResultRow.qml
            WaddenSeaDictionary/qml/ResultView.qml
            WaddenSeaDictionary/qml/WordDelegateText.qml
        RESOURCES
            WaddenSeaDictionary/images/background/background.jpg
            WaddenSeaDictionary/images/flags/danish_flag.svg
            WaddenSeaDictionary/images/flags/german_flag.svg
            WaddenSeaDictionary/images/flags/netherlands_flag.svg
            WaddenSeaDictionary/images/flags/union_jack.svg
            WaddenSeaDictionary/images/icons/app_icon.svg
            WaddenSeaDictionary/txt/Wadden_Sea_vocabulary.csv
        PREFIX /qt/qml/
    )
    if(ANDROID)
        set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "WaddenSeaDictionary")
    elseif(APPLE AND NOT IOS)
        set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "Wadden Sea Dictionary")
    else()
        set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "Wadden Sea Dictionary")
    endif()

    # macOS

    if(APPLE AND NOT IOS)
        set(MACOSX_BUNDLE_ICON_FILE app_icon.icns)
        set(app_icon_macos "${CMAKE_CURRENT_SOURCE_DIR}/WaddenSeaDictionary/macos/${MACOSX_BUNDLE_ICON_FILE}")
        set_source_files_properties(${app_icon_macos} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
        set_source_files_properties(LICENSE.md PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
        set_source_files_properties(README.md PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
        target_sources(${PROJECT_NAME} PUBLIC ${app_icon_macos} LICENSE.md README.md)
    endif()

    # Android
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/WaddenSeaDictionary/android)
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_VERSION_NAME ${CMAKE_PROJECT_VERSION})
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_VERSION_NUMBER 1)

    # iOS
    #set(QT_IOS_LAUNCH_SCREEN )
else() # Buchmål
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
