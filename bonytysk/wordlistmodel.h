#ifndef WORDLISTMODEL_H
#define WORDLISTMODEL_H
#include <QSortFilterProxyModel>
#include <QSqlQueryModel>
#include <QVector>

class WordListModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    enum Roles {
        WordRole,
        WordTypeRole,
        SectionRole
    };

    enum SortLanguage{
        Deutsch,
        Bokmaal,
        Nynorsk,
        unsorted
    };

    WordListModel();
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;
    QVariant data(const QModelIndex &ind, int role = -1) const override;

    //getters and setters
    SortLanguage sortLanguage() const;

    QSqlQueryModel *sourceSqlModel() const;
    void setSourceSqlModel(QSqlQueryModel *a_sourceSqlModel);

    QVector<QPair<QString, QChar>> sortKeys() const;
    Q_INVOKABLE QVariant at(int row, int role = -1);

public slots:
    void setSortLanguage(const SortLanguage &a_sortLanguage);

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    //member variables
    SortLanguage m_sortLanguage;
    QSqlQueryModel *m_sourceSqlModel;
    QVector<QPair<QString, QChar>> m_sortKeys;
};

#endif // WORDLISTMODEL_H
