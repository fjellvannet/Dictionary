import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Effects

Button {
    property string source

    background: Item{}
    AdaptedImage {
        id: icon
        anchors.centerIn: parent
        height: parent.parent.height / 1.35
        width: height
        source: parent.source
    }
    MultiEffect {
        id: olColor
        anchors.fill: icon
        source: icon
        colorizationColor: Material.accent
        colorization: 1
    }
    MultiEffect {
        anchors.fill: icon
        source: olColor
        colorizationColor: "black"
        colorization: 0.15
        visible: parent.visualFocus
    }
}
