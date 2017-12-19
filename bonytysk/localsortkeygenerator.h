#ifndef LOCALSORTKEYGENERATOR_H
#define LOCALSORTKEYGENERATOR_H

#include <QVector>
#include <QStringBuilder>

class LocalSortKeyGenerator
{
public:
    LocalSortKeyGenerator();
    void addReplacePair(const QChar a_value, const QString a_replacement);
    QString toString();
    void setMaxLength(int a_maxLength);
    int maxLength();
    QString sortKey(const QString& input);
private:
    struct replace_pair {
        QChar value;
        QString replacement;

        replace_pair(){}
        replace_pair(QChar a_value, QString a_replacement){
            value = a_value;
            replacement = a_replacement;
        }

        QString toString(){
            return value % " -> " % replacement;
        }
    };
    QVector<replace_pair> m_replace_pairs;
    int m_maxLength = INT_MAX; //bitweises not 0 - so this is the maximum value
};

#endif // LOCALSORTKEYGENERATOR_H
