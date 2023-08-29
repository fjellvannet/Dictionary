#include "resultmodel.h"

ResultModel::ResultModel()
{

}

bool ResultModel::setResultQuery(QString word, QString wordType, int resultLanguage)
{
    QSqlQuery query;
    query.prepare(QStringLiteral("SELECT %1, %1_type FROM heinzelliste "
        "WHERE %2=:word AND %2_type=:wordType ORDER BY %1_sort").arg(
        resultLanguage == 1 ? "DE" : "NO", resultLanguage == 1 ? "NO" : "DE"));
    query.bindValue(":word", word);
    query.bindValue(":wordType", wordType);
    return query.exec() && query.first();
}
