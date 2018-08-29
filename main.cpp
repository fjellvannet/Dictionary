#if WADDEN_SEA_DICTIONARY
    #include "wadden_sea_dictionary/vocabularymodel.h"
    #include "wadden_sea_dictionary/vocabularylistmodel.h"
    #include "wadden_sea_dictionary/dictionarymodel.h"
#else
    #include "bonytysk/wordlistmodel.h"
#if EDIT_DATABASE
    #include "bonytysk/databasecreator.h"
#endif
#endif
#define STRINGIFY(x) #x //Disse trengs for å kunne skrive ut App-versjonen i Kolofonen
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
#include <QTimer>
#if !WADDEN_SEA_DICTIONARY
    #include <QSqlDatabase>
    #include <QDir>
    #include <QStandardPaths>
    #include <QSqlError>
    #include <QFile>
    #include <QTextStream>
    #include <QTextCodec>
    #include <QSqlQuery>
    #include <QTime>
    #include <QElapsedTimer>
    #include <QThread>
#endif

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
#if WADDEN_SEA_DICTIONARY
    app.setApplicationName(QCoreApplication::tr("Wadden Sea Dictionary"));//if you change it, remember to change appinfo.h (windows) accordingly
#else
    app.setApplicationName("BoNyTysk");
#endif
    app.setOrganizationDomain("https://github.com/fjellvannet/Dictionary");//if you change it, remember to change appinfo.h (windows) accordingly
    app.setOrganizationName(TOSTRING(APP_DEVELOPER));
    app.setApplicationVersion(TOSTRING(APP_VERSION_STR));

    qDebug().noquote() << app.applicationName() << TOSTRING(APP_VERSION_STR);
#if !WADDEN_SEA_DICTIONARY
#if EDIT_DATABASE
    DatabaseCreator::updateHeinzelliste(true);
    DatabaseCreator::updateVersion();
    return 0;
#endif
    QFileInfo bonytyskVocabularyFile(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/bonytysk-database.sqlite");
    bool copyDatabase = true;
    if(bonytyskVocabularyFile.exists()) {
        {//scope to isolate database, so that the connection can be deleted when the database is out of scope
            QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");//not dbConnection
            db.setConnectOptions("QSQLITE_OPEN_READONLY");
            db.setDatabaseName(bonytyskVocabularyFile.absoluteFilePath()); //if the database file doesn't exist yet, it will create it
            if (!db.open()) qCritical().noquote() << db.lastError().text();
            {//scope for query, so the connection can be deleted when the Query is out of scope
                QSqlQuery query(db);
                query.exec("SELECT * FROM version");
                query.first();
                if(query.isValid()){
                    QVector<int> app_version = {APP_VERSION_NR};
                    QVector<int> db_version(3);
                    for(int i = 0; i < 3; i++) db_version[i] = query.value(i).toInt();
                    copyDatabase = app_version != db_version;
                    if(copyDatabase) {
                        QString dbVersionString = QString::number(db_version[0]);
                        for(int i = 1; i < db_version.count(); ++i) dbVersionString.append(QString(".%1").arg(db_version[i]));
                        if(db_version < app_version) qDebug().noquote() << "Database-version" << dbVersionString << "smaller than app-version, update database-version.";
                        else qDebug().noquote() << "Replace database, current database version" << dbVersionString;
                    } else qDebug().noquote() << "No need to replace the database file - the app- and database versions are equal.";
                }
            }
        }
        QSqlDatabase::removeDatabase("qt_sql_default_connection");
    }
    if(copyDatabase){
        if(QDir().mkpath(bonytyskVocabularyFile.absolutePath())){
            QFile f(bonytyskVocabularyFile.absoluteFilePath());
            f.setPermissions(QFile::ReadOther|QFile::WriteOther);
            if(!f.remove()) qWarning() << "Could not delete old database.";
            if(QFile(":/database/bonytysk-database.sqlite").copy(bonytyskVocabularyFile.absoluteFilePath()))
                qDebug().noquote() << "Successfully replaced old database-file.";
            else qWarning().noquote() << "Could not copy current version of database - check file permissions.";
        } else {
            qCritical().noquote() << "The AppData-Directory for updating the database could not be created, operation aborted.";
        }
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");//not dbConnection
    db.setDatabaseName(bonytyskVocabularyFile.absoluteFilePath());
    if (!db.open()) qCritical().noquote() << db.lastError().text();
    else qDebug().noquote() << "Successfully connected to database.";

    WordListModel test;
    test.setSortLanguage(WordListModel::Bokmaal);


    return 0;
#else
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
    QQmlContext *ctxt = view.engine()->rootContext();
    bool mobile = MOBILE == 1;
    ctxt->setContextProperty("mobile", mobile);
#if SPLASH
    view.setSource(QUrl("qrc:/qml/Main.qml"));//Um den SplashScreen wieder zu aktivieren, alle Kommentare in qml.qrc, dieser Datei und myqquickview.cpp entfernen, view.setSource mit AppWindow wieder auskommentieren.
    view.show();
/*
//    this code is for testing the launch screen by showing it over 5 seconds
    QTimer timer;
    QEventLoop sleeper;
    timer.setSingleShot(true);
    sleeper.connect(&timer, SIGNAL(timeout()), SLOT(quit()));
    timer.start(5000);
    sleeper.exec();
*/
#endif

    VocabularyModel model;
    VocabularyListModel listModel(&model);
    DictionaryModel dictionaryModel(&model);

    ctxt->setContextProperty("vocabularyModel", &listModel);
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("appLanguage", appLanguage);
    ctxt->setContextProperty("app_version", TOSTRING(APP_VERSION_STR));
    ctxt->setContextProperty("qt_version", QT_VERSION_STR);

#if !SPLASH
    view.setSource(QUrl("qrc:/qml/AppWindow.qml"));
    QQuickItem *mainWindow = view.rootObject();
#else
    QQuickItem *mainLoader = view.rootObject()->findChild<QQuickItem*>("mainLoader");
    mainLoader->setProperty("active", true);
    QEventLoop loadMainWindow;
    loadMainWindow.connect(mainLoader, SIGNAL(loaded()), SLOT(quit()));
    loadMainWindow.exec();
    QQuickItem *mainWindow = qvariant_cast<QQuickItem*>(mainLoader->property("item"));
#endif
#if !MOBILE
    view.loadGeometry();
#endif
    listModel.connect(mainWindow->findChild<QQuickItem*>("LanguageButton"), SIGNAL(sortBy(QVariant)), SLOT(sortBy(QVariant)));
    dictionaryModel.connect(mainWindow->findChild<QQuickItem*>("SearchField"), SIGNAL(textChanged(QVariant, QVariant)), SLOT(search(QVariant, QVariant)));
    if(mainWindow->property("vocabularyList").toBool())//sicherstellen, dass updateView zu Anfang einmal ausgeführt wird, wenn vocabularyList der letzte State war
    {
        QMetaObject::invokeMethod(mainWindow->findChild<QQuickItem*>("lvVocabulary"), "updateView");
    }
    return app.exec();
#endif
}

