import QtQuick 2.7
import QtQuick.Controls.Material 2.1

Item {
    readonly property int antallSpraak: 3
    readonly property color dark_accent: Material.color(Material.BlueGrey, Material.Shade700)
    readonly property int materialAccent: Material.Blue
    property string impressum: qsTr("<h3>Impressum</h3><p>During my Voluntary ecological year (FÖJ, Germany) 2015/16 \
                            at the Wadden Sea Centre in Vester Vedsted, Denmark, I have programmed this dictionary. \
                            For that, I used %1. The sourcecode is available on %2.</p>\
                            <p>For suggestions and error-reports, send me (Lukas Neuenschwander) an e-mail (%3). Here \
                            you can also suggest missing words that you would like to have added to the dictionary.</p>\
                            <p>The data for this app is taken from the \"IWSS Wadden Sea Dictionary\" (%4) - with the \
                            permission from the \"International Wadden Sea School\" (%5).</p>\
                            <p>Icon for settings made by %6, icon for downarrow mady by %7. Both come from %8, licensed by %9.</p>\
                            <p>Background image taken by Lukas Neuenschwander on the southern beach of Rømø, on March 12<sup>th</sup> 2016.</p>")

                            .arg("Qt 5.8-Open-Source")
                            .arg("<a href=\"https://github.com/fjellvannet/Wadden-Sea-Dictionary\">www.github.com/fjellvannet/Wadden-Sea-Dictionary</a>")
                            .arg("<a href=\"mailto:fjellvannet@gmail.com\">fjellvannet@gmail.com</a>")
                            .arg("<a href=\"http://www.iwss.org/fileadmin/uploads/network-download/Education_\
                            _Support/IWSS_Dictionary_2009.pdf\">http://www.iwss.org/fileadmin/uploads/network\
                            -download/Education__Support/IWSS_Dictionary_2009.pdf</a>")
                            .arg("<a href=\"http://www.iwss.org/\">www.iwss.org</a>")
                            .arg("<a href=\"http://www.freepik.com\" title=\"Freepik\">Freepik</a>")
                            .arg("<a href=\"http://www.flaticon.com/authors/dave-gandy\" title=\"Dave Gandy\">Dave Gandy</a>")
                            .arg("<a href=\"http://www.flaticon.com\" title=\"Flaticon\">www.flaticon.com</a>")
                            .arg("<a href=\"http://creativecommons.org/licenses/by/3.0/\" title=\"Creative Commons BY 3.0\" target=\"_blank\">CC 3.0 BY</a>")
    property string wordlist: qsTr("Wadden Sea wordlist")
    property string dictionary: qsTr("Wadden Sea dictionary")
    property string sectionLetter: switch (language) {
                                   case 0:
                                       return "SecDeutsch"
                                   case 1:
                                       return "SecEnglish"
                                   case 2:
                                       return "SecNederlands"
                                   case 3:
                                       return "SecDansk"
                                   default:
                                       return ""
                               }
}
