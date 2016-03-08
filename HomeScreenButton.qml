import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button {
    property string textLabel
    width: parent.width
    height: 2 * implicitHeight
    style: ButtonStyle {
        label:  Label {
            text: textLabel
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
        }

        background: Rectangle {
            color: dark_blue
            border.width: control.activeFocus ? 2 * globalBorder : globalBorder
            border.color: "#888"
            radius: height / 4
        }
    }

    Keys.onReleased: {
        if(event.key === Qt.Key_Enter) {
            clicked()
        }
    }
}
