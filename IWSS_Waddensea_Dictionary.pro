TEMPLATE = app

QT += qml quick widgets svg

SOURCES += main.cpp \
    vocabularymodel.cpp

HEADERS += \
    vocabularymodel.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    ../../../../OneDrive/svg für App/Flaggen/5;3/Alle Sprachen.svg \
    ../../../../OneDrive/svg für App/Flaggen/5;3/Dannebrog 5;3.svg \
    ../../../../OneDrive/svg für App/Flaggen/5;3/Deutsche Flagge.svg \
    ../../../../OneDrive/svg für App/Flaggen/5;3/Niederländische Flagge 5;3.svg \
    ../../../../OneDrive/svg für App/Flaggen/5;3/Union Jack 5;3 ohne Überschneidung vom Rand.svg

