import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Effects

Button {
    /*contentItem: AdaptedText{
        text: parent.text
        horizontalAlignment: Qt.AlignHCenter
        padding: 0
        Rectangle {
            anchors.fill: parent
            color: "red"
        }
    }*/
    font.pixelSize: globalFontPixelSize
    background: Rectangle{
        id: bg
        color: Material.accent
        radius: 0.75 * mg
    }
    MultiEffect {
        anchors.fill: bg
        source: bg
        colorizationColor: "black"
        colorization: 0.15
        visible: parent.visualFocus
    }
    leftPadding: 0.75 * em
    rightPadding: 0.75 * em
    topPadding: 0.75 * em
    bottomPadding: 0.75 * em
}
