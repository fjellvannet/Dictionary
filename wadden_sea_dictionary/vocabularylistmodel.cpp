#include "vocabularylistmodel.h"

VocabularyListModel::VocabularyListModel(VocabularyModel *a_sourceModel, QObject *parent)
    : QSortFilterProxyModel(parent)
{
    m_sourceModel = a_sourceModel;
    setSourceModel(m_sourceModel);
}

QVariant VocabularyListModel::at(int row, int role)
{
    return m_sourceModel->at(row, role);
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
    else if(column == 3) //Dänisch - Reihenfolge von ÅÆØ zu ÆØÅ ändern
    {
        for(int row = 0; row < rowCount(); ++row)
        {//es müssen großbuchstaben ersetzt werden, da die verschiedenen Replaces sich sonst behindern.
            m_preSort.append(sourceModel()->data(index(row, column), column).toString().toLower().remove(QRegExp("^\\(.*\\)\\s*")).replace("æ", "Å").replace("ø", "Æ").replace("å", "Ø"));
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
