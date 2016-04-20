import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button {
    property string textLabel
    width: parent.width
    height: 2 * implicitHeight
    style: ButtonStyle {
        label:  AdaptedText {
            text: textLabel
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
        }

        background: Rectangle {
            color: dark_blue
            border.width: control.activeFocus ? 2 * globalBorder : 0
            border.color: "#888"
            radius: height / 4
        }
    }
}
