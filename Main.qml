import QtQuick 2.11
import QtQuick.Window 2.4
import QtQuick.Layouts 1.11

StackLayout {
    height: childrenRect.height
    width: childrenRect.width
    Loader {
        id: splashLoader
        sourceComponent: Splash{}
    }
    Loader{
        id: mainLoader
        objectName: "mainLoader"
        sourceComponent: AppWindow{}
        active: false
        asynchronous: true
        onLoaded: {splashLoader.active = false; parent.currentIndex = 1}
    }
}
