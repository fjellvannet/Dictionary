import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Button {
    property string source

    background: AdaptedImage {
        anchors.centerIn: parent
        height: parent.parent.height / 1.35
        width: height
        source: parent.source
    }
    ColorOverlay {
        id: olColor
        anchors.fill: parent.background
        source: parent.background
        color: Material.accent
    }
    ColorOverlay {
        anchors.fill: parent.background
        source: olColor
        color: "black"
        opacity: 0.15
        visible: parent.activeFocus
    }
}
