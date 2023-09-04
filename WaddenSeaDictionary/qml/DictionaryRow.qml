import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

RowLayout{
    y: em / 2
    anchors.margins: y
    spacing: y
    property int baseHeight: em
    property alias textHeight: dictionaryWord.contentHeight

    FlagImage {
        visible: settings.flags_in_all_language_mode
        Layout.preferredHeight: baseHeight
        Layout.preferredWidth: 5 * baseHeight / 3
        Layout.alignment: Qt.AlignVCenter
        languageId: {
            var a = ResultLanguage
            if(a === 4) a = appLanguage
            return a
        }
    }

    AdaptedText {
        visible: !settings.flags_in_all_language_mode
        Layout.preferredWidth: 4/3 * baseHeight
        Layout.alignment: Qt.AlignVCenter
        font.pixelSize: baseHeight
        Layout.preferredHeight: baseHeight
        verticalAlignment: Text.AlignVCenter
        color: dark_accent
        text: {
            var a = ResultLanguage
            if(a === 4) a = appLanguage
            switch(a) {
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
