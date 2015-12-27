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

    property int languageInt: 0

    Text {
        id: fontHeight
        visible: false
    }

    function nextLanguage() {
        languageInt++;
        if(languageInt == 5 && root.state == "dictionary") languageInt = 0;
        else if (languageInt == 4 && root.state == "vocabularyList") languageInt = 0;
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
                        textLabel:qsTr("Waddensea Vocabulary List")
                        anchors.left: parent.left; anchors.right: parent.right
                        onClicked: {
                            root.state = "vocabularyList"
                        }
                    }

                    HomeScreenButton{
                        textLabel:qsTr("Waddensea Dictionary")
                        anchors.left: parent.left; anchors.right: parent.right
                        onClicked: {
                            root.state = "dictionary"
                        }
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

                    header: SearchField {}

                    model: DictionaryModel

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
                                Text { text: Deutsch}
                                Text {
                                    text: "(<i>" + Scientific + "</i>)"
                                    visible: text.length == 9 ? false : true // Klammern nur anzeigen, wenn es überhaupt einen wissenschaftlichen Begriff gibt
                                }
                            }
                        }
                    }

                    footer: Rectangle {
                        width: parent.width
                        height: globalBorder
                        color: "black"
                        visible: DictionaryModel.count > 0 ? true : false
                    }
                }
            }

            Rectangle
            {
                id: vocabularyList
                anchors.fill: parent
                visible: false
                color: light_blue


                ListView {
                    model: VocabularyModel

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

                    anchors.fill:parent
                    anchors.margins: globalMargin
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0
                    clip: true

                    delegate: Rectangle {
                        color: "black"
                        width: parent.width
                        height: textRowL.height + globalBorder
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: globalBorder
                            anchors.bottomMargin: 0
                            Row {
                                id: textRowL
                                spacing: globalMargin
                                Text { text: Deutsch}
                                Text {
                                    text: "(<i>" + Scientific + "</i>)"
                                    visible: text.length == 9 ? false : true // Klammern nur anzeigen, wenn es überhaupt einen wissenschaftlichen Begriff gibt
                                }
                            }
                        }
                    }

                    footer: Rectangle {
                        width: parent.width
                        height: globalBorder
                        color: "black"
                        visible: VocabularyModel.count > 0 ? true: false
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
        },

        State {
            name: "vocabularyList"
            PropertyChanges { target: home; visible: false }
            PropertyChanges { target: vocabularyList; visible: true }
        }
    ]
}
