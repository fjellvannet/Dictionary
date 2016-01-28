TEMPLATE = app

QT += qml quick widgets svg

SOURCES += main.cpp \
    vocabularymodel.cpp \
    vocabularylistmodel.cpp \
    dictionarymodel.cpp

HEADERS += \
    vocabularymodel.h \
    vocabularylistmodel.h \
    dictionarymodel.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

CONFIG+=qml_debug
