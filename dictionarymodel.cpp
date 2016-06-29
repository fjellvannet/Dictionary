#include "dictionarymodel.h"

DictionaryModel::DictionaryModel(VocabularyModel *a_sourceModel, QObject *parent)
    :QAbstractTableModel(parent)
{
     m_sourceModel = a_sourceModel;
     m_searchPattern = new QRegularExpression();
     m_searchResultIndexes = new QList<QModelIndex>;
}

void DictionaryModel::fillWithSearchResults(QString a_searchPattern, int a_language, bool a_findUmlauts)
{
    unsigned int limitSearchResults = 100; /*beschreibt, wie viele Ergebnisse maximal angezeigt werden
    ~0; schreibt den Maximalwert in den unsigned int (0 wird bitweise zu nur Einsen umgedreht) und steht dabei für die Anzeige aller möglichen Ergebnisse*/
    m_searchPattern = new QRegularExpression(findUmlauts(a_searchPattern, a_findUmlauts), QRegularExpression::CaseInsensitiveOption);
    beginResetModel();
    m_searchResultIndexes->clear();
    endResetModel();
    if (m_searchPattern->pattern().isEmpty()) return;
    QList<QModelIndex> *searchResultIndexes = new QList<QModelIndex>;
    if(a_language == 4)//alle Sprachen
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
            if(searchResultIndexes->count() >= limitSearchResults) break;
        }
    }
    else
    {
        for(int row = 0; row < m_sourceModel->rowCount(); ++row)
        {
            QModelIndex index = m_sourceModel->index(row, a_language);
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
            if(searchResultIndexes->count() >= limitSearchResults) break;
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
    return 7;
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
    else// role == ResultLanguageRole
    {
        return m_searchResultIndexes->at(index.row()).column();
    }
}

void DictionaryModel::search(QVariant v_searchPattern, QVariant v_language, QVariant v_findUmlauts)
{
    fillWithSearchResults(v_searchPattern.toString(), v_language.toInt(), v_findUmlauts.toBool());
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

/**
 * @brief MainWindow::findUmlauts sorgt dafür, dass zum Beispiel beim Suchen von groesse auch Größe gefunden wird
 * @param regex QString: der anzupassende String
 * @param replace bool: aktiviert oder deaktiviert die Funktion (ob sie die regex verändert oder nicht)
 * @return
 */
QString DictionaryModel::findUmlauts(QString regex, bool replace)
{
    if(replace)
    {
        regex = regex.toLower();
        regex.replace(QRegularExpression("([aou]e)"), "\\1{0,1}");//wenn das e als Umlaut-e gemeint war, auch nach gar kein e Suchen (vorderer Buchstabe wird nachher durch Umlaut erstetzt)
        regex.replace(QRegularExpression("aa"), "a{1,2}");
        regex.replace(QRegularExpression("ss"), "(ss|ß)");//bei ss auch ß finden
        regex.replace(QRegularExpression("a"), "[aäåæ]");
        regex.replace(QRegularExpression("o"), "[oöø]");
        regex.replace(QRegularExpression("u"), "[uü]");
    }
    return regex;
}
