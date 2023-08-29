#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QtCore>
#include <QNetworkReply>

class ProgressManager : public QObject {
  Q_OBJECT
 public:
  explicit ProgressManager(QObject* parent = nullptr);
  inline static QString formatSecondsToTime(int seconds);
  inline static QString unitString(double value, QString unit = QLatin1String(), qint8 precision = 4);
  QByteArray download(QUrl downloadLink, QString stepName = QLatin1String());
  void setCurrentStep(QString stepName, QString unit = QLatin1String());
  void setFormat(QString formatAllStats = QLatin1String(), QString formatIndeterminateDoneSpeed = QLatin1String());
  static const QString OPERATION_CANCELLED_BY_USER;

 public slots:
  void emitCurrentStepProgress(qint64 doneOps, qint64 totOps);
  inline void cancelOperation() {
    operationCancelled = true;
  }

 signals:
  void sendCurrentStepProgress(double value, QString formattedValue = QLatin1String());
  void sendCurrentStep(QString stepDescription);

 private slots:
  void emitCurrentStep(bool withTime = true);

 private:
  inline bool checkOperationCancelled();
  inline double calculateFilteredSpeed(double& speed);
  QNetworkReply* downloadReply = nullptr;

  QString formatAllStats;
  QString formatIndeterminateDoneSpeed;

  bool operationCancelled = false;
  quint8 step = 0;
  QString unit;
  QString currentStepName;
  QElapsedTimer currentStepTime;
  QTimer updateStepTime;
  int stepSeconds;
  qint64 t_1 = 0, t_lastUpdated = 0;
  qint64 doneOps_t_1 = 0;
  double speed_filtered = 0;
  QQueue<int> speedQueue;
};

#endif // DOWNLOADMANAGER_H
