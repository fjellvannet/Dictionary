import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Controls.Material 2.4

Rectangle {
    Material.theme: Material.Light
    Material.accent: Material.color(Material.Blue, Material.ShadeA700)
    height: window.height//childrenRect.height + 500
    width: window.width
    color: width == window.width ? "transparent" : window.color
    property int basicUnit: splashImage.width / sizeConstant
    property int sizeConstant: 30

    Text {id: stdText}
    Rectangle {
        id: window
        anchors.centerIn: parent
        implicitHeight: windowColumn.implicitHeight + 2*basicUnit//windowColumn.implicitHeight + 2*basicUnit
        implicitWidth: (sizeConstant + 2)*basicUnit//windowColumn.implicitWidth + 2*basicUnit//Dieser Code funktioniert nicht - dann wird die implicitWidth der Høhe nicht richtig erkannt
        color: Material.color(Material.LightBlue, Material.Shade300)
        border.width: {
            if(false);//parent.height == height) return Math.max(basicUnit / 10, 1)
            else return 0
        }
        radius: 3*basicUnit
        Column{
            id: windowColumn
            anchors.fill: parent
            anchors.margins: basicUnit
            spacing: basicUnit

            AdaptedImage {
                id: splashImage
                height: width
                width: Math.min(Math.min(Screen.height, Screen.width)/2, sizeConstant*stdText.font.pixelSize)
                source: "qrc:/images/icons/app_icon"
                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.quit()
                }
            }
            ProgressBar {
                height: 2*basicUnit
                background.height: height
                contentItem.implicitHeight: height
                width: parent.width
                indeterminate: true
            }
            Text{
                text: Qt.application.name
                width: splashImage.width
                font.bold: true
                font.pixelSize: {
                    var patt = / /
                    if(patt.test(text)) return 4*basicUnit
                    else return 3*basicUnit
                }
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
