import QtQuick

MouseArea{//Stellt sicher, dass mit dem Mausrad nicht zu schnell gescrollt wird - wie schnell kann eingestellt werden
    anchors.fill: parent
    property int lastScrollTs: Date.now() % 86400000
    function performScroll(wheel) {
        if (wheel.device.type === PointerDevice.Mouse || wheel.device.name.includes("magic mouse")) {
            let tsSpeed = Date.now() % 86400000 - lastScrollTs
            let speed = (0.00625 + 3.125 / Math.max(Math.min(tsSpeed, 500), 200)) * em * wheel.angleDelta.y
            parent.contentY = Math.min(Math.max(parent.originY, parent.contentY - speed), parent.contentHeight + parent.originY - parent.height)
            lastScrollTs = Date.now() % 86400000
            return em * wheel.angleDelta.y / tsSpeed
        }
    }
    propagateComposedEvents: true//damit die Klicks an die darunter liegenden MouseAreas weitergeleitet werden.
}
