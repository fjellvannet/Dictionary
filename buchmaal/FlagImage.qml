import QtQuick
import QtQuick.Controls

AdaptedImage {
    property int languageId: language
    source: switch(languageId) {
            case 0:
                return "qrc:/images/flags/german_flag"
            case 1:
                return "qrc:/images/flags/norwegian_flag"
            case undefined:
                return ""
            }
}
