#ifndef VOCABULARYLISTMODEL_H
#define VOCABULARYLISTMODEL_H
#include <QSortFilterProxyModel>
#include "vocabularymodel.h"

class VocabularyListModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    VocabularyListModel(VocabularyModel *a_sourceModel, QObject *parent = nullptr);
    Q_INVOKABLE QVariant at(int row, int role);
public slots:
    void sortBy(QVariant role);    
protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;
private:
    QVector<QString> m_preSort;
    VocabularyModel *m_sourceModel;
};

#endif // VOCABULARYLISTMODEL_H
