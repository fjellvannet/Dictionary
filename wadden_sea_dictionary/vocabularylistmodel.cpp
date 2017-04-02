#include "vocabularylistmodel.h"

VocabularyListModel::VocabularyListModel(VocabularyModel *a_sourceModel, QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setSourceModel(a_sourceModel);
}

void VocabularyListModel::sortBy(QVariant role)
{
    int column = role.toInt();
    if(column == 0) //Deutsch, sicherstellen, dass Ä, Ö und Ü eingereiht werden
    {
        for(int row = 0; row < rowCount(); ++row)
        {
            m_preSort.append(sourceModel()->data(index(row, column), column).toString().toLower().remove(QRegExp("^\\(.*\\)\\s*")).replace("ä", "a").replace("ö", "o").replace("ü", "u"));
        }
    }
    else
    {
        for(int row = 0; row < rowCount(); ++row)
        {
            m_preSort.append(sourceModel()->data(index(row, column), column).toString().toLower().remove(QRegExp("^\\(.*\\)\\s*")));
        }
    }
    sort(column);
    m_preSort.clear();
}

bool VocabularyListModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    return m_preSort.at(left.row()) < m_preSort.at(right.row());
}
