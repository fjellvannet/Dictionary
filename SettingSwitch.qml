import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
RowLayout {
    id: rootLayout
    property string _text
    property bool checked: false
    spacing: globalMargin

    Rectangle {
        id: background
        Layout.preferredHeight: txt.height
        Layout.preferredWidth: 2.5 * txt.height
        radius: parent.height / 2
        property int duration: 200
        state: "off"

        Rectangle {
            id: handle
            height: parent.height
            width: parent.height
            radius: parent.radius
            color: activeFocus ? dark_blue : "#888"
            activeFocusOnTab: true
            z: ma.z + 1
            MouseArea {
                anchors.fill: parent
                drag.target: handle; drag.axis: Drag.XAxis; drag.minimumX: 0; drag.maximumX: background.width - handle.width
                onReleased: {
                    if(!drag.active) {
                        checked = !checked
                    }
                    else if(handle.x < (background.width - handle.width) / 2) {
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
                when: rootLayout.checked
                PropertyChanges { target: handle; x: background.width - handle.width }
                PropertyChanges { target: background; color: medium_blue }
            },

            State {
                name: "off"
                when: !rootLayout.checked
                PropertyChanges { target: handle; x: 0 }
                PropertyChanges { target: background; color: "lightgray" }
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

    AdaptedText {
        id: txt
        text: _text
        verticalAlignment: Text.AlignVCenter
        Layout.preferredHeight: 1.5 * implicitHeight
    }
}
