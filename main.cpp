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

    VocabularyModel model;
    model.fillModelFromCsv(":/database/Wadden_Sea_vocabulary.csv");
    VocabularyListModel listModel;
    listModel.setSourceModel(&model);
    DictionaryModel dictionaryModel(&model);
    QSettings settings;
    MyQQuickView view;
    view.setSettings(&settings);
    view.loadGeometry();
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setTitle(app.applicationName());
    view.setIcon(QIcon("D:/Dokumente/Qt/Workspace/IWSS_Waddensea_Dictionary/icon/app_icon.ico"));
    QQmlContext *ctxt = view.rootContext();
    QQuickStyle::setStyle("Material");

    ctxt->setContextProperty("vocabularyModel", &listModel);
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("appName", app.applicationName());
    ctxt->setContextProperty("appLanguage", appLanguage);
    view.setSource(QUrl("qrc:/qml/AppWindow.qml"));
    listModel.connect(view.rootObject()->findChild<QObject*>("LanguageButton"), SIGNAL(sortBy(QVariant)), SLOT(sortBy(QVariant)));
    dictionaryModel.connect(view.rootObject()->findChild<QObject*>("SearchField"), SIGNAL(textChanged(QVariant, QVariant)), SLOT(search(QVariant, QVariant)));
    if(view.rootObject()->property("vocabularyList").toBool())//sicherstellen, dass updateView zu Anfang einmal ausgeführt wird, wenn vocabularyList der letzte State war
    {
        QMetaObject::invokeMethod(view.rootObject()->findChild<QObject*>("lvVocabulary"), "updateView");
    }
    view.show();
    return app.exec();
}

void closing(){
    qDebug() << "nix";
}

