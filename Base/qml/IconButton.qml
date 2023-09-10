import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Effects

Button {
    property string src
    padding: mg

    background: AdaptedImage {
        //id: icon
        //anchors.centerIn: parent
        //height: parent.parent.height / 1.35
        //width: height
        source: src
        fillMode: Image.PreserveAspectFit
    }
    MultiEffect {
        id: olColor
        anchors.fill: parent.background
        source: parent.background
        colorizationColor: Material.accent
        colorization: 1
    }
    MultiEffect {
        anchors.fill: parent.background
        source: olColor
        colorizationColor: "black"
        colorization: tabColorIntensity
        visible: parent.visualFocus
    }
}
