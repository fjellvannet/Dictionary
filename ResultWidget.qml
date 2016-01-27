import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0

Item {
    id: resultWidget
    property ListView resultListView
    property int fromLanguage

    Layout.preferredHeight: resultView.height
    Layout.preferredWidth: resultView.width
    Layout.minimumWidth: parent.width / 4
    Layout.maximumWidth: parent.width / 2
    Layout.fillHeight: true
    Layout.fillWidth: false

    Flickable {
        anchors.fill: parent
        contentWidth: childrenRect.width; contentHeight: childrenRect.height
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
                ResultRow {
                    language: languageInt
                    resize: highDpi ? 1.25 : 1.75
                    scientific: true
                    visible: true
                    row: resultWidget.resultListView.currentIndex
                }
                ResultRow {
                    language: 0
                    row: resultWidget.resultListView.currentIndex
                }
                ResultRow {
                    language: 1
                    row: resultWidget.resultListView.currentIndex
                }
                ResultRow {
                    language: 2
                    row: resultWidget.resultListView.currentIndex
                }
                ResultRow {
                    language: 3
                    row: resultWidget.resultListView.currentIndex
                }
            }
        }
    }

    states: State{
        name: "TopToBottom"
        when: parent.flow == GridLayout.TopToBottom
        PropertyChanges{
            target: resultWidget
            Layout.fillHeight: false
            Layout.fillWidth: true
            Layout.maximumWidth: -1
            Layout.maximumHeight: parent.height / 2
        }
    }
}
