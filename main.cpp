#include "vocabularymodel.h"
#include "vocabularylistmodel.h"
#include "dictionarymodel.h"

#include <QApplication>
#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QQuickItem>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName(QCoreApplication::tr("IWSS Waddensea Dictionary"));

    VocabularyModel model;
    model.fillModelFromCsv(":/database/waddensea_vocabulary.csv");
    VocabularyListModel listModel;
    listModel.setSourceModel(&model);
    DictionaryModel dictionaryModel(&model);
    int appLanguage = 1;
    listModel.sortBy(appLanguage);

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setHeight(480);
    view.setWidth(640);
    QQmlContext *ctxt = view.rootContext();

    ctxt->setContextProperty("vocabularyModel", &listModel);
    ctxt->setContextProperty("dictionaryModel", &dictionaryModel);
    ctxt->setContextProperty("appName", app.applicationName());
    ctxt->setContextProperty("appLanguage", appLanguage);
    view.setSource(QUrl("qrc:/AppWindow.qml"));
    listModel.connect(view.rootObject()->findChild<QObject*>("LanguageButton"), SIGNAL(sortBy(QVariant)), SLOT(sortBy(QVariant)));
    dictionaryModel.connect(view.rootObject()->findChild<QObject*>("SearchField"), SIGNAL(textChanged(QVariant, QVariant)), SLOT(search(QVariant, QVariant)));
    view.show();

    return app.exec();
}

