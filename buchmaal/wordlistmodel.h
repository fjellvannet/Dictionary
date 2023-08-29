#ifndef WORDLISTMODEL_H
#define WORDLISTMODEL_H
#include <QSqlQueryModel>
#include <QSqlQuery>
#include <QVector>
#include <QDebug>
#include <buchmaal/localsortkeygenerator.h>

class WordListModel : public QSqlQueryModel
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

    //getters and setters
    SortLanguage sortLanguage() const;

    QVector<QPair<QString, QChar>> *sortKeys() const;
    QVariant data(const QModelIndex &ind, int role = -1) const override;
    Q_INVOKABLE QVariant at(int row, int role = -1);
    Q_INVOKABLE void sortBy(int role);
    Q_INVOKABLE void setSortLanguage(const SortLanguage &a_sortLanguage);

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    //member variables
    SortLanguage m_sortLanguage;
};

#endif // WORDLISTMODEL_H
