#include "vocabularymodel.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QSortFilterProxyModel>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    VocabularyModel model;
    model.fillModelFromCsv(":/database/waddensea_vocabulary.csv");
    QSortFilterProxyModel listModel;
    listModel.setSourceModel(&model);
    //VocabularyModel model;

    QQmlApplicationEngine engine;

    QQmlContext *ctxt = engine.rootContext();

//    QQuickView view;
//    view.setResizeMode(QQuickView::SizeRootObjectToView);
//    QQmlContext *ctxt = view.rootContext();

    ctxt->setContextProperty("VocabularyModel", &listModel);
    //ctxt->setContextProperty("DictionaryModel", &model);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    //view.setSource(QUrl("qrc:/AppWindow.qml"));
    //view.show();

    return app.exec();
}

