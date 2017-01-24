import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

ScrollBar {
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    property double barwidth: 2 * globalMargin
    visible: size < 1
    contentItem: Rectangle {
        implicitWidth: barwidth
        implicitHeight: parent.background.height * parent.size
        radius: width / 2
        opacity: 0
        color: pressed ? Material.color(Material.Grey, Material.Shade700) : Material.color(Material.Grey)
        states: State {
            name: "active"
            when: active
            PropertyChanges { target: contentItem; opacity: 1 }
        }
        transitions: Transition {
            from: "active"
            to: ""
            animations: SequentialAnimation {
                PauseAnimation { duration: 2000 }
                NumberAnimation { target: contentItem; properties: "opacity"; duration: 1000}
            }
        }
    }
    states: State {
        when: orientation === Qt.Horizontal
        PropertyChanges {
            target: contentItem
            implicitWidth: parent.width * size
            implicitHeight: barwidth
        }
    }
}
