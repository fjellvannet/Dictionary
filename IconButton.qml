import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

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
    ColorOverlay {
        id: olColor
        anchors.fill: icon
        source: icon
        color: Material.accent
    }
    ColorOverlay {
        anchors.fill: icon
        source: olColor
        color: "black"
        opacity: 0.15
        visible: parent.visualFocus
    }
}
