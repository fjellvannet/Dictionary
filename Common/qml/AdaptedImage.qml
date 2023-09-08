import QtQuick
import QtQuick.Window

Image {
    property bool ios: false
    sourceSize.height: height * Screen.devicePixelRatio
    sourceSize.width: width * Screen.devicePixelRatio
    smooth: true
    asynchronous: true
}
