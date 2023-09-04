cmake_minimum_required(VERSION 3.24)

add_compile_definitions(WADDEN_SEA_DICTIONARY=1)
set(WADDEN_SEA_DICTIONARY 1)
project(Dictionary VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Core QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

#qt_add_executable(appDictionary
#    Common/src/main.cpp
#    Common/src/myqquickview.cpp
#    Common/include/myqquickview.h
#)

#include_directories(Common/include)

#qt_add_qml_module(appDictionary
#    URI Dictionary
#    VERSION 1.0
#    QML_FILES
#        Common/qml/AppWindow.qml
#        Common/qml/AdaptedImage.qml
#        Common/qml/AdaptedScrollBar.qml
#        Common/qml/AdaptedSwitch.qml
#        Common/qml/AdaptedText.qml
#        Common/qml/IconButton.qml
#        Common/qml/TextButton.qml
#    SOURCES
#        Common/src/main.cpp
#        Common/src/myqquickview.cpp
#        Common/include/myqquickview.h
#    RESOURCES
#        Common/images/icons/alphabetic.svg
#        Common/images/icons/arrow.svg
#        Common/images/icons/cross_searchfield.svg
#        Common/images/icons/magnifying_glass.svg
#        Common/images/icons/settings.svg
#    RESOURCE_PREFIX /
#)

add_subdirectory(Common)


#qt_add_executable(appDictionary
#    common/src/main.cpp
#)


#add_subdirectory(Common)
#qt_add_qml_module(appDictionary
#    URI Dictionary
#    VERSION 1.0
#    QML_FILES common/qml/Main.qml
#)


#qt_target_qml_sources(appDictionary
#    QML_FILES common/qml/Main.qml
#)
#target_sources(appDictionary PUBLIC
#    WaddenSeaDictionary/WaddenSeaDictionary.qrc
#)
if(${WADDEN_SEA_DICTIONARY} EQUAL 1)
    add_compile_definitions(WADDEN_SEA_DICTIONARY)
    add_subdirectory(WaddenSeaDictionary)
    target_link_libraries(appDictionary PUBLIC DictLib)
    #    WaddenSeaDictionary/include/dictionarymodel.h
    #    WaddenSeaDictionary/include/vocabularylistmodel.h
    #    WaddenSeaDictionary/include/vocabularymodel.h
    #    WaddenSeaDictionary/src/dictionarymodel.cpp
    #    WaddenSeaDictionary/src/vocabularylistmodel.cpp
    #    WaddenSeaDictionary/src/vocabularymodel.cpp
    #)
    #include_directories(WaddenSeaDictionary/Dict/include)
    target_sources(appDictionary PUBLIC
        WaddenSeaDictionary/WaddenSeaDictionary.qrc
    )
    target_include_directories(appDictionary PUBLIC
        WaddenSeaDictionary/include
    )
    #qt_target_qml_sources(
    #    appDictionary
    #    QML_FILES wadden_sea_dictionary/qml/AdaptedText.qml
    #)
else()
    add_subdirectory(buchmaal)
endif()




# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appDictionary PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appDictionary
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appDictionary
    PRIVATE Qt6::Quick Qt6::Core Qt6::Qml Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appDictionary
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
