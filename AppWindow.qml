import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0

ColumnLayout{
    id: root
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

    property int language: 0
    property int appLanguage: 3

    function nextLanguage() {
        if(language < 3) language++;
        else if(language === 4 && root.state === "dictionary") language = 0;
        else if (language === 3 && root.state === "vocabularyList") language = 0;
        else if (language === 3 && root.state === "dictionary") language = 4;
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
                source: switch(language) {
                        case 0:
                            return "qrc:/images/flags/german_flag.svg"
                        case 1:
                            return "qrc:/images/flags/union_jack.svg"
                        case 2:
                            return "qrc:/images/flags/netherlands_flag.svg"
                        case 3:
                            return "qrc:/images/flags/danish_flag.svg"
                        case 4:
                            return "qrc:/images/flags/all_languages.svg"
                        case undefined:
                            return ""
                        }

                signal sortBy(var role)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(root.state == "vocabularyList")
                        {
                            lvVocabulary.visible = false
                            nextLanguage()
                            languageButton.sortBy(language)
                            lvVocabulary.positionViewAtEnd()
                            lvVocabulary.positionViewAtBeginning()
                            lvVocabulary.visible = true
                        }
                        if(root.state == "dictionary")
                        {
                            nextLanguage()
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
                        if(language === 4) language = 0
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
                maximumFlickVelocity: globalMargin * 1000
                flickDeceleration: maximumFlickVelocity / 2
                clip: true

                section.labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
                section.property: switch (language) {
                    case 0:
                        return "SecDeutsch"
                    case 1:
                        return "SecEnglish"
                    case 2:
                        return "SecNederlands"
                    case 3:
                        return "SecDansk"
                    default:
                        return ""
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
                        property string wordText: switch (language) {
                            case 0:
                                return Deutsch
                            case 1:
                                return English
                            case 2:
                                return Nederlands
                            case 3:
                                return Dansk
                            default:
                                return ""
                        }
                        property string wordScientific: Scientific == "" ? "" : " (<i>" + Scientific + "</i>)"
                        text: wordText + wordScientific
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

            ColumnLayout {
                id: dictionaryWidget
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: false
                spacing: 0

                Rectangle { //Suchfeld
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2 * searchField.implicitHeight
                    Layout.margins: globalMargin

                    border.width: 2 * globalBorder
                    border.color: "#666666"
                    radius: height / 4
                    RowLayout
                    {
                        anchors.fill: parent
                        anchors.margins: parent.height / 5
                        spacing: parent.height / 10

                        Image {
                            Layout.fillHeight: true
                            width: height
                            sourceSize.height: height
                            sourceSize.width: height
                            source: "qrc:/images/icons/magnifying_glass.svg"
                        }

                        TextInput {
                            id: searchField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.rightMargin: 1
                            clip: true
                            inputMethodHints: Qt.ImhNoPredictiveText
                            verticalAlignment: Text.AlignVCenter
                            Text {
                                anchors.fill: parent
                                text: qsTr("Search")
                                color: "#888"
                                visible: !parent.focus && parent.length === 0
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Image {
                            Layout.fillHeight: true
                            width: height
                            sourceSize.height: height
                            sourceSize.width: height
                            source: "qrc:/images/icons/cross_searchfield.svg"
                            visible: searchField.length !== 0

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    searchField.text = ""
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    color: "black"
                    Layout.fillWidth: true
                    Layout.preferredHeight: globalBorder
                }

                ListView {
                    id: lvDictionary
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    maximumFlickVelocity: globalMargin * 1000
                    flickDeceleration: maximumFlickVelocity / 2

                    model: dictionaryModel

                    delegate: Rectangle {
                        id: dictionaryDelegate
                        width: parent.width
                        height: Math.max(4 * globalMargin, dictionaryWord.implicitHeight + globalMargin)
                        z: 2
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: globalMargin / 2
                            Image {
                                visible: language == 4
                                Layout.preferredHeight: 3 * globalMargin
                                sourceSize.height: height
                                sourceSize.width: height / 3 * 5
                                source: switch(ResultLanguage) {
                                        case 0:
                                            return "qrc:/images/flags/german_flag.svg"
                                        case 1:
                                            return "qrc:/images/flags/union_jack.svg"
                                        case 2:
                                            return "qrc:/images/flags/netherlands_flag.svg"
                                        case 3:
                                            return "qrc:/images/flags/danish_flag.svg"
                                        case 4:
                                            switch (appLanguage) {
                                            case 0:
                                                return "qrc:/images/flags/german_flag.svg"
                                            case 1:
                                                return "qrc:/images/flags/union_jack.svg"
                                            case 2:
                                                return "qrc:/images/flags/netherlands_flag.svg"
                                            case 3:
                                                return "qrc:/images/flags/danish_flag.svg"
                                            default:
                                                return ""
                                            }
                                        default:
                                            return ""
                                }
                            }


                            Text {
                                id: dictionaryWord
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                property string wordScientific: Scientific == "" ? "" : " (<i>" + Scientific + "</i>)"
                                property string appLanguageScientific: switch (appLanguage) {
                                                                       case 0:
                                                                          return Deutsch
                                                                       case 1:
                                                                          return English
                                                                       case 2:
                                                                          return Nederlands
                                                                       case 3:
                                                                          return Dansk
                                }
                                text: (ResultLanguage == 4 ? appLanguageScientific : ResultWord) + wordScientific
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.Wrap
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                lvDictionary.focus = true
                                dictionaryDelegate.ListView.view.currentIndex = index
                            }
                        }

                        states: State {
                            when: dictionaryDelegate.ListView.isCurrentItem
                            PropertyChanges { target: dictionaryDelegate; color: "blue"; z: 4 }
                        }
                    }

                    Keys.onReleased: {
                        if(event.key === Qt.Key_Back) {
                            event.accepted = true
                            root.state = ""
                        }
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
                property int fromLanguage: language === 4 ? appLanguage : language

                Layout.preferredHeight: resultView.height
                Layout.preferredWidth: resultView.width
                Layout.minimumWidth: parent.width / 4
                Layout.maximumWidth: parent.width / 2
                Layout.fillHeight: true
                Layout.fillWidth: false

                Flickable {
                    anchors.fill: parent
                    contentWidth: resultView.width; contentHeight: resultView.height
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
                                rowLanguage: resultWidget.fromLanguage
                                resize: highDpi ? 1.25 : 1.75
                                scientific: true
                                visible: true
                                row: resultWidget.resultListView.currentIndex
                            }
                            ResultRow {
                                rowLanguage: 0
                                row: resultWidget.resultListView.currentIndex
                            }
                            ResultRow {
                                rowLanguage: 1
                                row: resultWidget.resultListView.currentIndex
                            }
                            ResultRow {
                                rowLanguage: 2
                                row: resultWidget.resultListView.currentIndex
                            }
                            ResultRow {
                                rowLanguage: 3
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
                        Layout.maximumHeight: gridLayout.height / 2
                    }
                }
            }
        }
    }

    states: [

        State {
            name: "vocabularyList"
            PropertyChanges { target: home; visible: false }
            PropertyChanges { target: gridLayout; visible: true }
            PropertyChanges { target: lvVocabulary; focus: true; visible: true; model: vocabularyModel}
            PropertyChanges { target: dictionaryMenu; visible: true }
        },

        State {
            name: "dictionary"
            extend: "vocabularyList"
            PropertyChanges { target: lvVocabulary; visible: false; focus: false; model: ""}
            PropertyChanges { target: dictionaryWidget; visible: true }
            PropertyChanges { target: lvDictionary; focus: true}
            PropertyChanges { target: resultWidget; resultListView: lvDictionary }

        }
    ]
}
