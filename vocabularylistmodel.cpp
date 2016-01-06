#include "vocabularylistmodel.h"
#include <QDebug>

VocabularyListModel::VocabularyListModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
}

void VocabularyListModel::sortBy(QVariant role)
{
    int column = role.toInt();
    for(int row = 0; row < rowCount(); ++row)
    {
        m_preSort.append(sourceModel()->data(index(row, column), column).toString().toUpper().remove(QRegExp("^\\(.*\\)\\s*")));
    }
    sort(column);
    m_preSort.clear();
}

bool VocabularyListModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    return m_preSort.at(left.row()) < m_preSort.at(right.row());
}
