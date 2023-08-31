#if WADDEN_SEA_DICTIONARY
#include "wadden_sea_dictionary/vocabularymodel.h"
#include "wadden_sea_dictionary/vocabularylistmodel.h"
#include "wadden_sea_dictionary/dictionarymodel.h"
#else
#include "buchmaal/wordlistmodel.h"
#include "buchmaal/resultmodel.h"
#include "buchmaal/databasemanager.h"
#if EDIT_DATABASE + UPDATE_DB_VERSION
#include "buchmaal/databasecreator.h"
#endif
#endif
#define STRINGIFY(x) #x //Disse trengs for å kunne skrive ut App-versjonen i Kolofonen
#define TOSTRING(x) STRINGIFY(x)
#include "myqquickview.h"

#include <QtCore>
#include <QtQuick>
#include <QQuickStyle>
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

int main(int argc, char* argv[]) {
  QApplication app(argc, argv);
#if WADDEN_SEA_DICTIONARY
  app.setApplicationName(QCoreApplication::tr("Wadden Sea Dictionary"));//if you change it, remember to change appinfo.h (windows) accordingly
#else
  app.setApplicationName("Buchmål");
  DatabaseManager::openDatabaseConnection();
  DatabaseManager databaseManager; // create these before the QML-engine not to get NPE's closing down the app
  WordListModel listModel;
  ResultModel resultModel;
#endif
  app.setOrganizationDomain("https://github.com/fjellvannet/Dictionary");//if you change it, remember to change appinfo.h (windows) accordingly
  app.setOrganizationName(TOSTRING(APP_DEVELOPER));
  app.setApplicationVersion(TOSTRING(APP_VERSION_STR));


  //    QLocale::setDefault(QLocale(QLocale::German, QLocale::Germany));
  //    QLocale::setDefault(QLocale(QLocale::English, QLocale::UnitedKingdom));
  //    QLocale::setDefault(QLocale(QLocale::Dutch, QLocale::Netherlands));
  //    QLocale::setDefault(QLocale(QLocale::Danish, QLocale::Denmark));
  //    QLocale::setDefault(QLocale(QLocale::NorwegianBokmal, QLocale::Norway));
  //    QLocale::setDefault(QLocale(QLocale::NorwegianNynorsk, QLocale::Norway));
  QTranslator translator;
  int appLanguage = 1;//default - English UK
  if (translator.load(QLocale(), "Dictionary", "_", ":/translations", ".qm")) {
    app.installTranslator(&translator);
    switch(QLocale().language()) {
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
  QQmlContext* ctxt = view.engine()->rootContext();
  bool mobile = MOBILE == 1;
  ctxt->setContextProperty("mobile", mobile);
#if SPLASH
  view.setSource(QUrl("qrc:/qml/Main.qml"));//Um den SplashScreen wieder zu aktivieren, alle Kommentare in qml.qrc, dieser Datei und myqquickview.cpp entfernen, view.setSource mit AppWindow wieder auskommentieren.
  view.show();

  //    this code is for testing the launch screen by showing it over 5 seconds
  QTimer timer;
  QEventLoop sleeper;
  timer.setSingleShot(true);
  sleeper.connect(&timer, SIGNAL(timeout()), SLOT(quit()));
  timer.start(5000);
  sleeper.exec();

#endif
#if WADDEN_SEA_DICTIONARY
  VocabularyModel model;
  VocabularyListModel listModel(&model);
  DictionaryModel dictionaryModel(&model);
  ctxt->setContextProperty("vocabularyModel", &listModel);
  ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
#else
  ctxt->setContextProperty("vocabularyModel", &listModel);
  ctxt->setContextProperty("dictionaryModel", nullptr);
  ctxt->setContextProperty("databaseManager", &databaseManager);
#endif
  ctxt->setContextProperty("appLanguage", appLanguage);
  ctxt->setContextProperty("app_version", TOSTRING(APP_VERSION_STR));
  ctxt->setContextProperty("qt_version", QT_VERSION_STR);

#if !SPLASH
  view.setSource(QUrl("qrc:/qml/AppWindow.qml"));
  QQuickItem* mainWindow = view.rootObject();
#else
  QQuickItem* mainLoader = view.rootObject()->findChild<QQuickItem*>("mainLoader");
  mainLoader->setProperty("active", true);
  QEventLoop loadMainWindow;
  loadMainWindow.connect(mainLoader, SIGNAL(loaded()), SLOT(quit()));
  loadMainWindow.exec();
  QQuickItem* mainWindow = qvariant_cast<QQuickItem*>(mainLoader->property("item"));
#endif
#if MOBILE
  view.setResizeMode(QQuickView::SizeRootObjectToView);
#else
  view.loadGeometry();
#endif
  if(mainWindow->property("vocabularyList").toBool()) { //sicherstellen, dass updateView zu Anfang einmal ausgeführt wird, wenn vocabularyList der letzte State war
    QMetaObject::invokeMethod(mainWindow->findChild<QQuickItem*>("lvVocabulary"), "updateView");
  }
  view.show();
  return app.exec();
}
