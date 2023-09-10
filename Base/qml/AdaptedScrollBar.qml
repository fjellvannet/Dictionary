import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4

ScrollBar {
    anchors.bottom: parent.bottom //disse må settes, for ellers funker ikke resize
    anchors.right: parent.right
    property int barwidth: em
    visible: size < 1
    implicitWidth: barwidth//dette ser kanskje rart ut (høyden og bredden skal jo ikke være like.) Men denne koden gjør det den skal.
    implicitHeight: barwidth
    minimumSize: 0.05
    function show() {
        active=true
        tmr.restart()
    }
    Timer {
        id: tmr
        interval: 2000
        onTriggered: active=false
    }
    onActiveChanged: function(active) {
        if(active === false)
            tmr.stop()
    }
}
