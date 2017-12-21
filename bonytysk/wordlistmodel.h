#ifndef WORDLISTMODEL_H
#define WORDLISTMODEL_H
#include <QSortFilterProxyModel>
#include <QSqlQueryModel>
#include <QVector>

class WordListModel : public QSortFilterProxyModel
{
public:
    enum SortLanguage{
        Deutsch,
        Bokmaal,
        Nynorsk,
        unsorted
    };

    WordListModel();
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const;

    //getters and setters
    SortLanguage sortLanguage() const;
    void setSortLanguage(const SortLanguage &a_sortLanguage);

    QSqlQueryModel *sourceSqlModel() const;
    void setSourceSqlModel(QSqlQueryModel *a_sourceSqlModel);

    QVector<QString> sortKeys() const;

private:
    //member variables
    SortLanguage m_sortLanguage;
    QSqlQueryModel *m_sourceSqlModel;
    QVector<QString> m_sortKeys;
};

#endif // WORDLISTMODEL_H
