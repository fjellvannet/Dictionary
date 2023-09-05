import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Row {
    property double resize: highDpi ? 1 : 1.25
    property int rowLanguage
    property int row: parent.row
    property bool scientific: false
    property bool updateText: parent.updateText

    spacing: em
    visible: fromLanguage !== rowLanguage

    FlagImage {
        id: flag
        height: 1.75 * resize * em
        width: height / 3 * 5
        languageId: rowLanguage
    }

    Column {
        id: languageAndScientific
        anchors.verticalCenter: flag.verticalCenter

        AdaptedText {
            property var textCheck: resultWidget.resultListView.model && (updateText || !updateText) ? resultWidget.resultListView.model.data(resultWidget.resultListView.model.index(row, rowLanguage), rowLanguage) : ""
            text: textCheck ? textCheck : "" //der Zwischenschritt über die var-Variable ist notwendig, da es sonst zu errors kommt, wenn das Model leer ist. Einer var kann man gut undefined zuweisen - einem String nicht
            font.pixelSize: (resize <= 0 ? 1 : resize) * globalFontPixelSize //dieses völlig bescheuerte Konstrukt um resize ist Compiler-Errors geschuldet
        }

        AdaptedText {//Scientific
            property var textCheck: resultWidget.resultListView.model && (updateText || !updateText) ? resultWidget.resultListView.model.data(resultWidget.resultListView.model.index(row, 4), 4) : ""
            text: textCheck ? textCheck : ""
            visible: scientific && text.length > 0
            font.italic: true
            font.pixelSize: ((resize <= 0 ? 1 : resize) - 0.5) * globalFontPixelSize
        }
    }
}