#include "WordListModel.h"

WordListModel::WordListModel()
{
    m_sortLanguage = unsorted;
}

WordListModel::SortLanguage WordListModel::sortLanguage() const
{
    return m_sortLanguage;
}

QVariant WordListModel::data(const QModelIndex &ind, int role) const
{
    return QSqlQueryModel::data(index(ind.row(), role), 0);
}

void WordListModel::setSortLanguage(const WordListModel::SortLanguage &a_sortLanguage)
{
    if(sortLanguage() == unsorted || sortLanguage() != a_sortLanguage) {
        beginResetModel();
        m_sortLanguage = a_sortLanguage;
        switch(sortLanguage()) {
            case Deutsch:
                qDebug().noquote() << "sorted in German";
                setQuery("SELECT DISTINCT DE,DE_type,DE_Sect FROM heinzelliste ORDER BY DE_Sort,DE_type");
                break;
            case Bokmaal:
                qDebug().noquote() << "sorted in Bokmaal";
                setQuery("SELECT DISTINCT NO,NO_type,NO_Sect FROM heinzelliste ORDER BY NO_Sort,NO_type");
                break;
            default:
                ;//feilmelding
        }
        while(canFetchMore()) fetchMore();
        endResetModel();
    }
}

QVariant WordListModel::at(int row, int role)
{
    return(data(index(row, role), role));
}

void WordListModel::sortBy(int role)
{
    switch(role) {
        case 0:
            setSortLanguage(Deutsch);
            break;
        case 1:
            setSortLanguage(Bokmaal);
            break;
        default:
            qWarning() << "WordListModel: Sort Language not changed, invalid sort language Role.";
    }
}

QHash<int, QByteArray> WordListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[WordRole    ] = "Word";
    roles[WordTypeRole] = "WordType";
    roles[SectionRole ] = "SectionLetter";
    return roles;
}
