#ifndef DICTIONARYMODEL_H
#define DICTIONARYMODEL_H

#include "vocabularymodel.h"
#include <QRegularExpression>
#include <QRegularExpressionMatch>

class DictionaryModel : public QAbstractTableModel
{
    Q_OBJECT
public:
    enum Roles {
        DeutschRole         ,
        EnglishRole         ,
        NederlandsRole      ,
        DanskRole           ,
        ScientificRole      ,
        ResultWordRole      ,
        ResultLanguageRole  ,
    };

    DictionaryModel(VocabularyModel *a_sourceModel, QObject *parent = 0);
    void fillWithSearchResults(QString a_searchPattern, int a_language, bool a_findUmlauts);

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role = -1) const;

public slots:
    void search(QVariant v_searchPattern, QVariant v_language, QVariant v_findUmlauts);

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    VocabularyModel *m_sourceModel;
    QList<QModelIndex> *m_searchResultIndexes;
    QRegularExpression *m_searchPattern;

    QString findUmlauts(QString regex,bool replace);
};

#endif // DICTIONARYMODEL_H
