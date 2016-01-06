#include "vocabularylistmodel.h"
#include <QDebug>

VocabularyListModel::VocabularyListModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
}

void VocabularyListModel::sortBy(QVariant role)
{
    int column = role.toInt();
    m_preSort.clear();
    for(int row = 0; row < rowCount(); ++row)
    {
        m_preSort.append(sourceModel()->data(index(row, column), column).toString().toLower().remove(QRegExp("^\\(.*\\)\\s*")));
    }
    sort(column);
//    for(int i = 0; i < rowCount(); ++i)
//    {
//        qDebug() << data(index(i, role.toInt())) << QString::number(role.toInt());
//    }
}

bool VocabularyListModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    return m_preSort.at(left.row()) < m_preSort.at(right.row());
}
