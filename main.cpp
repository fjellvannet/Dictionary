#include "vocabularymodel.h"
#include "vocabularylistmodel.h"
#include "dictionarymodel.h"

#include <QApplication>
#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QQuickItem>
#include <QDebug>

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
    listModel.sortBy(appLanguage);

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setHeight(480);
    view.setWidth(640);
    view.setTitle(app.applicationName());
    view.setIcon(QIcon("D:/Dokumente/Qt/Workspace/IWSS_Waddensea_Dictionary/icon/app_icon.ico"));
    QQmlContext *ctxt = view.rootContext();

    ctxt->setContextProperty("vocabularyModel", &listModel);
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("appName", app.applicationName());
    ctxt->setContextProperty("appLanguage", appLanguage);
    view.setSource(QUrl("qrc:/qml/AppWindow.qml"));
    listModel.connect(view.rootObject()->findChild<QObject*>("LanguageButton"), SIGNAL(sortBy(QVariant)), SLOT(sortBy(QVariant)));
    dictionaryModel.connect(view.rootObject()->findChild<QObject*>("SearchField"), SIGNAL(textChanged(QVariant, QVariant, QVariant)), SLOT(search(QVariant, QVariant, QVariant)));
    view.show();

    return app.exec();
}

