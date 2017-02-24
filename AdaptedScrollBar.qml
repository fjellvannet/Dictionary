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
        implicitHeight: barwidth /*das hier mag komisch aussehen - schließlich wære parent.height * parent.size hier viel sinniger. Es funktioniert
        aber, und der Balken hat auch die gewünschte Länge parent.height*parent.size. Schreibt man aber stattdessen das, entsteht beim State Change für
        vertical eine Binding Loop, warum auch immer. Der gewünschte Effekt wird also so erzielt.*/
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
                PauseAnimation { duration: 4000 }
                NumberAnimation { target: contentItem; properties: "opacity"; duration: 1000}
            }
        }
    }
}
