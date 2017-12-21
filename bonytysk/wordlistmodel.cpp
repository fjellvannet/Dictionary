#include "WordListModel.h"
#include <QDebug>
#include <QSqlQuery>
#include <bonytysk/localsortkeygenerator.h>

WordListModel::WordListModel()
{
    setSourceSqlModel(new QSqlQueryModel(this));
    m_sortLanguage = unsorted;
}

WordListModel::SortLanguage WordListModel::sortLanguage() const
{
    return m_sortLanguage;
}

void WordListModel::setSortLanguage(const WordListModel::SortLanguage &a_sortLanguage)
{
    if(sortLanguage() == unsorted || sortLanguage() != a_sortLanguage) {
        m_sortLanguage = a_sortLanguage;
        const int SORT_COLUMN = 0;
        LocalSortKeyGenerator generator;
        switch(sortLanguage()) {
            case Deutsch:
                qDebug().noquote() << "sorted in German";
                generator.addReplacePair(QString("ä").at(0), "a");
                generator.addReplacePair(QString("ö").at(0), "o");
                generator.addReplacePair(QString("ü").at(0), "u");
                generator.addReplacePair(QString("ß").at(0), "ss");
                sourceSqlModel()->setQuery("SELECT DISTINCT DE,DE_type FROM heinzelliste ORDER BY DE,DE_type");
                break;
            case Bokmaal:
                qDebug().noquote() << "sorted in Bokmaal";
                generator.addReplacePair(QString("æ").at(0), "Å");
                generator.addReplacePair(QString("ø").at(0), "Æ");
                generator.addReplacePair(QString("å").at(0), "Ø");
                sourceSqlModel()->setQuery("SELECT DISTINCT NO,NO_type FROM heinzelliste ORDER BY NO,NO_type");
                break;
            default:
                ;//feilmelding
        }

        int row;
        for(row = 0; 1; ++row)
        {
            QString word = data(index(row, SORT_COLUMN), SORT_COLUMN).toString();
            if(word.isEmpty()) {
                if(sourceSqlModel()->canFetchMore()) {
                    sourceSqlModel()->fetchMore();
                    word = data(index(row, SORT_COLUMN), SORT_COLUMN).toString();
                }
                else break;
            }
            m_sortKeys.append(generator.sortKey(word));
        }
        m_sortKeys.squeeze();
        sort(SORT_COLUMN);
    }
}

bool WordListModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    return m_sortKeys.at(left.row()) < m_sortKeys.at(right.row());
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
