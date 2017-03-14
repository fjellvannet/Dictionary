#include "vocabularymodel.h"
#include "vocabularylistmodel.h"
#include "dictionarymodel.h"
#include "myqquickwindow.h"
#include "closingobject.h"

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
    QQmlEngine engine;
    QObject::connect(&engine, SIGNAL(quit()), &app, SLOT(quit()));
    QQuickWindow::setDefaultAlphaBuffer(true);

    QQmlComponent mainComp(&engine);
    mainComp.loadUrl(QUrl("qrc:/qml/Main.qml"));

    VocabularyModel model;
    VocabularyListModel listModel(&model);
    DictionaryModel dictionaryModel(&model);

    QQmlContext *ctxt = engine.rootContext();
    ctxt->setContextProperty("vocabularyModel", &listModel);
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("appLanguage", appLanguage);

    QQuickItem *mainItem = qobject_cast<QQuickItem*>(mainComp.create(ctxt));
    QQuickItem *mainLoader = mainItem->findChild<QQuickItem*>("mainLoader");
    QEventLoop loadMainWindow;
    loadMainWindow.connect(mainLoader, SIGNAL(loaded()), SLOT(quit()));
    loadMainWindow.exec();

    MyQQuickWindow *mainWindow = (MyQQuickWindow*)(qvariant_cast<QQuickWindow*>(mainLoader->property("item")));
    //mainWindow->setX(0);
    //mainWindow->loadGeometry();
    //QObject *window = &(qvariant_cast<QObject>(mainLoader->property("item")));
    //QObject viser = qvariant_cast<QObject>(mainItem->findChild<QObject*>("mainLoader")->property("item"));
    //MyQQuickWindow *mainWindow = (MyQQuickWindow*)(qobject_cast<QQuickWindow*>(mainItem->findChild<QObject*>("mainLoader")->property("item")));



    model.fillModelFromCsv(":/database/Wadden_Sea_vocabulary.csv");

    //QQmlComponent appWindow(&engine);

    //appWindow.loadUrl(QUrl("qrc:/qml/AppWindow.qml"));
    //MyQQuickWindow *mainWindow = (MyQQuickWindow*)(qobject_cast<QQuickWindow*>(appWindow.create(ctxt)));
    //mainWindow->setIcon(QIcon("D:/Dokumente/Qt/Workspace/IWSS_Waddensea_Dictionary/icon/app_icon.ico"));

    QSettings settings;//kjempeviktig, for at settings skal funke må både applicationName og Organizationname til appen være definert!
    mainWindow->setSettings(&settings);
    mainWindow->loadGeometry();
    ClosingObject obj;
    obj.setWindow(mainWindow);
    QObject::connect(mainWindow, SIGNAL(closing(QQuickCloseEvent*)),&obj, SLOT(closingToGeometry()));

    listModel.connect(mainWindow->findChild<QObject*>("LanguageButton"), SIGNAL(sortBy(QVariant)), SLOT(sortBy(QVariant)));
    dictionaryModel.connect(mainWindow->findChild<QObject*>("SearchField"), SIGNAL(textChanged(QVariant, QVariant)), SLOT(search(QVariant, QVariant)));
    if(mainWindow->property("vocabularyList").toBool())//sicherstellen, dass updateView zu Anfang einmal ausgeführt wird, wenn vocabularyList der letzte State war
    {
        QMetaObject::invokeMethod(mainWindow->findChild<QObject*>("lvVocabulary"), "updateView");
    }
    mainWindow->setProperty("visible", true);
    return app.exec();
}
