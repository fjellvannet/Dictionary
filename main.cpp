#include "vocabularymodel.h"
#include "vocabularylistmodel.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QQuickItem>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    VocabularyModel model;
    model.fillModelFromCsv(":/database/waddensea_vocabulary.csv");
    VocabularyListModel listModel;
    listModel.setSourceModel(&model);
    //VocabularyModel model;

//    QQmlApplicationEngine engine;
//    QQmlContext *ctxt = engine.rootContext();

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setHeight(480);
    view.setWidth(640);
    QQmlContext *ctxt = view.rootContext();

    ctxt->setContextProperty("VocabularyModel", &listModel);
    view.setSource(QUrl("qrc:/AppWindow.qml"));
    listModel.connect(view.rootObject()->findChild<QObject*>("LanguageButton"), SIGNAL(sortBy(QVariant)), SLOT(sortBy(QVariant)));
    //ctxt->setContextProperty("DictionaryModel", &model);
    //engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    view.show();

    return app.exec();
}

