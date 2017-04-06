#if WADDEN_SEA_DICTIONARY
#include "wadden_sea_dictionary/vocabularymodel.h"
#include "wadden_sea_dictionary/vocabularylistmodel.h"
#include "wadden_sea_dictionary/dictionarymodel.h"
#endif
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
#include "myqquickview.h"

#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QDebug>
#include <QApplication>
#include <QQuickStyle>
#include <QSettings>
#include <QQmlProperty>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
#if WADDEN_SEA_DICTIONARY
    app.setApplicationName(QCoreApplication::tr("Wadden Sea Dictionary"));
#endif
    app.setOrganizationDomain("https://github.com/fjellvannet/Wadden-Sea-Dictionary");
    app.setOrganizationName("fjellvannet");
    qDebug().noquote() << app.applicationName() << TOSTRING(VERSION_STR);

//    QLocale::setDefault(QLocale(QLocale::German, QLocale::Germany));
//    QLocale::setDefault(QLocale(QLocale::English, QLocale::UnitedKingdom));
//    QLocale::setDefault(QLocale(QLocale::Dutch, QLocale::Netherlands));
//    QLocale::setDefault(QLocale(QLocale::Danish, QLocale::Denmark));
//    QLocale::setDefault(QLocale(QLocale::NorwegianBokmal, QLocale::Norway));
//    QLocale::setDefault(QLocale(QLocale::NorwegianNynorsk, QLocale::Norway));
    QTranslator translator;
    int appLanguage = 1;//default - English UK
    if (translator.load(QLocale(), "Dictionary", "_", ":/translations", ".qm"))
    {
        app.installTranslator(&translator);
        switch(QLocale().language())
        {
        case QLocale::German:
            appLanguage = 0;
            break;
#if WADDEN_SEA_DICTIONARY
        case QLocale::Dutch:
            appLanguage = 2;
            break;
        case QLocale::Danish:
            appLanguage = 3;
            break;
#else
        case QLocale::NorwegianBokmal:
            appLanguage = 2;
            break;
        case QLocale::NorwegianNynorsk:
            appLanguage = 3;
            break;
#endif
        default:
            ;//nur um Compiler-Warnungen zu unterdrücken, kann durch das vorangegangene if nicht auftreten
        }
    }

    QQuickStyle::setStyle("Material");
    QQuickWindow::setDefaultAlphaBuffer(true);
    MyQQuickView view;

//    view.setSource(QUrl("qrc:/qml/Main.qml"));//Um den SplashScreen wieder zu aktivieren, alle Kommentare in qml.qrc, dieser Datei und myqquickview.cpp entfernen, view.setSource mit AppWindow wieder auskommentieren.
//    view.show();

    VocabularyModel model;
    VocabularyListModel listModel(&model);
    DictionaryModel dictionaryModel(&model);

    QQmlContext *ctxt = view.engine()->rootContext();
    ctxt->setContextProperty("vocabularyModel", &listModel);
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("appLanguage", appLanguage);
    ctxt->setContextProperty("app_version", TOSTRING(APP_VERSION_STR));
    ctxt->setContextProperty("qt_version", QT_VERSION_STR);

    view.setSource(QUrl("qrc:/qml/AppWindow.qml"));
    QQuickItem *mainWindow = view.rootObject();

//    QQuickItem *mainLoader = view.rootObject()->findChild<QQuickItem*>("mainLoader");
//    mainLoader->setProperty("active", true);
//    QEventLoop loadMainWindow;
//    loadMainWindow.connect(mainLoader, SIGNAL(loaded()), SLOT(quit()));
//    loadMainWindow.exec();
//    QQuickItem *mainWindow = qvariant_cast<QQuickItem*>(mainLoader->property("item"));

    listModel.connect(mainWindow->findChild<QQuickItem*>("LanguageButton"), SIGNAL(sortBy(QVariant)), SLOT(sortBy(QVariant)));
    dictionaryModel.connect(mainWindow->findChild<QQuickItem*>("SearchField"), SIGNAL(textChanged(QVariant, QVariant)), SLOT(search(QVariant, QVariant)));
    if(mainWindow->property("vocabularyList").toBool())//sicherstellen, dass updateView zu Anfang einmal ausgeführt wird, wenn vocabularyList der letzte State war
    {
        QMetaObject::invokeMethod(mainWindow->findChild<QQuickItem*>("lvVocabulary"), "updateView");
    }

    view.loadGeometry();
    return app.exec();
}
