import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

ColumnLayout{
    id: root
    anchors.fill: parent
    spacing: 0

    property color light_blue: "#41b6e6"
    property color medium_blue: "#00629b"
    property color dark_blue: "#00313c"
    property double rootSize: settings.sized
    //state: settings.vocabularyList ? "vocabularyList" : "dictionary"
    AdaptedText {
        id: fontHeight
        visible: false
    }

    Settings {
        id: settings
        property alias sized: sizeSlider.value
        property alias flags_in_all_language_mode: swFlags_in_all_language_mode.checked
        property alias findUmlauts: swUmlauts.checked
        property alias x: window.x
        property alias y: window.y
        property alias width: root.width
        property alias height: root.height
        property alias language: root.language
        property alias vocabularyList: root.vocabularyList
    }

    property int globalMargin: fontHeight.height / 2
    property int globalBorder: globalMargin / 10 > 1 ? globalMargin / 10 : 1
    property bool highDpi: Math.max(Screen.height, Screen.width) / globalMargin < 100
    property bool vocabularyList: false
    property int language: appLanguage

    property string wadden_sea_wordlist: qsTr("Wadden Sea wordlist")
    property string wadden_sea_dictionary: qsTr("Wadden Sea dictionary")

    function nextLanguage() {
        if(language < 3) language++;
        else if(language === 4 && root.state === "dictionary") language = 0;
        else if (language === 3 && root.state === "vocabularyList") language = 0;
        else if (language === 3 && root.state === "dictionary") language = 4;
    }

    Component.onCompleted: {
        if(root.state === "vocabularyList") lvVocabulary.updateView()
    }
    Rectangle{//Menubar
        Layout.fillWidth: true
        Layout.preferredHeight: globalMargin *(highDpi ? 6 : 11)
        color: medium_blue
        z: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: parent.height / 8
            spacing: parent.height / 8
            visible: false
            Button {
                id: backArrow
                visible: false
                Layout.fillHeight: true
                Layout.preferredWidth: height
                activeFocusOnTab: true

                AdaptedImage {
                    anchors.centerIn: parent
                    id: backButton
                    height: parent.height / 1.35
                    width: height
                    source: "qrc:/images/icons/arrow"
                }

                style: ButtonStyle {
                    background: Rectangle{
                        color: "#00000000"
                        border.color: "#888"
                        border.width: backArrow.activeFocus ? 2 * globalBorder : 0
                    }
                }

                onClicked: {
                    root.state = settings.vocabularyList ? "vocabularyList" : "dictionary"
                }
            }

            AdaptedText {
                id: activityTitle
                Layout.fillHeight: true
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height / 2.5
                font.bold: true
                color: "white"
                text: appName
                visible: false
            }

            AdaptedImage {
                visible: false
                id: languageButton
                objectName: "LanguageButton"
                Layout.fillHeight: true
                Layout.preferredWidth: height / 3 * 5
                source: switch(language) {
                        case 0:
                            return "qrc:/images/flags/german_flag"
                        case 1:
                            return "qrc:/images/flags/union_jack"
                        case 2:
                            return "qrc:/images/flags/netherlands_flag"
                        case 3:
                            return "qrc:/images/flags/danish_flag"
                        case undefined:
                            return ""
                        }

                signal sortBy(var role)

                Button {
                    id: languageBtn
                    anchors.fill: parent
                    activeFocusOnTab: true
                    onClicked: {
                        lvVocabulary.visible = false
                        nextLanguage()
                        lvVocabulary.updateView()
                    }

                    style: ButtonStyle {
                        background: Rectangle{
                            color: "#00000000"
                            border.color: "#888"
                            border.width: languageBtn.activeFocus ? 2 * globalBorder : 0
                        }
                    }

                    Keys.onReleased: {
                        if(event.key === Qt.Key_Back)
                        {
                            event.accepted = true
                            root.state = ""
                        }
                    }

                }
            }

            AdaptedImage {
                id: appIcon
                Layout.fillHeight: true
                Layout.preferredWidth: height
                source: "qrc:/images/icons/app_icon"
            }
        }
    }

    Rectangle{
        id: window
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: light_blue

        Flickable {
            id: settingsWindow
            anchors.fill: parent
            anchors.margins: globalMargin
            contentWidth: settingsColumn.width
            contentHeight: settingsColumn.height
            clip: false
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            visible: false

//                    onClicked: {
//                        if(language === 4){
//                            language = 0;
//                        }
//                        languageButton.sortBy(language);
//                        root.state = "vocabularyList"
//                    }

            ColumnLayout {
                id: settingsColumn
                width: settingsWindow.width
                spacing: globalMargin

                AdaptedText {
                    Layout.fillWidth: true
                    text: qsTr("Layout size")
                    font.pixelSize: 1.2 * fontHeight.font.pixelSize
                    font.bold: true
                }

                Slider {
                    id: sizeSlider
                    maximumValue: 60
                    minimumValue: 5
                    stepSize: 0.5
                    Layout.fillWidth: true
                    Text{
                        id: fontSize
                    }
                    value: fontSize.font.pixelSize

                    style: SliderStyle{
                        handle: Rectangle {
                            color: sizeSlider.activeFocus ? dark_blue : "gray"
                            height: 2.5 * globalMargin
                            width: height
                            radius: height / 2
                        }

                        groove: Rectangle {
                            height: globalMargin
                            width: parent.width
                            color: "lightgray"
                            radius: height / 2
                            Rectangle {
                                height: parent.height
                                width: styleData.handlePosition
                                radius: parent.radius
                                color: medium_blue
                            }
                        }
                    }
                }

                Rectangle {
                    color: "black"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2 * globalBorder
                }

                AdaptedText {
                    text:  qsTr("Dictionary Search")
                    Layout.fillWidth: true
                    font.pixelSize: 1.2 * fontHeight.font.pixelSize
                    font.bold: true
                }

                SettingSwitch {
                    id: swUmlauts
                    Layout.fillWidth: true
                    _text: qsTr("Find æ, ø, å, ä, ö, ü, ß when searching a, o, u or ss (mowe finds Möwe, weiss finds weiß)")
                    checked: true
                }

                SettingSwitch {
                    id: swFlags_in_all_language_mode
                    Layout.fillWidth: true
                    _text: qsTr("Show flags when searching all languages at the same time (might make search slower)")
                    checked: true
                }

                Rectangle {
                    color: "black"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2 * globalBorder
                }

                AdaptedText {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text:
                        qsTr("<h3>Impressum</h3><p>During my Voluntary ecological year (FÖJ, Germany) 2015/16 \
                        at the Wadden Sea Centre, in Vester Vedsted, Denmark, I have programmed this dictionary. \
                        For that, I used Qt 5.7-Open-Source.</p>\
                        <p>For suggestions and error-reports, send me (Lukas Neuenschwander) an e-mail (%1). Here \
                        you can also suggest missing words that you would like to have added to the dictionary.</p>\
                        <p>The data for this app is taken from the \”IWSS Wadden Sea Dictionary\” (%2) - with the \
                        permission from the \”International Wadden Sea School\” (%3).</p>")

                        .arg("<a href=\"mailto:lukas.neu24@gmail.com\">lukas.neu24@gmail.com</a>")
                        .arg("<a href=\"http://www.iwss.org/fileadmin/uploads/network-download/Education_\
                        _Support/IWSS_Dictionary_2009.pdf\">http://www.iwss.org/fileadmin/uploads/network\
                        -download/Education__Support/IWSS_Dictionary_2009.pdf</a>")
                        .arg("<a href=\"http://www.iwss.org/\">www.iwss.org</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }

            Keys.onReleased: {
                if(event.key === Qt.Key_Back) {
                    event.accepted = true
                    root.state = ""
                }
            }
        }

        GridLayout {
            id: gridLayout
            anchors.fill: parent
            flow:  width > height ? GridLayout.LeftToRight : GridLayout.TopToBottom
            rowSpacing: 0
            columnSpacing: 0

            ListView {
                id: lvVocabulary
                visible: false
                Layout.fillHeight: true
                Layout.fillWidth: true
                maximumFlickVelocity: globalMargin * 1000
                flickDeceleration: maximumFlickVelocity / 2
                clip: true
                activeFocusOnTab: true

                model: vocabularyModel

                function updateView(){
                    visible = false
                    languageButton.sortBy(language)
                    positionViewAtEnd()
                    positionViewAtBeginning()
                    currentIndex = 0
                    visible = true
                }

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
                    width: window.width
                    height: 4 * globalMargin
                    z:3
                    AdaptedText {
                        anchors.left: parent.left
                        anchors.leftMargin: globalMargin / 2
                        id: text
                        text: section
                        font.bold: true
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 1.5 * fontHeight.font.pixelSize
                        color: "white"
                    }
                }

                delegate: Rectangle {
                    id: wordDelegate
                    width: lvVocabulary.width
                    height: Math.max(4 * globalMargin, word.implicitHeight + globalMargin)
                    z: 2
                    AdaptedText {
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
                        property string wordScientific: Scientific === "" ? "" : " (<i>" + Scientific + "</i>)"
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

                AdaptedText {
                    id: sectionLetter
                    z: parent.delegate.z + 2
                    visible: parent.verticalVelocity >= parent.maximumFlickVelocity / 4 || parent.verticalVelocity <= -parent.maximumFlickVelocity / 4
                    anchors.centerIn: parent
                    text: parent.currentSection
                    color: "white"
                    font.pixelSize: 3 * fontHeight.font.pixelSize
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

                        AdaptedImage {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            source: "qrc:/images/icons/magnifying_glass"
                            MouseArea {
                                anchors.fill: parent
                                onClicked: searchField.performSearch()
                            }
                        }

                        TextInput {
                            id: searchField
                            objectName: "SearchField"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.rightMargin: 1
                            clip: true
                            inputMethodHints: Qt.ImhNoPredictiveText
                            verticalAlignment: Text.AlignVCenter
                            activeFocusOnTab: true
                            font: fontHeight.font

                            signal textChanged(var text, var findUmlauts)

                            AdaptedText {
                                anchors.fill: parent
                                text: qsTr("Search")
                                color: "#888"
                                visible: !parent.focus && parent.length === 0
                                verticalAlignment: Text.AlignVCenter
                            }

                            function performSearch() {
                                searchField.textChanged(searchField.text, settings.findUmlauts)
                                if(length > 0)
                                {
                                    noSearchResults.visible = lvDictionary.count === 0
                                    if(!noSearchResults.visible)
                                    {
                                        console.log("ios", languageButton.ios ? "true" : "false")
                                        if(!languageButton.ios && searchField.activeFocus) lvDictionary.forceActiveFocus()
                                        lvDictionary.currentIndex = 0
                                    }
                                }
                                resultColumn.updateText = !resultColumn.updateText//damit ResultWidget aktualisiert und ggf ausgeblendet wird
                            }

                            onEditingFinished: performSearch()

                            onVisibleChanged: {
                                if(visible) forceActiveFocus();
                            }

                            Keys.onReleased: {
                                if(event.key === Qt.Key_Back)
                                {
                                    event.accepted = true
                                    root.state = ""
                                }
                            }
                        }

                        AdaptedImage {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            source: "qrc:/images/icons/cross_searchfield"
                            visible: searchField.length !== 0

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    searchField.text = ""
                                    searchField.performSearch()
                                    searchField.forceActiveFocus()
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    color: "black"
                    Layout.fillWidth: true
                    Layout.preferredHeight: globalBorder
                    visible: lvDictionary.count > 0
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
                        width: lvDictionary.width
                        height: Math.max(4 * globalMargin, dictionaryWord.implicitHeight + globalMargin)
                        z: 2
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: globalMargin / 2
                            AdaptedImage {
                                visible: settings.flags_in_all_language_mode
                                Layout.preferredHeight: 3 * globalMargin
                                Layout.preferredWidth: height / 3 * 5
                                source: switch(ResultLanguage) {
                                        case 0:
                                            return "qrc:/images/flags/german_flag"
                                        case 1:
                                            return "qrc:/images/flags/union_jack"
                                        case 2:
                                            return "qrc:/images/flags/netherlands_flag"
                                        case 3:
                                            return "qrc:/images/flags/danish_flag"
                                        case 4:
                                            switch (language === 4 ? appLanguage : language) {
                                            case 0:
                                                return "qrc:/images/flags/german_flag"
                                            case 1:
                                                return "qrc:/images/flags/union_jack"
                                            case 2:
                                                return "qrc:/images/flags/netherlands_flag"
                                            case 3:
                                                return "qrc:/images/flags/danish_flag"
                                            default:
                                                return ""
                                            }
                                        default:
                                            return ""
                                }
                            }

                            AdaptedText {
                                visible: !settings.flags_in_all_language_mode
                                Layout.preferredHeight: 3 * globalMargin
                                Layout.preferredWidth: 4 * globalMargin
                                font.pixelSize: 3 * globalMargin
                                color: dark_blue
                                verticalAlignment: Text.AlignVCenter
                                text: switch(ResultLanguage) {
                                      case 0:
                                          return "DE"
                                      case 1:
                                          return "EN"
                                      case 2:
                                          return "NL"
                                      case 3:
                                          return "DK"
                                      case 4:
                                          switch (language === 4 ? appLanguage : language) {
                                          case 0:
                                              return "DE"
                                          case 1:
                                              return "EN"
                                          case 2:
                                              return "NL"
                                          case 3:
                                              return "DK"
                                          default:
                                              return ""
                                          }
                                      default:
                                          return ""
                               }
                            }

                            AdaptedText {
                                id: dictionaryWord
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                property string wordScientific: Scientific === "" ? "" : " (<i>" + Scientific + "</i>)"
                                property string appLanguageScientific: switch (language === 4 ? appLanguage : language) {
                                                                       case 0:
                                                                          return Deutsch
                                                                       case 1:
                                                                          return English
                                                                       case 2:
                                                                          return Nederlands
                                                                       case 3:
                                                                          return Dansk
                                }
                                text: (ResultLanguage === 4 ? appLanguageScientific : ResultWord) + wordScientific
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.Wrap
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: parent.ListView.view.currentIndex = index
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
                        else if(event.key === Qt.Key_tab)
                        {
                            nextItemInFocusChain()
                        }
                        else if((event.key === Qt.Key_Tab) && (event.modifiers === Qt.ShiftModifier))
                        {
                            nextItemInFocusChain(false)
                        }
                    }

                    AdaptedText {
                        id: noSearchResults
                        anchors.fill: parent
                        text: qsTr("No matches found!")
                        horizontalAlignment: Text.AlignHCenter
                        anchors.margins: globalMargin
                        visible: false
                    }
                }
            }

            Rectangle {
                id: seperatorLine
                color: "black"
                Layout.preferredWidth: globalBorder
                Layout.fillHeight: true
                visible: resultWidget.visible

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
                property ListView resultListView: /*lvDictionary*/lvVocabulary
                property int fromLanguage: lvDictionary.count > 0 ? (dictionaryModel.data(dictionaryModel.index(resultListView.currentIndex, 6), 6) === 4 ?
                    appLanguage : dictionaryModel.data(dictionaryModel.index(resultListView.currentIndex === -1 ? 0 : resultListView.currentIndex, 6), 6)) : language
                Layout.preferredHeight: resultView.height
                Layout.preferredWidth: resultView.width
                Layout.minimumWidth: parent.width / 4
                Layout.maximumWidth: parent.width / 2
                Layout.fillHeight: true
                Layout.fillWidth: false

                visible: resultListView.count > 0

                Flickable {
                    visible: false
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
                            property int row: resultWidget.resultListView.currentIndex
                            property bool updateText
                            ResultRow {
                                rowLanguage: resultWidget.fromLanguage
                                resize: highDpi ? 1.25 : 1.75
                                scientific: true
                                visible: true
                            }
                            ResultRow {
                                rowLanguage: 0
                            }
                            ResultRow {
                                rowLanguage: 1
                            }
                            ResultRow {
                                rowLanguage: 2
                            }
                            ResultRow {
                                rowLanguage: 3
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
            name: "settings"
            PropertyChanges { target: backArrow; visible: true }
            PropertyChanges { target: activityTitle; text: qsTr("Settings") }
            PropertyChanges { target: settingsWindow; contentY: 0; visible: true; focus: true }
            PropertyChanges { target: gridLayout; visible: false }
        },

        State {
            name: "vocabularyList"
            PropertyChanges { target: activityTitle; text: wadden_sea_wordlist }
            PropertyChanges { target: languageButton; visible: true }
            PropertyChanges { target: lvVocabulary; focus: true; visible: true/*; model: vocabularyModel */}
            PropertyChanges { target: settings; vocabularyList: true }
        },

        State {
            name: "dictionary"
            PropertyChanges { target: activityTitle; text: wadden_sea_dictionary }
            PropertyChanges { target: dictionaryWidget; visible: true; focus: true }
            PropertyChanges { target: resultWidget; resultListView: lvDictionary }
            PropertyChanges { target: settings; vocabularyList: false }
        }
    ]
}
