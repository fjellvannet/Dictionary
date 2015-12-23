#include "vocabularymodel.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    VocabularyModel model;
    model.fillModelFromCsv(":/database/waddensea_vocabulary.csv");

    //VocabularyModel model;


    QQmlApplicationEngine engine;

    QQmlContext *ctxt = engine.rootContext();

//    QQuickView view;
//    view.setResizeMode(QQuickView::SizeRootObjectToView);
//    QQmlContext *ctxt = view.rootContext();

    ctxt->setContextProperty("myModel", &model);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    //view.setSource(QUrl("qrc:/AppWindow.qml"));
    //view.show();

    return app.exec();
}

