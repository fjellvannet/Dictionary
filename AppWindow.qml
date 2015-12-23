import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

Item {
    id: root
    width: 640
    height: 480
    anchors.fill: parent

    property color dark_blue: "#00313c"
    property color medium_blue: "#00629b"
    property color light_blue: "#41b6e6"

    property int globalMargin: fontHeight.height / 2
    property int globalBorder: globalMargin / 10 > 1 ? globalMargin / 10 : 1

    Text {
        id: fontHeight
        visible: false
    }

    Column{
        anchors.fill: parent

        Rectangle{
            id: menuBar
            width: parent.width
            height: globalMargin * 10
            color: dark_blue
        }

        Rectangle{
            id: window
            width: parent.width
            height: parent.height - menuBar.height
            Rectangle {
                id: home //um den Grundzustand wiederherzustellen: root.state = ""
                color: light_blue
                anchors.fill: parent
                visible: true
                Column {
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: globalMargin
                    spacing: globalMargin

                    HomeScreenButton{
                        textLabel:qsTr("Waddensea Dictionary")
                        anchors.left: parent.left; anchors.right: parent.right
                        onClicked: {
                            root.state = "dictionary"
                        }
                    }

                    HomeScreenButton{
                        textLabel:qsTr("Image")
                        anchors.left: parent.left; anchors.right: parent.right
                    }
                }
            }
            Rectangle
            {
                id: dictionary
                anchors.fill: parent
                visible: false
                color: light_blue

                ListView {
                    anchors.fill:parent
                    anchors.margins: globalMargin
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0
                    clip: true
                    headerPositioning: ListView.PullBackHeader
                    Component.onCompleted: {//notwendig, da ansonsten zu Anfang die Hälfte der ersten Kategorie/des ersten Elementes verdeckt wird
                        positionViewAtBeginning()
                    }

                    model: myModel

                    header: Rectangle {
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

//                        ListModel {
//                        id: fruitModel

//                        ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }
//                        ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }ListElement {
//                            name: "Apple"
//                            cost: 2.45
//                        }
//                        ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }ListElement {
//                            name: "Orange"
//                            cost: 3.25
//                        }
//                        ListElement {
//                            name: "Banana"
//                            cost: 1.95
//                        }
//                        ListElement {
//                            name: "Pear"
//                            cost: 1.25
//                        }
//                        ListElement {
//                            name: "Pineapple"
//                            cost: 6.45
//                        }
//                        ListElement {
//                            name: "peach"
//                            cost: 2.50
//                        }
//                    }
                    delegate: Rectangle {
                        color: "black"
                        width: parent.width
                        height: textRow.height + globalBorder
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: globalBorder
                            anchors.bottomMargin: 0
                            Row {
                                id: textRow
                                spacing: globalMargin
                                Text { text: Deutsch + " - " + English + " - " + Nederlands + " - " + Dansk + " - " + Scientific}
                            }
                        }
                    }
                    footer: Rectangle {
                        width: parent.width
                        height: globalBorder
                        color: "black"
                        visible: myModel.rowCount() > 0 ? true : false
                    }

                    section.property: "Deutsch"
                    section.criteria: ViewSection.FirstCharacter
                    section.delegate: Rectangle {
                        color: "black"
                        width: parent.width
                        height: text.height + globalBorder
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: globalBorder
                            anchors.bottomMargin: 0
                            color: medium_blue
                            Text {
                                id: text
                                text: section
                                font.bold: true
                                font.pointSize: 1.5 * fontHeight.font.pointSize
                            }
                        }
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "dictionary"
            PropertyChanges { target: home; visible: false }
            PropertyChanges { target: dictionary; visible: true }
        }
    ]
}
