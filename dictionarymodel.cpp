#include "dictionarymodel.h"

DictionaryModel::DictionaryModel(VocabularyModel *a_sourceModel, QObject *parent)
    :QAbstractTableModel(parent)
{
     m_sourceModel = a_sourceModel;
     m_searchPattern = new QRegularExpression();
     m_searchResultIndexes = new QList<QModelIndex>;
}

void DictionaryModel::fillWithSearchResults(QString a_searchPattern, int language)
{
    m_searchPattern = new QRegularExpression(a_searchPattern, QRegularExpression::CaseInsensitiveOption);
    beginResetModel();
    m_searchResultIndexes->clear();
    endResetModel();
    QList<QModelIndex> *searchResultIndexes = new QList<QModelIndex>;
    if(language == 4)//alle Sprachen
    {
        for(int row = 0; row < m_sourceModel->rowCount(); ++row)
        {
            bool exists = false;//um zu umgehen, dass das Wort mehrmals auftaucht, wegen einem Treffer im lat. Namen
            for(int column = 0; column <= 3; ++column)
            {
                QModelIndex index = m_sourceModel->index(row, column);
                if(m_searchPattern->match(m_sourceModel->data(index).toString()).hasMatch())
                {
                    searchResultIndexes->append(index);
                    exists = true;
                }
            }
            if(!exists)
            {
                QModelIndex index = m_sourceModel->index(row, 4);
                if(m_searchPattern->match(m_sourceModel->data(index).toString()).hasMatch())
                {
                    searchResultIndexes->append(index);
                }
            }
        }
    }
    else
    {
        for(int row = 0; row < m_sourceModel->rowCount(); ++row)
        {
            QModelIndex index = m_sourceModel->index(row, language);
            if(m_searchPattern->match(m_sourceModel->data(index).toString()).hasMatch())
            {
                searchResultIndexes->append(index);
            }
            else
            {
                index = m_sourceModel->index(row, 4);//Scientific zusätzlich immer überprüfen
                if(m_searchPattern->match(m_sourceModel->data(index).toString()).hasMatch())
                {
                    searchResultIndexes->append(index);
                }
            }
        }
    }
    if(searchResultIndexes->count() > 0)
    {
        beginInsertRows(QModelIndex(), 0, searchResultIndexes->count() - 1);
        m_searchResultIndexes = searchResultIndexes;
        endInsertRows();
    }
}

int DictionaryModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return m_searchResultIndexes->count();
}

int DictionaryModel::columnCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent);
    return 5;
}

QVariant DictionaryModel::data(const QModelIndex & index, int role) const
{
    if ((index.row() < 0 || index.row() >= rowCount()) || (role < -1 || role > ResultLanguageRole))
    {
        return QVariant();
    }
    if(role == -1)
    {
        role = index.column();
    }

    if(role == ResultWordRole)
    {
        return m_sourceModel->data(m_searchResultIndexes->at(index.row()));
    }
    else if(role <= ScientificRole)
    {
        return m_sourceModel->data(m_sourceModel->index(m_searchResultIndexes->at(index.row()).row(), role));
    }
    //else - role == ResultLanguageRole
    return m_searchResultIndexes->at(index.row()).column();
}

void DictionaryModel::search(QVariant v_searchPattern, QVariant v_language)
{
    fillWithSearchResults(v_searchPattern.toString(), v_language.toInt());
}

QHash<int, QByteArray> DictionaryModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[DeutschRole         ] = "Deutsch";
    roles[EnglishRole         ] = "English";
    roles[NederlandsRole      ] = "Nederlands";
    roles[DanskRole           ] = "Dansk";
    roles[ScientificRole      ] = "Scientific";
    roles[ResultWordRole      ] = "ResultWord";
    roles[ResultLanguageRole  ] = "ResultLanguage";
    return roles;
}
