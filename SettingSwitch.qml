import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
RowLayout {
    property string a_text
    property bool checked
    spacing: globalMargin

    Rectangle {
        id: background
        Layout.preferredHeight: txt.height
        Layout.preferredWidth: 2.5 * txt.height
        radius: parent.height / 2
        color: checked ? medium_blue : "lightgray"
        property int duration: 100


        Behavior on color{
            ColorAnimation { duration: background.duration }
        }

        Rectangle {
            id: handle
            height: parent.height
            width: parent.height
            radius: parent.radius
            color: activeFocus ? "blue" : "#888"
            x: checked ? parent.width - width : 0

            Behavior on x {
                NumberAnimation {
                    duration: background.duration
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: checked = !checked
        }
    }

    AdaptedText {
        id: txt
        text: a_text
        verticalAlignment: Text.AlignVCenter
        Layout.preferredHeight: 2 * implicitHeight
    }
}
