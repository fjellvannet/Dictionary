import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Effects

Button {
    contentItem: AdaptedText{
        text: "  " + parent.text + "  "
        horizontalAlignment: Qt.AlignHCenter
    }
    background: Item{}
    Rectangle{
        id: bg
        anchors.fill: parent
        color: Material.accent
        radius: parent.padding
    }
    MultiEffect {
        anchors.fill: bg
        source: bg
        colorizationColor: "black"
        colorization: 0.15
        visible: parent.visualFocus
    }
    padding: mg
}
