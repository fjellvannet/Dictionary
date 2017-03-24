#include "vocabularymodel.h"
#include "vocabularylistmodel.h"
#include "dictionarymodel.h"
#include "myqquickview.h"

#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QDebug>
#include <QApplication>
#include <QQuickStyle>
#include <QSettings>
#include <QDateTime>
#include <QThread>
#include <QQmlProperty>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    //QLocale::setDefault(QLocale(QLocale::German, QLocale::Germany));
    //QLocale::setDefault(QLocale(QLocale::English, QLocale::UnitedKingdom));
    //QLocale::setDefault(QLocale(QLocale::Dutch, QLocale::Netherlands));
    //QLocale::setDefault(QLocale(QLocale::Danish, QLocale::Denmark));
    QTranslator translator;
    int appLanguage = 1;//default - English UK
    if (translator.load(QLocale(), "translations/Wadden_Sea_Dictionary", "_", ":/translations", ".qm"))
    {
        app.installTranslator(&translator);
        switch(QLocale().language())
        {
        case QLocale::German:
            appLanguage = 0;
            break;
        case QLocale::Dutch:
            appLanguage = 2;
            break;
        case QLocale::Danish:
            appLanguage = 3;
        default:
            ;//nur um Compiler-Warnungen zu unterdrücken, kann durch das vorangegangene if nicht auftreten
        }
    }

    app.setApplicationName(QCoreApplication::tr("Wadden Sea Dictionary"));
    app.setOrganizationName("fjellvannet");

    QQuickStyle::setStyle("Material");
    QQuickWindow::setDefaultAlphaBuffer(true);
    MyQQuickView view;

//    view.setSource(QUrl("qrc:/qml/Main.qml"));//Um den SplashScreen wieder zu aktivieren, alle Kommentare in qml.qrc, dieser Datei und myqquickview.cpp entfernen, view.setSource mit AppWindow wieder auskommentieren.
//    view.show();

    VocabularyModel model(&QFile(":/database/Wadden_Sea_vocabulary.csv"));
    VocabularyListModel listModel(&model);
    DictionaryModel dictionaryModel(&model);

    QQmlContext *ctxt = view.engine()->rootContext();
    ctxt->setContextProperty("vocabularyModel", &listModel);
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("appLanguage", appLanguage);

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
