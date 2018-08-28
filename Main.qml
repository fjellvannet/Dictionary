import QtQuick 2.11
import QtQuick.Window 2.4
import QtQuick.Layouts 1.11

StackLayout {
    height: childrenRect.height//splashLoader.active ? splashLoader.height : Screen.height
    width: childrenRect.width//splashLoader.active ? splashLoader.width : Screen.width
    Loader {
        id: splashLoader
        source: "qrc:/qml/Splash.qml"
    }
    Loader{
        id: mainLoader
        objectName: "mainLoader"
        source: "qrc:/qml/AppWindow.qml"
        active: false
        asynchronous: true
        onLoaded: {splashLoader.active = false; parent.currentIndex = 1}
    }
}
