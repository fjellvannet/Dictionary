#ifndef WORDLISTMODEL_H
#define WORDLISTMODEL_H
#include <QSortFilterProxyModel>
#include <QSqlQueryModel>
#include <QVector>

class WordListModel : public QSortFilterProxyModel
{
public:
    enum Language{
        Deutsch,
        Bokmaal,
        Nynorsk
    };

    WordListModel();
    void sortByLanguage(Language a_language);
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const;

    //getters and setters
    Language language() const;
    void setLanguage(const Language &a_language);

    QSqlQueryModel *sourceSqlModel() const;
    void setSourceSqlModel(QSqlQueryModel *a_sourceSqlModel);

    QVector<QString> sortKeys() const;
    void setSortKeys(const QVector<QString> &a_sortKeys);

private:
    //member variables
    Language m_language;
    QSqlQueryModel *m_sourceSqlModel;
    QVector<QString> m_sortKeys;
};

#endif // WORDLISTMODEL_H
