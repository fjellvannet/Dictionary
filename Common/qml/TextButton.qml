import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
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
    ColorOverlay {
        anchors.fill: bg
        source: bg
        color: "black"
        opacity: 0.15
        visible: parent.visualFocus
    }
    padding: mg
}
