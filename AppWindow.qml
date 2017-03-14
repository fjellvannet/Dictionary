import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
Window {
    id: root
    title: Qt.application.name

    onClosing: Qt.quit();

    Material.theme: Material.Light
    Material.accent: Material.Blue

    property color dark_accent: Material.color(Material.BlueGrey, Material.Shade700)
    property double rootSize: settings.sized

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

    property int globalMargin: fontHeight.height / 2
    property int globalFontPixelSize: fontHeight.font.pixelSize
    property int globalBorder: globalMargin / 10 > 1 ? globalMargin / 10 : 1
    property bool highDpi: Math.max(Screen.height, Screen.width) / globalMargin < 100
    property bool vocabularyList: false
    property int language: appLanguage

    property string wadden_sea_wordlist: qsTr("Wadden Sea wordlist")
    property string wadden_sea_dictionary: qsTr("Wadden Sea dictionary")

    function nextLanguage() {
        if(language < 3) language++;
        else language = 0;
    }

    Image {
        anchors.fill: parent
        source: "qrc:/images/background/background"
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
            Layout.preferredHeight: globalMargin *(highDpi ? 6 : 11)
            //color: medium_blue

            RowLayout {
                anchors.fill: parent
                anchors.margins: parent.height / 8
                spacing: parent.height / 8
                IconButton {
                    id: stateButton
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    source: "qrc:/images/icons/arrow"

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
                    background: AdaptedImage {
                        anchors.fill: parent
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
                    }
                    ColorOverlay {
                        anchors.fill: parent
                        source: parent.background
                        color: "black"
                        opacity: 0.15
                        visible: languageButton.visualFocus
                    }

                    signal sortBy(var role)

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
                    source: "qrc:/images/icons/settings"
                    onClicked: {
                        mainlayout.state = mainlayout.state === "settings" ? (settings.vocabularyList ? "vocabularyList" : "dictionary") : "settings"
                    }
                }
            }
        }

        Rectangle {
            color: "black"
            Layout.fillWidth: true
            Layout.preferredHeight: globalBorder
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
                    x: globalMargin
                    width: parent.width - 2*x
                    spacing: globalMargin

                    Item{Layout.fillWidth: true}

                    AdaptedText {
                        Layout.fillWidth: true
                        text: qsTr("Layout size")
                        font.pixelSize: 1.2 * globalFontPixelSize
                        font.bold: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: globalMargin
                        TextButton {
                            onClicked: sizeSlider.value = defaultFontHeight.font.pixelSize
                            text: qsTr("Default")
                        }

                        Item{height: 1}//Abstandhalter

                        TextButton {
                            onClicked: sizeSlider.decrease()
                            text: "–"
                        }

                        Slider {
                            id: sizeSlider
                            from: defaultFontHeight.font.pixelSize * Math.max(6/defaultFontHeight.font.pointSize, 0.5)//den minste verdien skal enten være 6 point eller halvparten av originalfonten (det som er størst av de)
                            to: {
                                if(root.height == 0) return 1000
                                else return Math.max(Math.min(root.height, root.width) / 17, from)
                            }
                            stepSize: 1
                            Layout.fillWidth: true
                            implicitHeight: focus_indicator.height - 1.5 * globalMargin

                            value: defaultFontHeight.font.pixelSize

                            handle: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                color: Material.accent
                                height: 2.5 * globalMargin
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
                                height: globalMargin
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

                    Rectangle {
                        color: "black"
                        Layout.fillWidth: true
                        Layout.preferredHeight: globalBorder
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
                        Layout.preferredHeight: globalBorder
                    }

                    AdaptedText {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                        text:
                            qsTr("<h3>Impressum</h3><p>During my Voluntary ecological year (FÖJ, Germany) 2015/16 \
                            at the Wadden Sea Centre in Vester Vedsted, Denmark, I have programmed this dictionary. \
                            For that, I used %1. The sourcecode is available on %2.</p>\
                            <p>For suggestions and error-reports, send me (Lukas Neuenschwander) an e-mail (%3). Here \
                            you can also suggest missing words that you would like to have added to the dictionary.</p>\
                            <p>The data for this app is taken from the \"IWSS Wadden Sea Dictionary\" (%4) - with the \
                            permission from the \"International Wadden Sea School\" (%5).</p>\
                            <p>Icon for settings made by %6, icon for downarrow mady by %7. Both come from %8, licensed by %9.</p>\
                            <p>Background image taken by Lukas Neuenschwander on the southern beach of Rømø, on March 12<sup>th</sup> 2016.</p>")

                            .arg("Qt 5.8-Open-Source")
                            .arg("<a href=\"https://github.com/fjellvannet/Wadden-Sea-Dictionary\">www.github.com/fjellvannet/Wadden-Sea-Dictionary</a>")
                            .arg("<a href=\"mailto:fjellvannet@gmail.com\">fjellvannet@gmail.com</a>")
                            .arg("<a href=\"http://www.iwss.org/fileadmin/uploads/network-download/Education_\
                            _Support/IWSS_Dictionary_2009.pdf\">http://www.iwss.org/fileadmin/uploads/network\
                            -download/Education__Support/IWSS_Dictionary_2009.pdf</a>")
                            .arg("<a href=\"http://www.iwss.org/\">www.iwss.org</a>")
                            .arg("<a href=\"http://www.freepik.com\" title=\"Freepik\">Freepik</a>")
                            .arg("<a href=\"http://www.flaticon.com/authors/dave-gandy\" title=\"Dave Gandy\">Dave Gandy</a>")
                            .arg("<a href=\"http://www.flaticon.com\" title=\"Flaticon\">www.flaticon.com</a>")
                            .arg("<a href=\"http://creativecommons.org/licenses/by/3.0/\" title=\"Creative Commons BY 3.0\" target=\"_blank\">CC 3.0 BY</a>")
                        onLinkActivated: Qt.openUrlExternally(link)
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
                flow:  height < 1.8 * resultView.height ? GridLayout.LeftToRight : GridLayout.TopToBottom
                rowSpacing: 0
                columnSpacing: 0

                ListView {
                    objectName: "lvVocabulary"
                    id: lvVocabulary
                    visible: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    maximumFlickVelocity: defaultFontHeight.height * 500
                    activeFocusOnTab: true
                    flickDeceleration: maximumFlickVelocity / 2
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    //snapMode: ListView.SnapToItem scrollen ist dann einfach nicht mehr smooth...
                    ScrollBar.vertical: AdaptedScrollBar {}

                    model: vocabularyModel

                    function updateView(){
                        visible = false
                        languageButton.sortBy(language)
                        positionViewAtEnd()
                        positionViewAtBeginning()
                        currentIndex = 0
                        resultColumn.updateText = !resultColumn.updateText//damit ResultWidget aktualisiert und ggf ausgeblendet wird
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
                        color: dark_accent
                        width: window.width
                        height: 4 * globalMargin
                        AdaptedText {
                            anchors.left: parent.left
                            anchors.leftMargin: globalMargin / 2
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
                        height: Math.max(4 * globalMargin, word.implicitHeight + globalMargin)
                        color: "transparent"
                        AdaptedText {
                            id: word
                            anchors.left: parent.left; anchors.right: parent.right
                            anchors.leftMargin: globalMargin / 2
                            text: {
                                var s
                                switch(language){
                                    case 0: s = Deutsch; break
                                    case 1: s = English; break
                                    case 2: s = Nederlands; break
                                    case 3: s = Dansk; break
                                    case undefined: s = ""
                                }
                                return s + (Scientific === "" ? "" : " (<i>" + Scientific + "</i>)")
                            }
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
                        visible: parent.verticalVelocity >= parent.maximumFlickVelocity / 4 || parent.verticalVelocity <= -parent.maximumFlickVelocity / 4
                        anchors.centerIn: parent
                        text: parent.currentSection
                        color: "white"
                        font.pixelSize: 3 * globalFontPixelSize
                    }

                    MouseArea {//Stellt sicher, dass mit dem Mausrad nicht zu schnell gescrollt wird - wie schnell kann eingestellt werden
                        anchors.fill: parent
                        onWheel: parent.flick(0, wheel.angleDelta.y * defaultFontHeight.height / 1.5);/*Gegebenenfalls könnte man über eine Einstellung
                             für diesen Wert nachdenken. So ist er jetzt aber genau an Windows angepasst, hoffe dass es in Mac auch läuft.*/
                        scrollGestureEnabled: false
                        propagateComposedEvents: true//damit die Klicks an die darunter liegenden MouseAreas weitergeleitet werden.
                    }

                    Keys.onReleased: {
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
                        Layout.margins: globalMargin

                        border.width: 2 * globalBorder
                        border.color: Material.accent
                        radius: height / 4
                        color: "transparent"
                        RowLayout
                        {
                            anchors.fill: parent
                            anchors.margins: parent.height / 5
                            spacing: parent.height / 10

                            Button {
                                id: magnifying_glass
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                activeFocusOnTab: false
                                background: AdaptedImage {
                                    source: "qrc:/images/icons/magnifying_glass"
                                }
                                onClicked: searchField.performSearch()
                                ColorOverlay {
                                    anchors.fill: parent.background
                                    source: parent.background
                                    color: Material.accent
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

                                signal textChanged(var text, var findUmlauts)
                                property string dbcurrentquery

                                AdaptedText {
                                    anchors.fill: parent
                                    text: qsTr("Search")
                                    color: "#888"
                                    visible: !parent.focus && parent.length === 0
                                    verticalAlignment: Text.AlignVCenter
                                }
                                //property double starttime
                                function performSearch() {
                                    //starttime = new Date().getTime();
                                    if(text !== dbcurrentquery)//verhindert, dass der gleiche Begriff 2x gesucht wird
                                    {
                                        dbcurrentquery = text
                                        searchField.textChanged(searchField.text, settings.findUmlauts)
                                        lvDictionary.currentIndex = 0
                                    }
                                    //console.log("Die Suche & Anzeige von " + text + " dauerte " + (new Date().getTime() - starttime) + " ms")
                                    if(length > 0)
                                    {
                                        noSearchResults.visible = lvDictionary.count === 0
                                        if(!noSearchResults.visible) lvDictionary.forceActiveFocus()
                                    }
                                    resultColumn.updateText = !resultColumn.updateText//damit ResultWidget aktualisiert und ggf ausgeblendet wird
                                }

                                onEditingFinished: performSearch()
                            }
                            Button {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                visible: searchField.length !== 0
                                activeFocusOnTab: false
                                background: AdaptedImage {
                                    source: "qrc:/images/icons/cross_searchfield"
                                }
                                onClicked: {
                                    searchField.text = ""
                                    searchField.performSearch()
                                    searchField.forceActiveFocus()
                                }
                                ColorOverlay {
                                    anchors.fill: parent.background
                                    source: parent.background
                                    color: Material.accent
                                }
                            }
                        }

                    }

                    Rectangle {
                        id: seperatorLine
                        color: "black"
                        Layout.fillWidth: true
                        Layout.preferredHeight: globalBorder
                    }

                    ListView {
                        id: lvDictionary
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        boundsBehavior: ListView.StopAtBounds
                        //snapMode: ListView.SnapToItem funktioniert nicht gut, scrollen ist dann überhaupt nicht mehr smooth
                        maximumFlickVelocity: defaultFontHeight.height * 500
                        flickDeceleration: maximumFlickVelocity / 2
                        ScrollBar.vertical: AdaptedScrollBar {}
                        activeFocusOnTab: count > 0
                        model: dictionaryModel

                        delegate: Rectangle {
                            id: dictionaryDelegate
                            width: lvDictionary.width
                            height: Math.max(4*globalMargin, dictionaryWord.contentHeight + globalMargin)
                            color: "transparent"
                            RowLayout {
                                id: rl
                                y: globalMargin / 2
                                anchors.margins: globalMargin / 2
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: globalMargin / 2

                                AdaptedImage {
                                    visible: settings.flags_in_all_language_mode
                                    Layout.preferredHeight: 3 * globalMargin
                                    Layout.preferredWidth: 5 * globalMargin
                                    Layout.alignment: Qt.AlignVCenter
                                    source: {
                                        var a = ResultLanguage
                                        if(a === 4) a = appLanguage
                                        switch(a) {
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
                                    }
                                }

                                AdaptedText {
                                    visible: !settings.flags_in_all_language_mode
                                    Layout.preferredWidth: 4 * globalMargin
                                    Layout.alignment: Qt.AlignVCenter
                                    font.pixelSize: 3 * globalMargin
                                    color: dark_accent
                                    text:{
                                        var a = ResultLanguage
                                        if(a === 4) a = appLanguage
                                        switch(a){
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
                                    }
                                }

                                AdaptedText {
                                    id: dictionaryWord
                                    Layout.fillWidth: true
                                    text: {
                                        var a = ResultLanguage
                                        if(a === 4) a = appLanguage
                                        var s
                                        switch(a){
                                            case 0: s = Deutsch; break
                                            case 1: s = English; break
                                            case 2: s = Nederlands; break
                                            case 3: s = Dansk; break
                                            default: s = ""
                                        }
                                        return s + (Scientific === "" ? "" : " (<i>" + Scientific + "</i>)")
                                    }
                                    Layout.alignment: Qt.AlignVCenter
                                    wrapMode: Text.Wrap
                                }
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

                        Keys.onReleased: {
                            if(event.key === Qt.Key_Up || event.key === Qt.Key_Down) positionViewAtIndex(currentIndex, ListView.Center)
                            else if(event.key === Qt.Key_Home) { currentIndex = 0; positionViewAtBeginning()}
                            else if(event.key === Qt.Key_End) { currentIndex = count - 1; positionViewAtEnd()}
                        }

                        MouseArea {//Stellt sicher, dass mit dem Mausrad nicht zu schnell gescrollt wird - wie schnell kann eingestellt werden
                            anchors.fill: parent
                            onWheel: parent.flick(0, wheel.angleDelta.y * defaultFontHeight.height / 1.5);/*Gegebenenfalls könnte man über eine Einstellung
                                 für diesen Wert nachdenken. So ist er jetzt aber genau an Windows angepasst, hoffe dass es in Mac auch läuft.*/
                            scrollGestureEnabled: false
                            propagateComposedEvents: true//damit die Klicks an die darunter liegenden MouseAreas weitergeleitet werden.
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
                    color: "black"
                    Layout.preferredHeight: globalBorder
                    Layout.fillWidth: true
                    visible: gridLayout.flow === GridLayout.TopToBottom && seperatorLine.visible
                }

                Item {
                    id: resultWidget
                    property ListView resultListView: lvVocabulary
                    property int fromLanguage: {
                        if(lvDictionary.visible && lvDictionary.count > 0 && dictionaryModel.index(resultListView.currentIndex, 6) < 4)
                            return dictionaryModel.data(resultListView.currentIndex, 6)
                        else return language;
                    }
                    Layout.preferredHeight: resultView.height
//                    Layout.preferredWidth: resultView.width
//                    Layout.minimumWidth: parent.width / 4
//                    Layout.maximumWidth: parent.width / 2
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
                PropertyChanges { target: activityTitle; text: qsTr("Settings") }
                PropertyChanges { target: settingsWindow; contentY: 0; visible: true; focus: true }
                PropertyChanges { target: gridLayout; visible: false }
                PropertyChanges { target: stateButton; source: "qrc:/images/icons/arrow" }
            },

            State {
                name: "vocabularyList"
                PropertyChanges { target: activityTitle; text: wadden_sea_wordlist }
                PropertyChanges { target: languageButton; visible: true }
                PropertyChanges { target: lvVocabulary; focus: true; visible: true/*; model: vocabularyModel */}
                PropertyChanges { target: stateButton; source: "qrc:/images/icons/magnifying_glass" }
                StateChangeScript { script: { lvVocabulary.updateView(); lvVocabulary.forceActiveFocus() } }
            },

            State {
                name: "dictionary"
                PropertyChanges { target: activityTitle; text: wadden_sea_dictionary }
                PropertyChanges { target: dictionaryWidget; visible: true; focus: true }
                PropertyChanges { target: resultWidget; resultListView: lvDictionary }
                PropertyChanges { target: stateButton; source: "qrc:/images/icons/alphabetic" }
                PropertyChanges { target: seperatorLine; visible: lvDictionary.contentHeight > lvDictionary.height }
                StateChangeScript { script: { searchField.forceActiveFocus() } }
            }
        ]
    }
}
