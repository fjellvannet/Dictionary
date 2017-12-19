#include "WordListModel.h"
#include <QDebug>
#include <QSqlQuery>
#include <bonytysk/localsortkeygenerator.h>

WordListModel::WordListModel()
{
    setSourceSqlModel(new QSqlQueryModel(this));
}

void WordListModel::sortByLanguage(Language a_language)
{
    if(language() != a_language){
        setLanguage(a_language);
    }
}

bool WordListModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    return m_sortKeys.at(left.row()) < m_sortKeys.at(right.row());
}

WordListModel::Language WordListModel::language() const
{
    return m_language;
}

void WordListModel::setLanguage(const Language &a_language)
{
    m_language = a_language;
    QSqlQuery query;
    query.exec("SELECT DISTINCT DE,DE_type FROM heinzelliste ORDER BY DE");
    const int SORT_COLUMN = 0;
    LocalSortKeyGenerator generator;
    //generator.setMaxLength(0);
//    switch(language()) {
//    case Deutsch:
        qDebug().noquote() << "Deutsch";
        generator.addReplacePair(QString("ä").at(0), "a");
        generator.addReplacePair(QString("ö").at(0), "o");
        generator.addReplacePair(QString("ü").at(0), "u");
        generator.addReplacePair(QString("ß").at(0), "ss");
//        sourceSqlModel()->setQuery("SELECT DISTINCT DE,DE_type FROM heinzelliste ORDER BY DE");
//    case Bokmaal:
//        generator.addReplacePair(QString("æ").at(0), "Å");
//        generator.addReplacePair(QString("ø").at(0), "Æ");
//        generator.addReplacePair(QString("å").at(0), "Ø");
        sourceSqlModel()->setQuery("SELECT DISTINCT NO,NO_type FROM heinzelliste ORDER BY NO");
//    default:
//        ;//feilmelding
//    }
    sortKeys().clear();
    while(sourceSqlModel()->canFetchMore())
        fetchMore(QModelIndex());

    qDebug() << data(index(0, 0)).toString();
    int row;
    for(row = 0; 1; ++row)
    {
        QString sortKey = generator.sortKey(sourceModel()->data(index(row, SORT_COLUMN), SORT_COLUMN).toString());
        if(sortKey.isEmpty()) break;
        else m_sortKeys.append(sortKey);
    }
    qDebug() << m_sortKeys.last();
    m_sortKeys.squeeze();
    sort(SORT_COLUMN);
    qDebug() << data(index(row - 1,0)).toString();
    m_sortKeys.clear();
}

QSqlQueryModel *WordListModel::sourceSqlModel() const
{
    return m_sourceSqlModel;
}

void WordListModel::setSourceSqlModel(QSqlQueryModel *a_sourceSqlModel)
{
    m_sourceSqlModel = a_sourceSqlModel;
    setSourceModel(sourceSqlModel());
}

QVector<QString> WordListModel::sortKeys() const
{
    return m_sortKeys;
}
