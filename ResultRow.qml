import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

Row {
    property double resize: highDpi ? 1 : 1.25
    property int rowLanguage
    property int row
    property bool scientific: false

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
        }
    }

    Column {
        id: languageAndScientific
        anchors.verticalCenter: flag.verticalCenter
        Text {
            text: resultWidget.resultListView.model.data(resultWidget.resultListView.model.index(row, rowLanguage), rowLanguage)
            font.pointSize: (resize <= 0 ? 1 : resize) * fontHeight.font.pointSize //dieses völlig bescheuerte Konstrukt um resize ist Compiler-Errors geschuldet
        }
        
        Text {//Scientific
            text: resultWidget.resultListView.model.data(resultWidget.resultListView.model.index(row, 4), 4)
            visible: scientific && text.length > 0
            font.italic: true
            font.pointSize: ((resize <= 0 ? 1 : resize) - 0.5) * fontHeight.font.pointSize
        }
    }
}
