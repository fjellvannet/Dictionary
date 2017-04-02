import QtQuick 2.7
import QtQuick.Controls 2.1

AdaptedImage {
    property int languageId: language
    source: switch(languageId) {
            case 0:
                return "qrc:/images/flags/german_flag"
            case 1:
                return "qrc:/images/flags/union_jack"
            case 2:
                return "qrc:/images/flags/netherlands_flag"
            case 3:
                return "qrc:/images/flags/danish_flag"
            case undefined:
                return ""
            }
}
