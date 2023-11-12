cmake_minimum_required(VERSION 3.24)

set(WADDEN_SEA_DICTIONARY 1)
if(WADDEN_SEA_DICTIONARY)
    set(PROJECT WaddenSeaDictionary)
    set(PACKAGE no.fjellvannet.wadden_sea_dictionary)
    add_compile_definitions(WADDEN_SEA_DICTIONARY)
else()
    set(PROJECT Buchmaal)
    set(PACKAGE no.fjellvannet.buchmaal)
endif()

project(${PROJECT} LANGUAGES CXX VERSION 1.0.0)
message("${PROJECT_NAME} ${CMAKE_PROJECT_VERSION}")

set(QT_VERSION 6.6)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

if(ANDROID OR WINDOWS_PHONE OR IOS)
    add_compile_definitions(MOBILE)
endif()

find_package(Qt6 ${QT_VERSION} REQUIRED COMPONENTS Quick Core QuickControls2 LinguistTools)

qt_standard_project_setup(REQUIRES ${QT_VERSION})

set(BASE_DIR Base)
set(BASE_URI Dictionary)
set(DICT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}")

macro(addHeadersAndSources DIR)
    file(GLOB FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${DIR}/include/*.h")
    list(APPEND HEADERS ${FILES})
    file(GLOB FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${DIR}/src/*.cpp")
    list(APPEND SOURCES ${FILES})
    include_directories(${DIR}/include)
endmacro()

macro(addResources)
    cmake_parse_arguments(RSC "" DIR RESOURCE_DIRS ${ARGN})


    file(GLOB RSC_QML RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${RSC_DIR}/qml/*.qml")
    list(APPEND QML_FILES ${RSC_QML})

    foreach(DIR_EXTENSIONS IN ITEMS ${RSC_RESOURCE_DIRS})
        separate_arguments(EXTENSIONS UNIX_COMMAND ${DIR_EXTENSIONS})
        list(POP_FRONT EXTENSIONS DIR)
        foreach(EXTENSION IN LISTS EXTENSIONS)
            file(GLOB_RECURSE FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${RSC_DIR}/${_DIR}/${EXTENSION}")
            list(APPEND RESOURCES ${FILES})
            list(APPEND RSC_RESOURCES ${FILES})
        endforeach()
    endforeach()

    file(GLOB RSC_TS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "${RSC_DIR}/translations/*.ts")
    list(APPEND TS_FILES ${RSC_TS})



    foreach(VAR IN ITEMS RSC_RESOURCES RSC_QML RSC_TS)
        foreach(FILE IN LISTS ${VAR})
            file(RELATIVE_PATH FILE_NAME ${CMAKE_SOURCE_DIR}/${RSC_DIR} ${CMAKE_SOURCE_DIR}/${FILE})
            message("${FILE} ${FILE_NAME}")
            set_source_files_properties(${FILE} PROPERTIES QT_RESOURCE_ALIAS ${FILE_NAME})
        endforeach()
        unset(${VAR})
    endforeach()
endmacro()

addHeadersAndSources(${BASE_DIR})
addHeadersAndSources(${PROJECT_NAME})

qt_add_executable(${PROJECT_NAME} ${HEADERS} ${SOURCES})

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

list(APPEND RESOURCES LICENSE.md README.md)
addResources(DIR ${BASE_DIR} RESOURCE_DIRS "images *.svg *.jpg")
addResources(DIR ${PROJECT_NAME} RESOURCE_DIRS "images *.svg *.jpg" "txt *.csv")

qt_add_qml_module(${PROJECT_NAME}
    URI ${BASE_URI}
    VERSION ${CMAKE_PROJECT_VERSION}
    QML_FILES ${QML_FILES}
    SOURCES ${SOURCES}
    RESOURCES ${RESOURCES}
    PREFIX /qt/qml
)

qt_add_translations(${PROJECT_NAME} TS_FILES ${TS_FILES})

foreach(VAR IN ITEMS HEADERS SOURCES QML_FILES RESOURCES TS_FILES)
    message("\n${VAR}")
    foreach(FILE IN LISTS ${VAR})
        message("    ${FILE}")
    endforeach()
endforeach()

if(APPLE)
    list(APPEND APPLE_RESOURCES LICENSE.md README.md)
    if(IOS)
        enable_language(OBJCXX)
        #set_target_properties(${PROJECT_NAME} PROPERTIES )
        set_target_properties(${PROJECT_NAME} PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST "${DICT_DIR}/ios/Info.plist"
        )

        # Custom resources
        #file(GLOB_RECURSE text_files CONFIGURE_DEPENDS "*.txt")
        if(0) #text_files)
            list(FILTER text_files EXCLUDE REGEX CMakeLists.txt)
            target_sources(tst_manual_ios_assets PRIVATE ${text_files})
            # On iOS the 'Resources' prefix is removed by Xcode because on iOS app bundles are shallow,
            # so the final location of the text file will be
            #    tst_manual_ios_assets.app/textFiles/foo.txt
            # On macOS the location will be
            #    tst_manual_ios_assets.app/Contents/Resources/textFiles/foo.txt
            set_source_files_properties(
                ${text_files}
                PROPERTIES MACOSX_PACKAGE_LOCATION Resources/textFiles)
        endif()

        # App icons
        # https://developer.apple.com/library/archive/qa/qa1686/_index.html
        # https://help.apple.com/xcode/mac/current/#/dev10510b1f7
        # https://web.archive.org/web/20180124234409/https://developer.apple.com/ios/human-interface-guidelines/icons-and-images/app-icon/
        # https://doc.qt.io/qt-6/ios-platform-notes.html#icons
        # No need to copy the icons into the bundle manually when using Xcode 13+.
        # - rely on Xcode 13 to copy the needed icon files that are specified in the asset catalog (all the
        #   required ones should be specified manually)
        # - rely on Xcode 14 to generate the needed icon files based on the 1024x1024 sized image in the
        #   asset catalog

        # Asset catalog with images and icons.
        if(0)
            if(XCODE_VERSION AND XCODE_VERSION VERSION_LESS "14")
                set(asset_catalog_path "${CMAKE_CURRENT_SOURCE_DIR}/AssetsXcode13.0.xcassets")
            else()
                set(asset_catalog_path "${CMAKE_CURRENT_SOURCE_DIR}/AssetsXcode14.3.xcassets")
            endif()
            target_sources(tst_manual_ios_assets PRIVATE "${asset_catalog_path}")
            set_source_files_properties(
                ${asset_catalog_path}
                PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

            # Make sure asset catalog compilation generates the needed app icons image sizes.
            # This might not be needed in a future Qt version where qt_add_executable might do it
            # automatically. Unclear how to do it cleanly though, because specifying the option when
            # the asset catalog doesn't have an AppIcon set will cause a build failure.
            set_target_properties(tst_manual_ios_assets PROPERTIES
                XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME AppIcon)

            target_sources(tst_manual_ios_assets PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/utils.mm")
        endif()

        # Set custom launch screen.
        # iOS has evolved and provides a few ways to handle this.
        # - UILaunchImageFile Info.plist key, introduced in iOS 3.2, supposedly deprecated in iOS 10.
        # - UILaunchImages, Info.plist keys,  introduced in iOS 7, deprecated in iOS 13
        # - UILaunchStoryboardName, Info.plist key, introduced in iOS 9, not deprecated
        # - UILaunchScreen / UILaunchScreens, Info.plist dictionaries, introduced in iOS 14, not
        #    deprecated
        # The first two expect images, the third one expects a storyboard / .xib file.
        # The last ones expect a dictionary of keys to configure the launch screen.
        # At the moment, UILaunchStoryboardName represents the lower bound of what Qt supports,
        # so use it here.
        # Reference info
        # https://developer.apple.com/documentation/xcode/specifying-your-apps-launch-screen/
        # https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/uid/TP40009252-SW24
        # https://developer.apple.com/documentation/uikit/uilocalnotification/1616660-alertlaunchimage?language=objc
        # https://developer.apple.com/documentation/bundleresources/information_property_list/uilaunchimages?language=objc
        # https://developer.apple.com/documentation/bundleresources/information_property_list/uilaunchstoryboardname?language=objc
        # https://developer.apple.com/documentation/bundleresources/information_property_list/uilaunchscreen?language=objc
        # https://forum.qt.io/topic/106251/use-launch-images-in-ios-project/4
        # https://codereview.qt-project.org/c/qt/qtdoc/+/100846
            # Because we're not using the automatically generated Info.plist, it needs to be manually
            # modified to have the UILaunchStoryboardName key.
        #target_sources(${PROJECT_NAME} PRIVATE "${DICT_DIR}/ios/AssetsXcode14.3.xcassets")
        list(APPEND APPLE_RESOURCES
            #"${DICT_DIR}/ios/AssetsXcode14.3.xcassets"
            "${DICT_DIR}/ios/app_icon.xcassets"
            "${DICT_DIR}/ios/launch_app_icon.png"
        )
        set_target_properties(${PROJECT_NAME} PROPERTIES
            #MACOSX_BUNDLE_INFO_PLIST "${DICT_DIR}/ios/Info.plist"
            #MACOSX_BUNDLE_INFO_PLIST "${DICT_DIR}/ios/Info.ios.cmake.xcode.14.3.plist"
            XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME AppIcon
            QT_IOS_LAUNCH_SCREEN "${DICT_DIR}/ios/LaunchScreen.storyboard"
        )
    else()
        set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "Wadden Sea Dictionary")
        set(MACOSX_BUNDLE_ICON_FILE app_icon.icns)
        set(APP_ICON_MACOS "${DICT_DIR}/macos/${MACOSX_BUNDLE_ICON_FILE}")
        list(APPEND APPLE_RESOURCES ${APP_ICON_MACOS})

        # Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
        # If you are developing for iOS or macOS you should consider setting an
        # explicit, fixed bundle identifier manually though.
        set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_GUI_IDENTIFIER ${PACKAGE})
    endif()

    set_source_files_properties(${APPLE_RESOURCES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    target_sources(${PROJECT_NAME} PUBLIC ${APPLE_RESOURCES})
endif()

# Android
if(ANDROID)
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${DICT_DIR}/android)
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_VERSION_NAME ${CMAKE_PROJECT_VERSION})
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_VERSION_NUMBER ${ANDROID_VERSION_NUMBER})
endif()
