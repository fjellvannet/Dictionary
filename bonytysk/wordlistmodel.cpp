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
    return m_sortKeys.at(left.row()).first < m_sortKeys.at(right.row()).first;
}

QVariant WordListModel::data(const QModelIndex &ind, int role) const
{
    if(ind.isValid())
    {
        if(role == SectionRole)
        {
            return m_sortKeys.at(QSortFilterProxyModel::mapToSource(ind).row()).second;
        }
        else
        {
            return QSortFilterProxyModel::data(ind, role);
        }
    }
    else return QVariant();
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

QVariant WordListModel::at(int row, int role)
{
    qDebug().noquote() << data(index(row, role), role) << row << role;
    return(data(index(row, role), role));
}

QVector<QPair<QString, QChar>> WordListModel::sortKeys() const
{
    return m_sortKeys;
}

QHash<int, QByteArray> WordListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[WordRole    ] = "Word";
    roles[WordTypeRole] = "WordType";
    roles[SectionRole ] = "SectionLetter";
    return roles;
}
