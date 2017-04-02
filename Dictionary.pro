TEMPLATE = app

QT += core qml quick widgets svg quickcontrols2
CONFIG += qml_debug c++11
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

RESOURCES += qml.qrc \
    images.qrc \
    translations.qrc

TRANSLATIONS += \
    translations/Dictionary_da.ts \
    translations/Dictionary_de.ts \
    translations/Dictionary_nl.ts

DISTFILES += \
    LICENSE.txt \
    README.md \
    translations/Dictionary_da.ts \
    translations/Dictionary_de.ts \
    translations/Dictionary_nl.ts \ 

# Default rules for deployment.
include(deployment.pri)

VER_MAJ = 1 #endre også versjonen i Android.manifest!
VER_MIN = 0
VER_PAT = 2
VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT

WADDEN_SEA_DICTIONARY=1#1 heißt Wadden Sea Dictionary wird kompiliert, 0 kompiliert Deutsch-Norwegisch-Wörterbuch
DEFINES += WADDEN_SEA_DICTIONARY=$$WADDEN_SEA_DICTIONARY \
    VERSION_STR=$$VERSION \
    VERSION_NR=$$VER_MAJ,$$VER_MIN,$$VER_PAT

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

        assets_catalogs.files = $$files($$PWD/wadden_sea_dictionary/ios/icon/*.xcassets)
        app_launch_images.files = $$PWD/wadden_sea_dictionary/ios/LaunchScreen.xib $$PWD/ios/images/app_icon.png
        QMAKE_BUNDLE_DATA += assets_catalogs \
            app_launch_images
    }

    android {
        DISTFILES += \
            wadden_sea_dictionary/android/AndroidManifest.xml \
            wadden_sea_dictionary/android/gradle/wrapper/gradle-wrapper.jar \
            wadden_sea_dictionary/android/gradlew \
            wadden_sea_dictionary/android/res/values/libs.xml \
            wadden_sea_dictionary/android/res/values/strings.xml \
            wadden_sea_dictionary/android/build.gradle \
            wadden_sea_dictionary/android/gradle/wrapper/gradle-wrapper.properties \
            wadden_sea_dictionary/android/gradlew.bat \
            wadden_sea_dictionary/android/res/drawable-hdpi/app_icon.png \
            wadden_sea_dictionary/android/res/drawable-ldpi/app_icon.png \
            wadden_sea_dictionary/android/res/drawable-mdpi/app_icon.png \
            wadden_sea_dictionary/android/res/drawable-tvdpi/app_icon.png \
            wadden_sea_dictionary/android/res/drawable-xhdpi/app_icon.png \
            wadden_sea_dictionary/android/res/drawable-xxhdpi/app_icon.png \
            wadden_sea_dictionary/android/res/drawable-xxxhdpi/app_icon.png \
            wadden_sea_dictionary/android/res/values-da/strings.xml \
            wadden_sea_dictionary/android/res/values-de/strings.xml \
            wadden_sea_dictionary/android/res/values-nl/strings.xml

        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/wadden_sea_dictionary/android
    }
}
else {#Deutsch-bokmål-nynorsk ordbok

}


