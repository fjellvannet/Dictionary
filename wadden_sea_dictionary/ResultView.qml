import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

Item {
    id: resultView
    height: resultColumn.implicitHeight + 2 * resultColumn.anchors.margins
    width: resultColumn.implicitWidth + 2 * resultColumn.anchors.margins
    property bool updateText
    Column {
        id: resultColumn
        anchors.fill: parent
        anchors.margins: 1.5 * globalMargin
        spacing: globalMargin
        property int row: resultWidget.resultListView.currentIndex
        property alias updateText: resultView.updateText
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
