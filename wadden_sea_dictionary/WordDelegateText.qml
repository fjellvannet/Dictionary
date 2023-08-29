import QtQuick
import QtQuick.Controls

AdaptedText {
    text: {
        var s
        switch(language){
            case 0: s = Deutsch; break
            case 1: s = English; break
            case 2: s = Nederlands; break
            case 3: s = Dansk; break
            case undefined: s = ""
        }
        return s + (Scientific === "" ? "" : " (<i>" + Scientific + "</i>)")
    }
}
