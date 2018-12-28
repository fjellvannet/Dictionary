import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtGraphicalEffects 1.0

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
