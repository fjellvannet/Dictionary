qt_add_executable(appDictionary
    src/main.cpp
    src/myqquickview.cpp
    include/myqquickview.h

    #Common.qrc
    #../WaddenSeaDictionary/WaddenSeaDictionary.qrc
)

include_directories(include)

qt_add_qml_module(appDictionary
    URI Dictionary
    VERSION 1.0
    QML_FILES
        qml/AppWindow.qml
        qml/AdaptedImage.qml
        qml/AdaptedScrollBar.qml
        qml/AdaptedSwitch.qml
        qml/AdaptedText.qml
        qml/IconButton.qml
        qml/TextButton.qml
    SOURCES
        src/main.cpp
        src/myqquickview.cpp
        include/myqquickview.h
    RESOURCES
        images/icons/alphabetic.svg
        images/icons/arrow.svg
        images/icons/cross_searchfield.svg
        images/icons/magnifying_glass.svg
        images/icons/settings.svg
        ../LICENSE.md
    RESOURCE_PREFIX /
)

#qt_add_resources(appDirectory goddag
#    FILES ../LICENSE.md
#    #PREFIX "/"
#)

