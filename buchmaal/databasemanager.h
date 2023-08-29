#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H
#include <QtCore>
#include "progressmanager.h"

class DatabaseManager: public QObject {
  Q_OBJECT

  Q_PROPERTY(QDateTime wordListLastUpdated MEMBER wordListUpdateLocal NOTIFY wordListUpdateCompleted)

 public:
  explicit DatabaseManager(QObject* parent = nullptr);
  static bool openDatabaseConnection();
  static QVariant directQuery(QString sqlSelect, QString errorMessage = "");

 public slots:
  bool executeWordListUpdate();

 signals:
  void sendCurrentStep(QString currentStep);
  void sendCurrentStepProgress(double value, QString formattedValue);
  void wordListUpdateCompleted(QString message);
  Q_INVOKABLE void cancelWordListUpdate();
  Q_INVOKABLE void startWordListUpdate();

 private:
  inline static bool copyOrReplaceDatabaseFile(const QFileInfo& databaseFile, bool overwrite = true);
  inline static bool connectDatabase(const QFileInfo& databaseFile);
  QPair<bool, QString> updateWordList();
  inline void prepareProgressManager(ProgressManager& progressManager);
  QDateTime getWordListUpdatedOnServer(ProgressManager& progressManager);
  inline bool createTableStructure(ProgressManager& progressManager);
  QString getUpdatedWordlist();
  QStringList prepareRawWordList(QString& rawWordList);
  QSet<QString> getCurrentWordSet();
  bool splitWordLines(QVector<QVector<QStringView>>& result, QSet<QString>& wordLines);
  void updateWordListInDatabase(ProgressManager& progressManager, QSet<QString>& wordsToAdd,
                                QSet<QString>& wordsToRemove);
  void insertNewWords(ProgressManager& progressManager, QSet<QString>& wordsToAdd);
  void deleteRemovedWords(ProgressManager& progressManager, QSet<QString>& wordsToRemove);
  bool updateWordListInfo(QDateTime wordListUpdateLocal, QDateTime wordListUpdateServer = QDateTime());
  QString wordListUpdateCompletedMessage(int insertedWords, int removedWords);

  QDateTime wordListUpdateLocal;
};

#endif // DATABASEMANAGER_H
