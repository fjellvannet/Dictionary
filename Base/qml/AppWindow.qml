import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Effects
import QtCore
import QtQuick.Window
import Qt.labs.animation

Item {
    id: root
    height: Window.height
    width: Window.width

    Constants{id: constants}
    property alias dark_accent: constants.dark_accent
    property double rootSize: settings.sized

    Material.theme: Material.Light
    Material.accent: constants.materialAccent

    AdaptedText {
        id: fontHeight
        visible: false
    }

    Text {
        id: defaultFontHeight
        visible: false
    }

    Settings {
        id: settings
        property alias sized: sizeSlider.value
        property alias flags_in_all_language_mode: swFlags_in_all_language_mode.checked
        property alias findUmlauts: swUmlauts.checked
        property alias language: root.language
        property alias vocabularyList: root.vocabularyList
    }

    property int em: fontHeight.height
    property int mg: fontHeight.height / 2
    property int globalFontPixelSize: fontHeight.font.pixelSize
    property int px: em / 20 > 1 ? em / 20 : 1
    readonly property real tabColorIntensity: 0.3
    readonly property bool highDpi: Math.max(Screen.height, Screen.width) / em < 50
    property bool vocabularyList: true
    property int language: appLanguage

    function nextLanguage() {
        if(language === constants.antallSpraak - 1) language = 0;
        else language++;
    }

//    ProgressDialog {
//        id: pd
//        title: qsTr("Updating wordlist")
//        cancelQuestion: qsTr("Are you sure that you want to cancel updating? You will be able to continue later.")

//        function updateWordList() {
//            pd.openProgressDialog()
//            databaseManager.startWordListUpdate()
//        }

//        onCancelOperation: {
//            databaseManager.cancelWordListUpdate()
//        }

//        Connections {
//            target: databaseManager
//            onWordListUpdateCompleted: {
//                pd.setFinished(message)
//            }

//            onSendCurrentStep: {
//                pd.setCurrentStep(currentStep)
//            }

//            onSendCurrentStepProgress: {
//                if (formattedValue === "0 %" || (formattedValue === "" && value === -1)) {
//                    pd.setCurrentStepProgress(value, formattedValue)
//                } else {
//                    var splitValueStats = formattedValue.arg(5 * em).split("\n")
//                    pd.setCurrentStepProgress(value, splitValueStats[0])
//                    if (splitValueStats[0]) pd.setCurrentStepStatistics(splitValueStats[1])
//                }
//            }
//        }
//    }

    Image {
        anchors.fill: parent
        source: "qrc:/qt/qml/Dictionary/images/background/background.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.3
    }

    ColumnLayout{
        id: mainlayout
        anchors.fill: parent
        spacing: 0
        z: parent.z + 1
        state: settings.vocabularyList ? "vocabularyList" : "dictionary"

        Item{//Menubar
            Layout.fillWidth: true
            Layout.preferredHeight: em * (highDpi ? 3 : 6)
            //color: medium_blue

            RowLayout {
                anchors.fill: parent
                anchors.margins: parent.height / 8
                spacing: parent.height / 8
                IconButton {
                    id: stateButton
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    src: "qrc:/qt/qml/Dictionary/images/icons/arrow.svg"

                    onClicked: {
                        if(mainlayout.state !== "settings")
                        {
                            settings.vocabularyList = !settings.vocabularyList
                        }
                        mainlayout.state = settings.vocabularyList ? "vocabularyList" : "dictionary"
                    }
                }

                Button {
                    visible: false
                    id: languageButton
                    objectName: "LanguageButton"
                    Layout.fillHeight: true
                    Layout.preferredWidth: height / 3 * 5

                    background: Item{}
                    FlagImage {
                        id: fi
                        anchors.fill: parent
                    }
                    MultiEffect {
                        anchors.fill: parent
                        source: fi
                        colorizationColor: "black"
                        colorization: tabColorIntensity
                        visible: parent.visualFocus
                    }

                    onClicked: {
                        lvVocabulary.visible = false
                        nextLanguage()
                        lvVocabulary.updateView()
                    }

                    Keys.onBackPressed: {
                        event.accepted = true
                        mainlayout.state = settings.vocabularyList ? "vocabularyList" : "dictionary"
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
                    text: Qt.application.name
                    elide: Text.ElideMiddle
                    opacity: truncated ? 0 : 1
                }

                IconButton {
                    id: settingsButton
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignRight
                    src: "qrc:/qt/qml/Dictionary/images/icons/settings.svg"
                    onClicked: {
                        mainlayout.state = mainlayout.state === "settings" ? (settings.vocabularyList ? "vocabularyList" : "dictionary") : "settings"
                    }
                }
            }
        }

        Rectangle {//separating line between search-items and top meny
            color: "black"
            Layout.fillWidth: true
            Layout.preferredHeight: px
            visible: mainlayout.state === "settings" && settingsWindow.contentHeight > settingsWindow.height
        }

        Item {
            id: window
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                id: settingsWindow
                anchors.fill: parent
                contentHeight: settingsColumn.height
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick
                ScrollBar.vertical: AdaptedScrollBar {}
                visible: false
                clip: true

                ColumnLayout {
                    id: settingsColumn
                    x: mg
                    width: parent.width - 2*x
                    spacing: mg

                    Item{Layout.fillWidth: true}

                    AdaptedText {
                        Layout.fillWidth: true
                        text: qsTr("Layout size")
                        font.pixelSize: 1.2 * globalFontPixelSize
                        font.bold: true
                    }

                    GridLayout {
                        flow:  tbDefault.implicitWidth > parent.width / 3.5 ? GridLayout.TopToBottom : GridLayout.LeftToRight
                        rowSpacing: mg
                        columnSpacing: mg

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            TextButton {
                                onClicked: sizeSlider.decrease()
                                text: "–"
                            }

                            Slider {
                                id: sizeSlider
                                from: defaultFontHeight.font.pixelSize * Math.max(6/defaultFontHeight.font.pointSize, 0.5)//den minste verdien skal enten være 6 point eller halvparten av originalfonten (det som er størst av de)
                                to: {
                                    if(!root.height) return 1000
                                    else return Math.max(Math.min(root.height, root.width) / 17, from)
                                }
                                stepSize: 1
                                Layout.fillWidth: true
                                implicitHeight: focus_indicator.height - 0.75 * em

                                value: defaultFontHeight.font.pixelSize

                                handle: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Material.accent
                                    height: 1.25 * em
                                    width: height
                                    radius: height / 2
                                    x: (focus_indicator.height - height)/2 + parent.visualPosition * (parent.background.width - parent.background.height)
                                }

                                Rectangle {
                                    id: focus_indicator
                                    visible: parent.visualFocus
                                    anchors.centerIn: parent.handle
                                    color: Material.accent
                                    opacity: 0.3
                                    height: 2 * parent.handle.height
                                    radius: height/2
                                    width: height
                                    z: parent.handle.z - 1
                                }

                                background: RowLayout {
                                    spacing: 0
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: (focus_indicator.height - height)/2; anchors.rightMargin: anchors.leftMargin
                                    height: mg
                                    width: parent.width - 2*x
                                    opacity: 0.5
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: sizeSlider.visualPosition * parent.width
                                        radius: height / 2
                                        color: Material.accent
                                    }
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        radius: height / 2
                                        color: Material.color(Material.Grey, Material.Shade700)
                                    }
                                }
                            }

                            TextButton {
                                onClicked: sizeSlider.increase()
                                text: "+"
                            }
                        }

                        TextButton {
                            id: tbDefault
                            onClicked: sizeSlider.value = defaultFontHeight.font.pixelSize
                            text: qsTr("Default")
                            Layout.fillWidth: parent.flow === GridLayout.TopToBottom
                        }
                    }

                    Rectangle {
                        color: "black"
                        Layout.fillWidth: true
                        Layout.preferredHeight: px
                    }

                    AdaptedText {
                        text:  qsTr("Dictionary Search")
                        Layout.fillWidth: true
                        font.pixelSize: 1.2 * globalFontPixelSize
                        font.bold: true
                    }

                    AdaptedSwitch {
                        id: swUmlauts
                        text: qsTr("Find æ, ø, å, ä, ö, ü, ß when searching a, o, u or ss (mowe finds Möwe, weiss finds weiß)")
                        checked: true
                        Layout.fillWidth: true
                    }

                    AdaptedSwitch {
                        id: swFlags_in_all_language_mode
                        text: qsTr("Show flags in dictionary search results (might make search slower%1)").arg("")//qsTr(", experimental"))
                        checked: true //in Android experimental einsetzen und die Standardeinstellung auf false
                        Layout.fillWidth: true
                    }


                    Rectangle {
                        color: "black"
                        Layout.fillWidth: true
                        Layout.preferredHeight: px
                    }

//                    RowLayout {
//                        id: db_settings
//                        visible: constants.isBuchmaal

//                        AdaptedText {
//                            Layout.fillWidth: true
//                            objectName: "db_update"
//                            id: db_update
//                            wrapMode: Text.WordWrap
//                            text: databaseManager.wordListLastUpdated ?
//                                      qsTr("<h3>Database</h3><p>Last updated: %1</p>")
//                                      .arg(databaseManager.wordListLastUpdated.toLocaleString()) :
//                                      qsTr("<h3>Database</h3>")
//                        }

//                        TextButton {
//                            id: btnUpdateWordList
//                            text: databaseManager.wordListLastUpdated ? qsTr("Update wordlist") :
//                                                                        qsTr("Initialize wordlist")
//                            onClicked: pd.updateWordList()
//                        }
//                    }

//                    Rectangle {
//                        visible: constants.isBuchmaal
//                        color: "black"
//                        Layout.preferredHeight: px
//                        Layout.fillWidth: true
//                    }

                    AdaptedImage {
                        source: "qrc:/qt/qml/Dictionary/images/icons/app_icon.svg"
                        Layout.preferredWidth: Math.min(10 * em, parent.width)
                        Layout.preferredHeight: Math.min(10 * em, parent.width)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    AdaptedText {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                        text: constants.impressum
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }

                    AdaptedText {
                        objectName: "license"
                        Layout.fillWidth: true
                        wrapMode:  Text.WordWrap
                        textFormat: Text.MarkdownText
                    }

                    Item{Layout.fillWidth: true}
                }

                Keys.onBackPressed: {
                    event.accepted = true
                    mainlayout.state = settings.vocabularyList ? "vocabularyList" : "dictionary"
                }
            }

            GridLayout {
                id: gridLayout
                anchors.fill: parent
                flow:  height < 2 * resultView.height ? GridLayout.LeftToRight : GridLayout.TopToBottom
                rowSpacing: 0
                columnSpacing: 0

                ListView {
                    objectName: "lvVocabulary"
                    id: lvVocabulary
                    visible: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    maximumFlickVelocity: em * 500
                    activeFocusOnTab: true
                    flickDeceleration: maximumFlickVelocity / 2
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    //snapMode: ListView.SnapToItem scrollen ist dann einfach nicht mehr smooth...
                    ScrollBar.vertical: AdaptedScrollBar {id: vocScrollBar}

                    model: vocabularyModel

                    function updateView(){
                        visible = false
                        vocabularyModel.sortBy(language)
                        positionViewAtEnd()
                        positionViewAtBeginning()
                        currentIndex = 0
                        resultView.updateText = !resultView.updateText//damit ResultWidget aktualisiert und ggf ausgeblendet wird
                        visible = true
                    }

                    section.labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
                    section.property: constants.sectionLetter

                    section.delegate: Rectangle {
                        id: sectionDelegate
                        color: dark_accent
                        width: window.width
                        height: 2 * em
                        AdaptedText {
                            anchors.left: parent.left
                            anchors.leftMargin: mg
                            id: text
                            text: section
                            font.bold: true
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 1.5 * globalFontPixelSize
                            color: "white"
                        }
                    }

                    delegate: Rectangle {
                        id: wordDelegate
                        width: lvVocabulary.width
                        height: Math.max(1.5 * em, word.implicitHeight + mg)
                        color: "transparent"

                        WordDelegateText{
                            id: word
                            anchors.left: parent.left; anchors.right: parent.right
                            anchors.leftMargin: em / 4
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.Wrap
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                lvVocabulary.currentIndex = index
                                lvVocabulary.forceActiveFocus()
                            }
                        }
                        states: State {
                            when: wordDelegate.ListView.isCurrentItem
                            PropertyChanges { target: wordDelegate; color: languageButton.background.ios || lvVocabulary.activeFocus ? Material.accent : Material.color(Material.Grey)}
                        }
                    }

                    Rectangle {
                        z: sectionLetter.z - 1 //sonst verschwindet es hinter den Delegates...
                        visible: sectionLetter.visible
                        height: 2 * sectionLetter.height
                        width: height
                        color: Material.accent
                        opacity: 0.5
                        anchors.centerIn: parent
                        radius: height / 6
                    }

                    AdaptedText {
                        id: sectionLetter
                        z: parent.delegate.z + 2
                        visible: false
                        anchors.centerIn: parent
                        text: parent.currentSection
                        color: "white"
                        font.pixelSize: 3 * globalFontPixelSize
                        Timer {
                            id: tm
                            interval: 200
                            onTriggered: sectionLetter.visible=false
                        }
                    }

                    ScrollMouseArea {
                        onWheel: function(wheel){
                            vocScrollBar.show()
                            let speed = performScroll(wheel) / 2
                            if (!visible && Math.abs(speed) >= parent.maximumFlickVelocity / 100)
                                visible = true
                            else if (sectionLetter.visible && Math.abs(speed) <= parent.maximumFlickVelocity / 250)
                                visible = false
                            tm.restart()
                        }
                    }

                    onVerticalVelocityChanged: {
                        sectionLetter.visible = Math.abs(verticalVelocity) >= maximumFlickVelocity / 4
                    }

                    Keys.onReleased: function(event){
                        if(event.key === Qt.Key_Up || event.key === Qt.Key_Down) positionViewAtIndex(currentIndex, ListView.Center)
                        else if(event.key === Qt.Key_Home) { currentIndex = 0; positionViewAtBeginning()}
                        else if(event.key === Qt.Key_End) { currentIndex = count - 1; positionViewAtEnd()}
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
                        Layout.margins: mg

                        border.width: 2 * px
                        border.color: Material.accent
                        radius: height / 4
                        color: "transparent"
                        RowLayout
                        {
                            anchors.fill: parent
                            anchors.margins: parent.height / 5
                            spacing: parent.height / 10
                            Button {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                activeFocusOnTab: false
                                background: Item{}
                                AdaptedImage {
                                    anchors.fill: parent
                                    id: magnifying_glass_image
                                    source: "qrc:/qt/qml/Dictionary/images/icons/magnifying_glass.svg"
                                }
                                onClicked: searchField.performSearch()
                                MultiEffect {
                                    anchors.fill: magnifying_glass_image
                                    source: magnifying_glass_image
                                    colorizationColor: Material.accent
                                    colorization: 1
                                }
                            }

                            TextInput {
                                id: searchField
                                objectName: "SearchField"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.rightMargin: 1
                                activeFocusOnTab: true
                                clip: true
                                inputMethodHints: Qt.ImhNoPredictiveText
                                verticalAlignment: Text.AlignVCenter
                                font: fontHeight.font
                                selectByMouse: true
                                property string dbcurrentquery

                                AdaptedText {
                                    anchors.fill: parent
                                    text: qsTr("Search")
                                    color: "#888"
                                    visible: !parent.focus && parent.length === 0
                                    verticalAlignment: Text.AlignVCenter
                                }
                                function performSearch() {
                                    if(searchField.text !== dbcurrentquery)//verhindert, dass der gleiche Begriff 2x gesucht wird
                                    {
                                        dbcurrentquery = text
                                        dictionaryModel.search(searchField.text, settings.findUmlauts)
                                        lvDictionary.currentIndex = 0
                                        if(length > 0)
                                        {
                                            noSearchResults.visible = lvDictionary.count === 0
                                        }
                                        resultView.updateText = !resultView.updateText//damit ResultWidget aktualisiert und ggf ausgeblendet wird
                                    }
                                }
                                onTextEdited: performSearch()

                                onEditingFinished: {
                                    performSearch()
                                    if(lvDictionary.count > 0) lvDictionary.forceActiveFocus()
                                }
                            }
                            Button {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                visible: searchField.length !== 0
                                activeFocusOnTab: false
                                background: Item{}
                                AdaptedImage {
                                    anchors.centerIn: parent
                                    id: ai
                                    width: parent.height * 3/4
                                    height: width
                                    source: "qrc:/qt/qml/Dictionary/images/icons/cross_searchfield.svg"
                                }
                                onClicked: {
                                    searchField.text = ""
                                    searchField.performSearch()
                                    searchField.forceActiveFocus()
                                }
                                MultiEffect {
                                    anchors.fill: ai
                                    source: ai
                                    colorizationColor: Material.accent
                                    colorization: 1
                                }
                            }
                        }

                    }

                    Rectangle {
                        id: seperatorLine
                        color: "black"
                        Layout.fillWidth: true
                        Layout.preferredHeight: px
                    }

                    ListView {
                        id: lvDictionary
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        boundsBehavior: ListView.StopAtBounds
                        //snapMode: ListView.SnapToItem funktioniert nicht gut, scrollen ist dann überhaupt nicht mehr smooth
                        maximumFlickVelocity: em * 500
                        flickDeceleration: maximumFlickVelocity / 2
                        ScrollBar.vertical: AdaptedScrollBar {id: dictScrollBar}
                        activeFocusOnTab: count > 0
                        model: dictionaryModel

                        delegate: Rectangle {
                            id: dictionaryDelegate
                            width: lvDictionary.width
                            height: Math.max(rl.baseHeight + mg, rl.textHeight + mg)
                            color: "transparent"

                            DictionaryRow {
                                id: rl
                                anchors.left: parent.left
                                anchors.right: parent.right
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    lvDictionary.currentIndex = index
                                    lvDictionary.forceActiveFocus()
                                }
                            }

                            states: State {
                                when: dictionaryDelegate.ListView.isCurrentItem
                                PropertyChanges { target: dictionaryDelegate; color: languageButton.background.ios || lvDictionary.activeFocus ? Material.accent : Material.color(Material.Grey); z: 4 }
                            }
                        }

                        Keys.onReleased: function(event) {
                            if(event.key === Qt.Key_Up || event.key === Qt.Key_Down) positionViewAtIndex(currentIndex, ListView.Center)
                            else if(event.key === Qt.Key_Home) { currentIndex = 0; positionViewAtBeginning()}
                            else if(event.key === Qt.Key_End) { currentIndex = count - 1; positionViewAtEnd()}
                        }

                        ScrollMouseArea {
                            onWheel: {
                                performScroll()
                                dictScrollBar.show()
                            }
                        }

                        AdaptedText {
                            id: noSearchResults
                            anchors.fill: parent
                            text: qsTr("No matches found!")
                            horizontalAlignment: Text.AlignHCenter
                            anchors.margins: mg
                            visible: false
                        }
                    }
                }

                Rectangle {
                    color: "black"
                    Layout.preferredHeight: px
                    Layout.fillWidth: true
                    visible: gridLayout.flow === GridLayout.TopToBottom && resultWidget.resultListView.contentHeight > resultWidget.resultListView.height
                }

                Item {
                    id: resultWidget
                    property ListView resultListView: lvVocabulary
                    Layout.preferredHeight: resultView.height
                    Layout.preferredWidth: parent.width / 2
                    Layout.fillHeight: true
                    Layout.fillWidth: false

                    visible: resultListView.count > 0

                    Flickable {
                        anchors.fill: parent
                        contentWidth: resultView.width; contentHeight: resultView.height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.horizontal: AdaptedScrollBar {}
                        ScrollBar.vertical: AdaptedScrollBar {}
                        ResultView {
                            id: resultView
                            updateText: true
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
                PropertyChanges { target: activityTitle; text: qsTr("Settings") }
                PropertyChanges { target: settingsWindow; contentY: 0; visible: true; focus: true }
                PropertyChanges { target: gridLayout; visible: false }
                PropertyChanges { target: stateButton; src: "qrc:/qt/qml/Dictionary/images/icons/arrow.svg" }
            },

            State {
                name: "vocabularyList"
                PropertyChanges { target: activityTitle; text: constants.wordlist}
                PropertyChanges { target: languageButton; visible: true }
                PropertyChanges { target: lvVocabulary; focus: true; visible: true/*; model: vocabularyModel */}
                PropertyChanges { target: stateButton; src: "qrc:/qt/qml/Dictionary/images/icons/magnifying_glass.svg" }
                StateChangeScript { script: { lvVocabulary.updateView(); lvVocabulary.forceActiveFocus() } }
            },

            State {
                name: "dictionary"
                PropertyChanges { target: activityTitle; text: constants.dictionary }
                PropertyChanges { target: dictionaryWidget; visible: true; focus: true }
                PropertyChanges { target: resultWidget; resultListView: lvDictionary }
                PropertyChanges { target: stateButton; src: "qrc:/qt/qml/Dictionary/images/icons/alphabetic.svg" }
                PropertyChanges { target: seperatorLine; visible: lvDictionary.contentHeight > lvDictionary.height }
                StateChangeScript { script: { searchField.forceActiveFocus() } }
            }
        ]
    }
}
