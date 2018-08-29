import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4

ScrollBar {
    anchors.bottom: parent.bottom //disse må settes, for ellers funker ikke resize
    anchors.right: parent.right
    property int barwidth: 2 * globalMargin
    visible: size < 1
    implicitWidth: barwidth//dette ser kanskje rart ut (høyden og bredden skal jo ikke være like.) Men denne koden gjør det den skal.
    implicitHeight: barwidth
    minimumSize: 0.05
}
