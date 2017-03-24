import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3

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
