import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

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
            height: globalMargin * 10
            color: dark_blue
            z: 10

            RowLayout {
                id: dictionaryMenu
                anchors.fill: parent
                anchors.margins: 1.5 * globalMargin

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

                GridLayout {
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
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: globalBorder
                                anchors.leftMargin: globalMargin / 2
                                anchors.bottomMargin: 0
                                color: medium_blue
                                Text {
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
                            }
                        }

                        footer: Rectangle {
                            width: parent.width
                            height: globalBorder
                            color: "black"
                            visible: VocabularyModel.rowCount() > 0 ? true: false
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
                            visible: parent.verticalVelocity <= parent.maximumFlickVelocity / 4 && parent.verticalVelocity >= -parent.maximumFlickVelocity / 4 ? false : true
                            anchors.centerIn: parent
                            text: parent.currentSection
                            color: "white"
                            font.pointSize: 3 * fontHeight.font.pointSize
                        }
                    }

                    Rectangle {
                        id: resultWindow
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        border.width: globalBorder
                        color: light_blue
                        property ListView resultView: lvVocabulary
                        property int fromLanguage: languageInt

                        Column {
                            anchors.fill: parent
                            anchors.margins: 2 * globalMargin
                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                property double resize: 1.5
                                spacing: globalMargin
                                Image {
                                    id: flag
                                    height: 4 * parent.resize * globalMargin > languageAndScientific.implicitHeight ? 4 * parent.resize * globalMargin : languageAndScientific.implicitHeight
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
                                    }
                                }

                                Text {
                                    id: languageAndScientific
                                    height: flag.height
                                    text: String(VocabularyModel.data(3,3))
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
