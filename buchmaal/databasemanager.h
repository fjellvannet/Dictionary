#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QtCore>
#include <QtSql>
#include <QStringBuilder>


class DatabaseManager: public QObject {
  Q_OBJECT

 public:
  DatabaseManager();
  QString downloadToString();
  void openDatabaseConnection();
  static QVariant directQuery(QString sqlSelect, QString errorMessage = "");

 public slots:
  bool updateWordList(bool skipHashCheck = false);

 private:
  // Functions
  bool connectDatabase();
  bool copyOrReplaceDatabaseFile(bool overwrite = true);
  bool createTableStructure();
  bool updateWordListInfo(QDateTime* lastUpdatedTimestamp, int length = 0, QByteArray* sha512Hash = nullptr);
  QString getUpdatedWordlist();
  QStringList prepareRawWordList(QString* rawWordList);
  QSet<QString> getCurrentWordSet();
  bool splitWordLines(QVector<QVector<QStringRef>>* result, QSet<QString>* wordLines);
  bool insertNewWords(QSet<QString>* wordsToAdd);
  bool deleteRemovedWords(QSet<QString>* wordsToRemove);

  // Constants
  const QUrl DOWNLOAD_LINK = QUrl("https://www.heinzelnisse.info/Downloads/heinzelliste.js");
  const QFileInfo DATABASE_FILE = QFileInfo(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) +
                                            "/buchmaal-database.sqlite");
  const QString TABLENAME = "wordlist";
  const QStringList WORDLIST_COLUMNS = QStringList({"NO", "NO_type", "NO_add_query", "NO_comment",
                                                    "DE", "DE_type", "DE_add_query", "DE_comment", "DE_category",
                                                    "NO_sort", "NO_sect", "DE_sort", "DE_sect"
                                                   });
  const QStringList WORDLIST_INFO_COLUMNS = QStringList({
    "LAST_UPDATED_TIMESTAMP", "RAW_FILE_LENGTH", "RAW_FILE_SHA512_HASH"});
  const QString MSG_TABLES_EXIST = "tables exist";
  const QString SQL_TABLES_EXISTING = QString(
                                        "SELECT CASE WHEN COUNT(*) == 2 THEN '%1' ELSE 'tables don''t exist' END "
                                        "FROM SQLITE_MASTER WHERE TYPE = 'table' "
                                        "AND NAME IN ('WORDLIST', 'WORDLIST_INFO')").arg(MSG_TABLES_EXIST);
  const QString SQL_CREATE_WORDLIST_INFO =
    "CREATE TABLE IF NOT EXISTS WORDLIST_INFO ("
    "LAST_UPDATED_TIMESTAMP TEXT, RAW_FILE_LENGTH INTEGER, RAW_FILE_SHA512_HASH TEXT)";
  const QString SQL_INSERT_INITIAL_WORDLIST_INFO =
    "INSERT INTO WORDLIST_INFO VALUES(NULL, NULL, NULL)";
  const QString SQL_CREATE_WORDLIST =
    "CREATE TABLE IF NOT EXISTS WORDLIST (" + WORDLIST_COLUMNS.join(" TEXT, ") + " TEXT)";
  const QString SQL_SELECT_WORDLIST_INFO = "SELECT * FROM WORDLIST_INFO";
  const QString SQL_SELECT_WORDLIST = "SELECT %1 FROM WORDLIST";
  const QString SQL_UPDATE_INFO = "UPDATE WORDLIST_INFO SET %1";

  const QString ERROR_TABLES_NOT_CREATED = "The table structure hasn't been initialized.";
  const int BATCHSIZE = 1000;
};

#endif // DATABASEMANAGER_H
