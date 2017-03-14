import QtQuick 2.0

Item {
    Loader{
        id: mainLoader
        objectName: "mainLoader"
        //source: "qrc:/qml/AppWindow.qml"
        //active: false
        asynchronous: true
        onLoaded: splashLoader.source = ""
    }

    Loader {
        id: splashLoader
        source: "qrc:/qml/Splash.qml"
        asynchronous: true
        onLoaded: mainLoader.source = "qrc:/qml/AppWindow.qml"
    }
}
