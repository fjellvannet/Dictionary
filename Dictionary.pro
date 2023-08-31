TEMPLATE = app
include(deployment.pri) # Default rules for deployment.

QT += core qml quick svg sql quickcontrols2 network concurrent widgets core5compat
CONFIG += qml_debug c++17
#DEFINES *= QT_USE_QSTRINGBUILDER #denne må du eventuelt ta ut dersom det blir problemer. Erstatter alle + operatorene, som henger sammen strenger,
    # med %-operatorer, forskjellen då er at det brukes stringbuildere, som forhindrer unødvendige kopieringer i minnen

#Endring av denne variablen eller versjonsnummeret krever alltid, at appen rekompileres komplett.
WADDEN_SEA_DICTIONARY=1 #1 heißt Wadden Sea Dictionary wird kompiliert, 0 kompiliert Buchmål
SPLASH=0
equals(SPLASH, 1): RESOURCES += splash.qrc
EDIT_DATABASE=0
UPDATE_DB_VERSION=0

android || ios || winrt: MOBILE=1
else : MOBILE=0

VER_MAJ = 1  # Do a complete rebuild for a version change to take effect
VER_MIN = 1
VER_PAT = 0
VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT

DEFINES += \
    WADDEN_SEA_DICTIONARY=$$WADDEN_SEA_DICTIONARY \
    APP_VERSION_STR=$$VERSION \
    APP_VERSION_NR=$$VER_MAJ,$$VER_MIN,$$VER_PAT \
    APP_DEVELOPER=fjellvannet \
    EDIT_DATABASE=$$EDIT_DATABASE \
    UPDATE_DB_VERSION=$$UPDATE_DB_VERSION \
    SPLASH=$$SPLASH \
    MOBILE=$$MOBILE

QT_QUICK_CONTROLS_STYLE=material
QT_AUTO_SCREEN_SCALE_FACTOR=1

HEADERS += \
    myqquickview.h

SOURCES += main.cpp \
    myqquickview.cpp

lupdate_only{
    SOURCES += \
        AppWindow.qml \
        wadden_sea_dictionary/Constants.qml
    RESOURCES += splash.qrc
}

RESOURCES += \
    images.qrc \
    common.qrc

TRANSLATIONS += \
    translations/Dictionary_da.ts \
    translations/Dictionary_de.ts \
    translations/Dictionary_nl.ts

DISTFILES += \
    LICENSE.txt \
    README.md

winrt {
    QT_OPENGL=software
    QT_ANGLE_PLATFORM=
}

!winrt {
    DISTFILES += \
        translations/Dictionary_da.ts \
        translations/Dictionary_de.ts \
        translations/Dictionary_nl.ts
}

windows {
    DISTFILES += \
        windows/appinfo.h\
        windows/appinfo_en.h\
        windows/appinfo_de.h\
        windows/appinfo_da.h\
        windows/appinfo_nl.h\
        windows/Dictionary.rc\
        windows/wadden_sea_dictionary_icon.ico\
        windows/Wadden_Sea_Dictionary_Windows_release.cmd

    RC_FILE = windows/Dictionary.rc
}

