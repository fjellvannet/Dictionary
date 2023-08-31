import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick
import QtQuick.Layouts

Item {
    id: dialogWrapper
    property string title
    property string cancelQuestion
    anchors.fill: parent
    signal cancelOperation()

    function openProgressDialog() {
        progressDialog.open()
    }

    function setCurrentStepStatistics(statisticsString) {
        stepStatistics.text = statisticsString
    }

    function setCurrentStepProgress(value, formattedValue) {
        stepProgress.indeterminate = value < 0
        stepProgress.value = value
        stepProgress.text = formattedValue
    }

    function setCurrentStep(currentStepText) {
        currentStep.text = currentStepText
    }

    function setFinished(text) {
        progressDialog.close()
        finishDialog.open()
        finishMessage.text = text
    }

    Popup {
        id: progressDialog
        anchors.centerIn: parent
        modal: true
        padding: 0.75 * em
        Material.accent: constants.materialAccent
        closePolicy: Popup.NoAutoClose
        onOpened: btnCancel.forceActiveFocus()

        ColumnLayout {
            spacing: mg

            AdaptedText {
                text: title
                font.pixelSize: 1.25 * globalFontPixelSize
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 0.75 * dialogWrapper.width
                Layout.alignment: Qt.AlignCenter
            }
            AdaptedText {
                id: currentStep
                text: "god morgen"
                Layout.maximumWidth: 0.75 * dialogWrapper.width
            }
            TextProgressBar {
                id: stepProgress
                text: "20 %"
                value: 0.3
                height: 2 * em
                Layout.fillWidth: true
            }
            AdaptedText {
                id: stepStatistics
                textFormat: Text.RichText
                visible: text.length > 0
            }
            TextButton {
                id: btnCancel
                text: qsTr("Cancel")
                onClicked: {
                    progressDialog.close()
                    cancelDialog.open()
                }

                focus: true
                font.pixelSize: globalFontPixelSize
                Layout.alignment: Qt.AlignRight

            }
        }
    }

    Dialog {
        id: cancelDialog
        modal: true
        anchors.centerIn: parent
        Material.accent: constants.materialAccent
        padding: 0.75 * em

        onAccepted: cancelOperation()
        onRejected: progressDialog.open()
        onOpened: btnYes.forceActiveFocus()

        contentItem: ColumnLayout {
            spacing: mg

            AdaptedText {
                text: dialogWrapper.title
                font.pixelSize: 1.25 * globalFontPixelSize
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 0.75 * dialogWrapper.width
                Layout.alignment: Qt.AlignCenter
            }
            AdaptedText {
                text: cancelQuestion
                textFormat: Text.RichText
                Layout.maximumWidth: 0.75 * dialogWrapper.width
                wrapMode: Text.WordWrap
            }
            RowLayout {
                property int buttonWidth: Math.max(btnYes.implicitWidth, btnNo.implicitWidth)
                Layout.alignment: Qt.AlignRight
                spacing: mg
                TextButton {
                    id: btnYes
                    text: qsTr("Yes")
                    onClicked: cancelDialog.accept()
                    Layout.preferredWidth: parent.buttonWidth
                    KeyNavigation.right: btnNo
                }
                TextButton {
                    id: btnNo
                    text: qsTr("No")
                    onClicked: cancelDialog.reject()
                    Layout.preferredWidth: parent.buttonWidth
                    KeyNavigation.left: btnYes
                }
            }
        }
    }

    Dialog {
        id: finishDialog
        modal: true
        padding: 0.75 * em
        onOpened: btnOk.forceActiveFocus()
        anchors.centerIn: parent
        Material.accent: constants.materialAccent

        contentItem: ColumnLayout {
            spacing: mg
            AdaptedText {
                text: dialogWrapper.title
                font.pixelSize: 1.25 * globalFontPixelSize
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 0.75 * dialogWrapper.width
                Layout.alignment: Qt.AlignCenter
            }
            AdaptedText {
                id: finishMessage
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 0.75 * dialogWrapper.width
            }
            TextButton {
                id: btnOk
                text: qsTr("Ok")
                onClicked: finishDialog.close()
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
