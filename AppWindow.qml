import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0

Item {
    id: root
    width: 640
    height: 480
    anchors.fill: parent

    property color dark_blue: "#00629b"
    property color medium_blue: "#00313c"
    property color light_blue: "#41b6e6"

    property int globalMargin: fontHeight.height / 2
    property int globalBorder: globalMargin / 10 > 1 ? globalMargin / 10 : 1
    property bool highDpi: Math.max(Screen.height, Screen.width) / globalMargin < 100

    property int languageInt: 0

    Text {
        id: fontHeight
        visible: false
    }

    function nextLanguage() {
        if(languageInt < 3) languageInt++;
        else if(languageInt == 4 && root.state == "dictionary") languageInt = 0;
        else if (languageInt == 3 && root.state == "vocabularyList") languageInt = 0;
    }

    Column{
        anchors.fill: parent

        Rectangle{
            id: menuBar
            width: parent.width
            height: globalMargin * (highDpi ? 8 : 11)
            color: dark_blue
            z: 10

            RowLayout {
                id: dictionaryMenu
                anchors.fill: parent
                anchors.margins: parent.height / 8

                Item { //Platzhalter
                    Layout.fillWidth: true
                }

                Image {
                    id: languageButton
                    objectName: "LanguageButton"
                    Layout.fillHeight: true
                    sourceSize.height: height
                    sourceSize.width: height / 3 * 5
                    source: switch(languageInt) {
                    case 0:
                        return "qrc:/images/flags/german_flag.svg"
                    case 1:
                        return "qrc:/images/flags/union_jack.svg"
                    case 2:
                        return "qrc:/images/flags/danish_flag.svg"
                    case 3:
                        return "qrc:/images/flags/netherlands_flag.svg"
                    case 4:
                        return "qrc:/images/flags/all_languages.svg"
                    }

                    signal sortBy(var role)

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(root.state == "vocabularyList")
                            {

                                lvVocabulary.visible = false
                                nextLanguage()
                                languageButton.sortBy(languageInt)
                                lvVocabulary.positionViewAtEnd()
                                lvVocabulary.positionViewAtBeginning()
                                lvVocabulary.currentIndex = 0
                                lvVocabulary.visible = true
                            }
                        }
                    }
                }
            }
        }

        Rectangle{
            id: window
            width: parent.width
            height: parent.height - menuBar.height
            color: light_blue
            Item {
                id: home //um den Grundzustand wiederherzustellen: root.state = ""
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

            Item
            {
                id: dictionary
                anchors.fill: parent
                visible: false

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

                    //model: DictionaryModel

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
                                    visible: text.length !== 9 // Klammern nur anzeigen, wenn es überhaupt einen wissenschaftlichen Begriff gibt
                                }
                            }
                        }
                    }

                    footer: Rectangle {
                        width: parent.width
                        height: globalBorder
                        color: "black"
                        //visible: DictionaryModel.count > 0 ? true : false
                    }
                }
            }

            Item
            {
                id: vocabularyList
                anchors.fill: parent
                visible: false

                GridLayout {
                    id: gridLayoutVocabulary
                    anchors.fill: parent
                    flow:  width > height ? GridLayout.LeftToRight : GridLayout.TopToBottom
                    rowSpacing: 0
                    columnSpacing: 0

                    ListView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        id: lvVocabulary
                        model: VocabularyModel
                        maximumFlickVelocity: globalMargin * 1000
                        flickDeceleration: maximumFlickVelocity / 2
                        focus: true
                        clip: true
                        Component.onCompleted: {
                            positionViewAtEnd()
                            positionViewAtBeginning()
                        }

                        section.labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
                        section.property: switch (languageInt) {
                            case 0:
                                return "SecDeutsch"
                            case 1:
                                return "SecEnglish"
                            case 2:
                                return "SecNederlands"
                            case 3:
                                return "SecDansk"
                        }

                        section.delegate: Rectangle {
                            id: sectionDelegate
                            color: "black"
                            width: parent.width
                            height: 4 * globalMargin + globalBorder
                            z:3
                            Rectangle {
                                anchors.fill: parent
                                anchors.topMargin: globalBorder
                                color: medium_blue
                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: globalMargin / 2
                                    id: text
                                    text: section
                                    font.bold: true
                                    height: 4 * globalMargin
                                    verticalAlignment: Text.AlignVCenter
                                    font.pointSize: 1.5 * fontHeight.font.pointSize
                                    color: "white"
                                }
                            }
                        }

                        delegate: Rectangle {
                            id: wordDelegate
                            color: "black"
                            width: parent.width
                            height: word.height
                            z: 2
                            Rectangle {
                                id: wordBackground
                                anchors.fill: parent
                                anchors.topMargin: globalBorder
                                anchors.bottomMargin: 0
                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: globalMargin / 2
                                    id: word
                                    property string wordText: switch (languageInt) {
                                        case 0:
                                            return Deutsch
                                        case 1:
                                            return English
                                        case 2:
                                            return Nederlands
                                        case 3:
                                            return Dansk
                                    }
                                    property string wordScientific: Scientific == "" ? "" : "(<i>" + Scientific + "</i>)"
                                    text: wordText + " " + wordScientific
                                    height: implicitHeight + globalMargin
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.Wrap
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: wordDelegate.ListView.view.currentIndex = index
                            }
                            states: State {
                                name: "Current"
                                when: wordDelegate.ListView.isCurrentItem
                                PropertyChanges { target: wordBackground; color: "blue" }
                                PropertyChanges { target: wordDelegate; z: 4 }
                                PropertyChanges { target: word; height: Math.max(4 * globalMargin + globalBorder, implicitHeight + globalMargin) }
                            }
                        }

                        Rectangle {
                            z: sectionLetter.z - 1 //sonst verschwindet es hinter den Delegates...
                            visible: sectionLetter.visible
                            height: 2 * sectionLetter.height
                            width: height
                            color: "blue"
                            opacity: 0.5
                            anchors.centerIn: parent
                            radius: height / 6
                        }

                        Text {
                            id: sectionLetter
                            z: parent.delegate.z + 2
                            visible: parent.verticalVelocity >= parent.maximumFlickVelocity / 4 || parent.verticalVelocity <= -parent.maximumFlickVelocity / 4
                            anchors.centerIn: parent
                            text: parent.currentSection
                            color: "white"
                            font.pointSize: 3 * fontHeight.font.pointSize
                        }
                    }

                    Rectangle {
                        id: seperatorLine
                        color: "black"
                        Layout.preferredWidth: globalBorder
                        Layout.fillHeight: true
                    }

                    Item {
                        id: resultWidget
                        Layout.preferredHeight: resultView.height
                        Layout.preferredWidth: resultView.width
                        Layout.minimumWidth: gridLayoutVocabulary.width / 4
                        Layout.maximumWidth: gridLayoutVocabulary.width / 2
                        Layout.fillHeight: true
                        Layout.fillWidth: false

                        states: State{
                                name: "TopToBottom"
                                when: gridLayoutVocabulary.flow == GridLayout.TopToBottom
                                PropertyChanges{target: resultWidget; Layout.fillHeight: false                                  }
                                PropertyChanges{target: resultWidget; Layout.fillWidth: true                                    }
                                PropertyChanges{target: resultWidget; Layout.maximumWidth: -1                                   }
                                PropertyChanges{target: resultWidget; Layout.maximumHeight: gridLayoutVocabulary.height / 2     }

                                PropertyChanges{target: seperatorLine; Layout.fillWidth: true                                   }
                                PropertyChanges{target: seperatorLine; Layout.fillHeight: false                                 }
                                PropertyChanges{target: seperatorLine; Layout.preferredHeight: globalBorder                     }
                        }

                        z: 9
                        property ListView resultListView: lvVocabulary
                        property int fromLanguage: languageInt
                        Flickable {
                            anchors.fill: parent
                            contentWidth: resultView.width; contentHeight: resultView.height
                            flickableDirection: Flickable.HorizontalAndVerticalFlick
                            clip: true

                            boundsBehavior: Flickable.StopAtBounds
                            Item {
                                id: resultView
                                height: resultColumn.implicitHeight + 2 * resultColumn.anchors.margins
                                width: resultColumn.implicitWidth + 2 * resultColumn.anchors.margins
                                Column {
                                    id: resultColumn
                                    anchors.fill: parent
                                    anchors.margins: 1.5 * globalMargin
                                    spacing: globalMargin
                                    ResultLanguageWidget {
                                        language: languageInt
                                        resize: highDpi ? 1.25 : 1.75
                                        scientific: true
                                        row: resultWidget.resultListView.currentIndex
                                    }
                                    ResultLanguageWidget {
                                        language: 0
                                        visible: languageInt !== language
                                        row: resultWidget.resultListView.currentIndex
                                    }
                                    ResultLanguageWidget {
                                        language: 1
                                        visible: languageInt !== language
                                        row: resultWidget.resultListView.currentIndex
                                    }
                                    ResultLanguageWidget {
                                        language: 2
                                        visible: languageInt !== language
                                        row: resultWidget.resultListView.currentIndex
                                    }
                                    ResultLanguageWidget {
                                        language: 3
                                        visible: languageInt !== language
                                        row: resultWidget.resultListView.currentIndex
                                    }
                                }
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
        },

        State {
            name: "vocabularyList"
            PropertyChanges { target: home; visible: false }
            PropertyChanges { target: vocabularyList; visible: true }
        }
    ]
}