equals(WADDEN_SEA_DICTIONARY, 1) { #Wadden Sea Dictionary
    message("Wadden Sea Dictionary" $$VERSION)
    RESOURCES += wadden_sea_dictionary.qrc
    windows || osx {
        TARGET = "Wadden Sea Dictionary"
    }else{
        TARGET = "Wadden_Sea_Dictionary"
    }

    HEADERS += \
        wadden_sea_dictionary/vocabularymodel.h \
        wadden_sea_dictionary/vocabularylistmodel.h \
        wadden_sea_dictionary/dictionarymodel.h

    SOURCES += \
        wadden_sea_dictionary/vocabularymodel.cpp \
        wadden_sea_dictionary/vocabularylistmodel.cpp \
        wadden_sea_dictionary/dictionarymodel.cpp


    osx {
        DISTFILES += wadden_sea_dictionary/ios/icon/app_icon.icns
        ICON = wadden_sea_dictionary/ios/icon/app_icon.icns
    }

    ios {
        RESOURCES -= images.qrc
        RESOURCES += images_ios.qrc

        DISTFILES += \
            wadden_sea_dictionary/ios/LaunchScreen.xib \
            wadden_sea_dictionary/ios/translations/HowToInXCode.rtf \
            wadden_sea_dictionary/ios/translations/Info.plist \
            wadden_sea_dictionary/ios/translations/da.lproj/InfoPlist.strings \
            wadden_sea_dictionary/ios/translations/de.lproj/InfoPlist.strings \
            wadden_sea_dictionary/ios/translations/en.lproj/File.strings \
            wadden_sea_dictionary/ios/translations/en.lproj/InfoPlist.strings \
            wadden_sea_dictionary/ios/translations/nl.lproj/InfoPlist.strings \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Contents.json \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/Contents.json \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-50.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-50@2x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-57.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-57@2x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-60@2x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-60@3x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-72.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-72@2x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-76.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-76@2x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-83.5@2x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-1.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-40.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-40@2x-1.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-40@2x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small-40@3x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small@2x-1.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small@2x.png \
            wadden_sea_dictionary/ios/icon/app_icon.xcassets/AppIcon.appiconset/Icon-Small@3x.png

        #assets_catalogs.files = $$files($$PWD/wadden_sea_dictionary/ios/icon/*.xcassets)
        app_launch_images.files = $$PWD/wadden_sea_dictionary/ios/LaunchScreen.xib $$PWD/ios/images/app_icon.png
        QMAKE_BUNDLE_DATA += assets_catalogs \
            app_launch_images
        QMAKE_ASSET_CATALOGS += wadden_sea_dictionary/ios/icon/app_icon.xcassets
    }

    android {
        ANDROID_VERSION_CODE = 2
        ANDROID_VERSION_NAME = $$VERSION
        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/wadden_sea_dictionary/android

        DISTFILES += \
            wadden_sea_dictionary/android/AndroidManifest.xml \
            wadden_sea_dictionary/android/build.gradle \
            wadden_sea_dictionary/android/gradle/wrapper/gradle-wrapper.jar \
            wadden_sea_dictionary/android/gradle/wrapper/gradle-wrapper.properties \
            wadden_sea_dictionary/android/gradlew \
            wadden_sea_dictionary/android/gradlew.bat \
            wadden_sea_dictionary/android/res/values/libs.xml \
            wadden_sea_dictionary/android/res/drawable-hdpi/icon.png \
            wadden_sea_dictionary/android/res/drawable-ldpi/icon.png \
            wadden_sea_dictionary/android/res/drawable-mdpi/icon.png \
            wadden_sea_dictionary/android/res/drawable-tvdpi/icon.png \
            wadden_sea_dictionary/android/res/drawable-xhdpi/icon.png \
            wadden_sea_dictionary/android/res/drawable-xxhdpi/icon.png \
            wadden_sea_dictionary/android/res/drawable-xxxhdpi/icon.png \
            wadden_sea_dictionary/android/res/values-da/strings.xml \
            wadden_sea_dictionary/android/res/values-de/strings.xml \
            wadden_sea_dictionary/android/res/values-nl/strings.xml \
            wadden_sea_dictionary/android/res/xml/locales_config.xml
    }
}
else {#Buchmål
    message("Buchmål" $$VERSION)
    equals(EDIT_DATABASE, 0) : RESOURCES += buchmaal.qrc

    HEADERS += buchmaal/databasecreator.h \
        buchmaal/databasemanager.h \
        buchmaal/localsortkeygenerator.h \
        buchmaal/wordlistmodel.h \
        buchmaal/resultmodel.h

    SOURCES += buchmaal/databasecreator.cpp \
        buchmaal/databasemanager.cpp \
        buchmaal/localsortkeygenerator.cpp \
        buchmaal/wordlistmodel.cpp\
        buchmaal/resultmodel.cpp

    DISTFILES += buchmaal/heinzelliste.csv
}
