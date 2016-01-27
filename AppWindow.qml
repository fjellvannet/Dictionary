import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0

ColumnLayout{
    id: root
    width: 640
    height: 480
    anchors.fill: parent
    spacing: 0

    property color light_blue: "#41b6e6"
    property color medium_blue: "#00629b"
    property color dark_blue: "#00313c"

    Text {
        id: fontHeight
        visible: false
    }

    property int globalMargin: fontHeight.height / 2
    property int globalBorder: globalMargin / 10 > 1 ? globalMargin / 10 : 1
    property bool highDpi: Math.max(Screen.height, Screen.width) / globalMargin < 100

    property int languageInt: 0

    function nextLanguage() {
        if(languageInt < 3) languageInt++;
        else if(languageInt === 4 && root.state === "dictionary") languageInt = 0;
        else if (languageInt === 3 && root.state === "vocabularyList") languageInt = 0;
    }

    Rectangle{
        id: menuBar
        Layout.fillWidth: true
        Layout.preferredHeight: globalMargin *(highDpi ? 6 : 11)
        color: medium_blue

        RowLayout {
            id: dictionaryMenu
            anchors.fill: parent
            anchors.margins: parent.height / 8
            visible: false

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Image {
                    anchors.centerIn: parent
                    id: backButton
                    //Layout.fillHeight: true
                    sourceSize.height: parent.height / 1.35
                    sourceSize.width: parent.height / 1.35
                    source: "qrc:/images/icons/arrow.svg"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.state = ""
                    }
                }
            }

            Item { Layout.fillWidth: true } //Platzhalter

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
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: light_blue
        Item {
            id: home //um den Grundzustand wiederherzustellen: root.state = ""
            anchors.fill: parent
            Column {
                anchors.fill: parent
                anchors.margins: globalMargin
                spacing: globalMargin

                HomeScreenButton{
                    textLabel:qsTr("Waddensea Vocabulary List")
                    onClicked: {
                        root.state = "vocabularyList"
                    }
                }

                HomeScreenButton{
                    textLabel:qsTr("Waddensea Dictionary")
                    onClicked: {
                        root.state = "dictionary"
                    }
                }
            }
        }

        GridLayout {
            id: gridLayout
            visible: false
            anchors.fill: parent
            flow:  width > height ? GridLayout.LeftToRight : GridLayout.TopToBottom
            rowSpacing: 0
            columnSpacing: 0

            ListView {
                id: lvVocabulary
                Layout.fillHeight: true
                Layout.fillWidth: true

                model: VocabularyModel
                maximumFlickVelocity: globalMargin * 1000
                flickDeceleration: maximumFlickVelocity / 2
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
                    color: dark_blue
                    width: parent.width
                    height: 4 * globalMargin
                    z:3
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: globalMargin / 2
                        id: text
                        text: section
                        font.bold: true
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 1.5 * fontHeight.font.pointSize
                        color: "white"
                    }
                }

                delegate: Rectangle {
                    id: wordDelegate
                    width: parent.width
                    height: Math.max(4 * globalMargin, word.implicitHeight + globalMargin)
                    z: 2
                    Text {
                        id: word
                        anchors.left: parent.left; anchors.right: parent.right
                        anchors.leftMargin: globalMargin / 2
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
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: wordDelegate.ListView.view.currentIndex = index
                    }

                    states: State {
                        when: wordDelegate.ListView.isCurrentItem
                        PropertyChanges { target: wordDelegate; color: "blue"; z: 4 }
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

                Keys.onReleased: {
                    if(event.key === Qt.Key_Back) {
                        event.accepted = true
                        root.state = ""
                    }
                }
            }

            Rectangle {
                id: seperatorLine
                color: "black"
                Layout.preferredWidth: globalBorder
                Layout.fillHeight: true

                states: State{
                    when: gridLayout.flow === GridLayout.TopToBottom
                    PropertyChanges{
                        target: seperatorLine
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        Layout.preferredHeight: globalBorder
                    }
                }
            }

            Item {
                id: resultWidget
                property ListView resultListView: lvVocabulary
                property int fromLanguage: languageInt

                Layout.preferredHeight: resultView.height
                Layout.preferredWidth: resultView.width
                Layout.minimumWidth: parent.width / 4
                Layout.maximumWidth: parent.width / 2
                Layout.fillHeight: true
                Layout.fillWidth: false

                Flickable {
                    anchors.fill: parent
                    contentWidth: childrenRect.width; contentHeight: childrenRect.height
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
                            ResultRow {
                                language: languageInt
                                resize: highDpi ? 1.25 : 1.75
                                scientific: true
                                visible: true
                                row: resultWidget.resultListView.currentIndex
                            }
                            ResultRow {
                                language: 0
                                row: resultWidget.resultListView.currentIndex
                            }
                            ResultRow {
                                language: 1
                                row: resultWidget.resultListView.currentIndex
                            }
                            ResultRow {
                                language: 2
                                row: resultWidget.resultListView.currentIndex
                            }
                            ResultRow {
                                language: 3
                                row: resultWidget.resultListView.currentIndex
                            }
                        }
                    }
                }

                states: State{
                    name: "TopToBottom"
                    when: gridLayout.flow === GridLayout.TopToBottom
                    PropertyChanges{
                        target: resultWidget
                        Layout.fillHeight: false
                        Layout.fillWidth: true
                        Layout.maximumWidth: -1
                        Layout.maximumHeight: parent.height / 2
                    }
                }
            }
        }
    }

    states: [
//        State {
//            name: "dictionary"
//            PropertyChanges { target: home; visible: false }
//            PropertyChanges { target: dictionary; visible: true }
//        },

        State {
            name: "vocabularyList"
            PropertyChanges { target: home; visible: false }
            PropertyChanges { target: gridLayout; visible: true }
            PropertyChanges { target: lvVocabulary; focus: true; visible: true }
            PropertyChanges { target: dictionaryMenu; visible: true }

        }
    ]
}
