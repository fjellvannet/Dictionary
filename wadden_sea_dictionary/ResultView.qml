import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Item {
    id: resultView
    height: resultColumn.implicitHeight + 2 * resultColumn.anchors.margins
    width: resultColumn.implicitWidth + 2 * resultColumn.anchors.margins
    property bool updateText
    property int fromLanguage: {
        if(lvDictionary.visible && lvDictionary.count > 0 && dictionaryModel.data(dictionaryModel.index(resultWidget.resultListView.currentIndex, 6), 6) < 4)
            return dictionaryModel.data(dictionaryModel.index(resultWidget.resultListView.currentIndex, 6), 6)
        else return language;
    }
    Column {
        id: resultColumn
        anchors.fill: parent
        anchors.margins: em
        spacing: em / 2
        property int row: resultWidget.resultListView.currentIndex
        property alias updateText: resultView.updateText
        ResultRow {
            rowLanguage: fromLanguage
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
