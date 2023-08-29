import QtQuick 2.11
import QtQuick.Controls.Material 2.1
Item {
    readonly property int antallSpraak: 2
    readonly property color dark_accent: Material.color(Material.BlueGrey, Material.Shade700)
    readonly property int materialAccent: Material.Red
    readonly property bool isBuchmaal: true
    property string impressum: qsTr("<h3>Impressum</h3><p>%1 %2</p> \
                            <p>During my Voluntary ecological year (FÖJ, Germany) 2015/16 \
                            at the Wadden Sea Centre in Vester Vedsted, Denmark, I have programmed this dictionary. \
                            For that, I used %3. The sourcecode is available on %4.</p>\
                            <p>For suggestions and error-reports, send me (Lukas Neuenschwander) an e-mail (%5). Here \
                            you can also suggest missing words that you would like to have added to the dictionary.</p>\
                            <p>The data for this app is taken from the \"IWSS Wadden Sea Dictionary\" (%6) - with the \
                            permission from the \"International Wadden Sea School\" (%7).</p>\
                            <p>Icon for settings made by %8, icon for downarrow mady by %9. Both come from %10, licensed by %11.</p>\
                            <p>Background image taken by Lukas Neuenschwander on the southern beach of Rømø, on March 12<sup>th</sup> 2016.</p>")

                            .arg(qsTr(Qt.application.name))
                            .arg(app_version)
                            .arg("Qt " + qt_version + "-Open-Source")
                            .arg("<a href=\"" + Qt.application.domain + "\">" + Qt.application.domain + "</a>")
                            .arg("<a href=\"mailto:fjellvannet@gmail.com\">fjellvannet@gmail.com</a>")
                            .arg("<a href=\"http://www.iwss.org/fileadmin/uploads/network-download/Education_\
                            _Support/IWSS_Dictionary_2009.pdf\">http://www.iwss.org/fileadmin/uploads/network\
                            -download/Education__Support/IWSS_Dictionary_2009.pdf</a>")
                            .arg("<a href=\"http://www.iwss.org/\">www.iwss.org</a>")
                            .arg("<a href=\"http://www.freepik.com\" title=\"Freepik\">Freepik</a>")
                            .arg("<a href=\"http://www.flaticon.com/authors/dave-gandy\" title=\"Dave Gandy\">Dave Gandy</a>")
                            .arg("<a href=\"http://www.flaticon.com\" title=\"Flaticon\">www.flaticon.com</a>")
                            .arg("<a href=\"http://creativecommons.org/licenses/by/3.0/\" title=\"Creative Commons BY 3.0\" target=\"_blank\">CC 3.0 BY</a>")
    property string wordlist: qsTr("Buchmål wordlist")
    property string dictionary: qsTr("Buchmål dictionary")
    property string sectionLetter: "SectionLetter"
}
