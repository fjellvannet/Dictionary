import QtQuick
import QtQuick.Controls

ProgressBar {
    property string text
    id: pb
    background.height: pb.height
    contentItem.implicitHeight: pb.height

    AdaptedText {
        id: txt
        z: pb.z + 1
        anchors.verticalCenter: pb.verticalCenter
        anchors.leftMargin: mg
        anchors.left: pb.left
        text: pb.text
        textFormat: Text.RichText
    }
}
