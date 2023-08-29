#ifndef RESULTMODEL_H
#define RESULTMODEL_H
#include <QSqlQueryModel>
#include <QSqlQuery>
#include <QDebug>
#include <QSqlRecord>

class ResultModel : public QSqlQueryModel
{
    Q_OBJECT
public:
    ResultModel();
    Q_INVOKABLE bool setResultQuery(QString word, QString wordType, int resultLanguage);
};

#endif // RESULTMODEL_H
