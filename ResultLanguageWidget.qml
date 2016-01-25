import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

Row {
    property double resize: highDpi ? 1 : 1.25
    property int language
    property int row
    property bool scientific: false

    spacing: globalMargin
    visible: resultWidget.fromLanguage !== language

    Image {
        id: flag
        height: 4 * parent.resize * globalMargin
        sourceSize.height: height
        sourceSize.width: height / 3 * 5
        source: switch(language) {
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

    Column {
        id: languageAndScientific
        anchors.verticalCenter: flag.verticalCenter
        Text {
            text: VocabularyModel.data(VocabularyModel.index(row, language), language)
            font.pointSize: parent.parent.resize * fontHeight.font.pointSize
        }
        
        Text {//Scientific
            text: VocabularyModel.data(VocabularyModel.index(row, 4), 4)
            visible: scientific && text.length > 0
            font.italic: true
            font.pointSize: (parent.parent.resize - 0.5) * fontHeight.font.pointSize
        }
    }
}
