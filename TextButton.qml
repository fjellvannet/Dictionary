import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
Button {
    contentItem: AdaptedText{
        text: " " + parent.text + " "
    }
    background: Rectangle{
        color: Material.accent
        radius: parent.padding
    }
    ColorOverlay {
        anchors.fill: parent.background
        source: parent.background
        color: "black"
        opacity: 0.15
        visible: parent.visualFocus
    }
    padding: globalMargin/2
}
