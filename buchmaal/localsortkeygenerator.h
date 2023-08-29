#ifndef LOCALSORTKEYGENERATOR_H
#define LOCALSORTKEYGENERATOR_H

#include <QVector>
#include <QStringBuilder>
#include <QtDebug>

class LocalSortKeyGenerator {
 public:
  LocalSortKeyGenerator();
  void addReplacePair(const QChar a_value, const QString a_replacement);
  QString toString();
  void setMaxLength(int a_maxLength);
  int maxLength();
  QPair<QString, QChar> sortKey(const QString& input);
 private:
  struct ReplacePair {
    QChar value;
    QString replacement;

    ReplacePair() {}
    ReplacePair(QChar a_value, QString a_replacement) {
      value = a_value;
      replacement = a_replacement;
    }

    QString toString() {
      return value % " -> " % replacement;
    }
  };
  QVector<ReplacePair> m_replace_pairs;
  int m_maxLength = INT_MAX;
};

#endif // LOCALSORTKEYGENERATOR_H
