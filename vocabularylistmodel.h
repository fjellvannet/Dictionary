#ifndef VOCABULARYLISTMODEL_H
#define VOCABULARYLISTMODEL_H
#include <QSortFilterProxyModel>



class VocabularyListModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    VocabularyListModel(QObject *parent = 0);
public slots:
    void sortBy(QVariant role);
protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;
private:
    QStringList m_preSort;
};

#endif // VOCABULARYLISTMODEL_H
