import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

Rectangle { //Suchfeld
    width: parent.width
    height: searchBox.height + globalMargin * 2
    z: 3
    color: dictionary.color
    Rectangle {
        anchors.centerIn: parent
        id: searchBox
        width: parent.width
        height: 1.25 * searchField.height
        border.width: 2 * globalBorder
        border.color: "#666666"
        //color: "#00000000" //macht das ganze Suchfeld transparent, sodass man die Hintergrundfarbe sieht
        radius: height / 4
        RowLayout
        {
            anchors.fill: parent
            
            Image {
                id: magnifying_glass
                Layout.margins: parent.height / 5
                Layout.rightMargin: 0
                Layout.fillHeight: true
                width: height
                sourceSize.height: height
                sourceSize.width: height
                source: "qrc:/images/Lupe.svg"
            }
            
            
            TextField {
                id: searchField
                Layout.fillWidth: true
                Layout.rightMargin: 1
                placeholderText: qsTr("Search")
                inputMethodHints: Qt.ImhNoPredictiveText
                verticalAlignment: Text.AlignVCenter
                style: TextFieldStyle {
                    background: Item{}
                }
            }
            
            Image {
                id: cross_searchfield
                Layout.margins: parent.height / 5
                Layout.leftMargin: 0
                Layout.fillHeight: true
                width: height
                sourceSize.height: height
                sourceSize.width: height
                source: "qrc:/images/cross_searchfield.svg"
                visible: searchField.length == 0 ? false : true
                
                MouseArea {
                    id: cleanButton
                    anchors.fill: parent
                    onClicked: {
                        searchField.text = ""
                    }
                }
            }
        }
    }
}
