import QtQuick
import QtQuick.Controls

AdaptedImage {
    property int languageId: language
    source: {
        if (!visible)
            return ""
        switch(languageId) {
            case 0:
                return "qrc:/qt/qml/Dictionary/images/flags/german_flag.svg"
            case 1:
                return "qrc:/qt/qml/Dictionary/images/flags/union_jack.svg"
            case 2:
                return "qrc:/qt/qml/Dictionary/images/flags/netherlands_flag.svg"
            case 3:
                return "qrc:/qt/qml/Dictionary/images/flags/danish_flag.svg"
            case undefined:
                return ""
            }
    }
}
