TEMPLATE = app

QT += core qml quick widgets svg
CONFIG += qml_debug c++11

SOURCES += main.cpp \
    vocabularymodel.cpp \
    vocabularylistmodel.cpp \
    dictionarymodel.cpp

lupdate_only{
    SOURCES += \
        AppWindow.qml
}

HEADERS += \
    vocabularymodel.h \
    vocabularylistmodel.h \
    dictionarymodel.h

RESOURCES += qml.qrc \
    images.qrc \
    ressources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

TRANSLATIONS += \
    translations\IWSS_Waddensea_Dictionary_da.ts \
    translations\IWSS_Waddensea_Dictionary_de.ts \
    translations\IWSS_Waddensea_Dictionary_nl.ts

DISTFILES += \
    translations/IWSS_Waddensea_Dictionary_da.ts \
    translations/IWSS_Waddensea_Dictionary_de.ts \
    translations/IWSS_Waddensea_Dictionary_nl.ts

windows {
    DISTFILES += \
        icon/app_icon.ico \
        icon/IWSS_Waddensea_Dictionary.rc

    RC_FILE = icon\IWSS_Waddensea_Dictionary.rc
}

windows || osx {
    TARGET = "IWSS Waddensea Dictionary"
}

osx {
    DISTFILES += icon/app_icon.icns
    ICON = icon/app_icon.icns
}

ios {
    RESOURCES -= images.qrc
    RESOURCES += images_ios.qrc

    DISTFILES += \
        ios/translations/HowToInXCode.rtf \
        ios/translations/Info.plist \
        ios/translations/da.lproj/InfoPlist.strings \
        ios/translations/de.lproj/InfoPlist.strings \
        ios/translations/en.lproj/File.strings \
        ios/translations/en.lproj/InfoPlist.strings \
        ios/translations/nl.lproj/InfoPlist.strings \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Contents.json \
        ios/icon/app_icon.xcassets/Contents.json \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-50.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-50@2x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-57.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-57@2x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-60@2x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-60@3x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-72.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-72@2x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-76.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-76@2x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-83.5@2x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-1.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-40.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-40@2x-1.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-40@2x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-40@3x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small@2x-1.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small@2x.png \
        ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small@3x.png

    assets_catalogs.files = $$files($$PWD/ios/icon/*.xcassets)
    QMAKE_BUNDLE_DATA += assets_catalogs
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
