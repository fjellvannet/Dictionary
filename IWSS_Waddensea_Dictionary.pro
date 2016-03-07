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

win32 {
    RC_ICONS = app_icon.ico
}

android {
DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

DISTFILES += \
    android/res/icon/app_icon.svg \
    android/res/drawable-hdpi/app_icon.png \
    android/res/drawable-ldpi/app_icon.png \
    android/res/drawable-mdpi/app_icon.png \
    android/res/drawable-tvdpi/app_icon.png \
    android/res/drawable-xhdpi/app_icon.png \
    android/res/drawable-xxhdpi/app_icon.png \
    android/res/drawable-xxxhdpi/app_icon.png
