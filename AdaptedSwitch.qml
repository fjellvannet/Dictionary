import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
Switch {
    implicitHeight: Math.max(focus_indicator.height-0.75*em, contentItem.implicitHeight)
    background: Item{}
    Rectangle {
        id: background
        height: 1.25 * em
        x: (focus_indicator.height - height)/2
        width: 2.5 * height
        radius: height / 2
        property int duration: 200
        state: "off"
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0.5

        MouseArea {
            id: ma
            anchors.fill: parent
            onClicked: {
                checked = !checked
            }
        }

        states: [
            State {
                name: "on"
                when: checked
                PropertyChanges { target: handle; x: ma2.drag.maximumX}
                PropertyChanges { target: background; color: Material.accent }
            },

            State {
                name: "off"
                when: !checked
                PropertyChanges { target: handle; x: ma2.drag.minimumX; color: "white" }
                PropertyChanges { target: background; color: Material.color(Material.Grey, Material.Shade700)}
            }

        ]

        transitions: Transition {
            NumberAnimation {
                duration: background.duration
                property: "x"
            }

            ColorAnimation {
                duration: background.duration
            }
        }
    }

    Rectangle {
        id: focus_indicator
        visible: parent.visualFocus
        anchors.centerIn: handle
        color: background.color
        opacity: 0.3
        height: 2 * handle.height
        radius: height/2
        width: height
        z: handle.z - 1
    }

    indicator: Rectangle {
        id: handle
        height: 1.5 * background.height
        width: height
        radius: height/2
        color: background.color
        anchors.verticalCenter: parent.verticalCenter

        z: ma.z + 1
        MouseArea {
            id: ma2
            anchors.fill: parent
            drag.target: handle; drag.axis: Drag.XAxis; drag.minimumX: (focus_indicator.height - height)/2; drag.maximumX: background.width - (handle.height - background.height)/2
            onReleased: {
                if(!drag.active) {
                    checked = !checked
                }
                else if(handle.x < drag.maximumX - drag.minimumX) {
                    checked = true //muss erst false gesetzt werden, damit der state auch
                    checked = false //wirklich wieder angewendet wird (sonst bleibt die Kugel irgendwo in der Mitte stehen)
                }
                else {
                    checked = false
                    checked = true
                }
            }
        }

        Keys.onReleased: {
            if(event.key === Qt.Key_Space) {
                event.accepted = true
                checked = !checked
            }
        }
    }

    contentItem: AdaptedText {
        text: parent.text
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        leftPadding: 2 * background.x + background.width
    }
}
