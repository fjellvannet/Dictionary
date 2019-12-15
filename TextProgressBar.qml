import QtQuick 2.13
import QtQuick.Controls 2.13

ProgressBar {
    property string text
    id: pb
    background.height: pb.height
    contentItem.implicitHeight: pb.height

    AdaptedText {
        id: txt
        z: pb.z + 1
        anchors.verticalCenter: pb.verticalCenter
        anchors.leftMargin: globalMargin
        anchors.left: pb.left
        text: pb.text
    }
}
