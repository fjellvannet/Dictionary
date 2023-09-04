import QtQuick
import QtQuick.Controls

AdaptedImage {
    property int languageId: language
    source: switch(languageId) {
            case 0:
                return "qrc:/Dictionary/images/flags/german_flag"
            case 1:
                return "qrc:/Dictionary/images/flags/union_jack"
            case 2:
                return "qrc:/Dictionary/images/flags/netherlands_flag"
            case 3:
                return "qrc:/Dictionary/images/flags/danish_flag"
            case undefined:
                return ""
            }
}
