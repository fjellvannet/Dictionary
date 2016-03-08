TEMPLATE = app

QT += qml quick widgets svg

SOURCES += main.cpp \
    vocabularymodel.cpp \
    vocabularylistmodel.cpp \
    dictionarymodel.cpp \

lupdate_only{
    SOURCES += \
        AppWindow.qml \
        HomeScreenButton.qml \
        ResultRow.qml
}

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

TRANSLATIONS += \
    translations\IWSS_Waddensea_Dictionary_da.ts \
    translations\IWSS_Waddensea_Dictionary_de.ts \
    translations\IWSS_Waddensea_Dictionary_nl.ts

DISTFILES += \
    translations/IWSS_Waddensea_Dictionary_da.ts \
    translations/IWSS_Waddensea_Dictionary_de.ts \
    translations/IWSS_Waddensea_Dictionary_nl.ts

win32 {
    DISTFILES += \
        icon\app_icon.ico

    RC_ICONS = icon\app_icon.ico
}

!android{
    TARGET = "IWSS Waddensea Dictionary"
}

android {
    DISTFILES += \
        android/AndroidManifest.xml \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradlew \
        android/res/values/libs.xml \
        android/res/values/strings.xml \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew.bat \
        android/res/drawable-hdpi/app_icon.png \
        android/res/drawable-ldpi/app_icon.png \
        android/res/drawable-mdpi/app_icon.png \
        android/res/drawable-tvdpi/app_icon.png \
        android/res/drawable-xhdpi/app_icon.png \
        android/res/drawable-xxhdpi/app_icon.png \
        android/res/drawable-xxxhdpi/app_icon.png \
        android/res/values-da/strings.xml \
        android/res/values-de/strings.xml \
        android/res/values-nl/strings.xml

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}
