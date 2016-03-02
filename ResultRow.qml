import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

Row {
    property double resize: highDpi ? 1 : 1.25
    property int rowLanguage
    property int row: parent.row
    property bool scientific: false
    property bool updateText: parent.updateText

    spacing: globalMargin
    visible: resultWidget.fromLanguage !== rowLanguage

    Image {
        id: flag
        height: 4 * resize * globalMargin
        sourceSize.height: height
        sourceSize.width: height / 3 * 5
        source: switch(rowLanguage) {
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
    }

    Column {
        id: languageAndScientific
        anchors.verticalCenter: flag.verticalCenter

        Text {
            property var textCheck: resultWidget.resultListView.model && (updateText || !updateText) ? resultWidget.resultListView.model.data(resultWidget.resultListView.model.index(row, rowLanguage), rowLanguage) : ""
            text: textCheck ? textCheck : "" //der Zwischenschritt über die var-Variable ist notwendig, da es sonst zu errors kommt, wenn das Model leer ist. Einer var kann man gut undefined zuweisen - einem String nicht
            font.pointSize: (resize <= 0 ? 1 : resize) * fontHeight.font.pointSize //dieses völlig bescheuerte Konstrukt um resize ist Compiler-Errors geschuldet
        }
        
        Text {//Scientific
            property var textCheck: resultWidget.resultListView.model && (updateText || !updateText) ? resultWidget.resultListView.model.data(resultWidget.resultListView.model.index(row, 4), 4) : ""
            text: textCheck ? textCheck : ""
            visible: scientific && text.length > 0
            font.italic: true
            font.pointSize: ((resize <= 0 ? 1 : resize) - 0.5) * fontHeight.font.pointSize
        }
    }
}
