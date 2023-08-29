#include "progressmanager.h"
#include <QtCore>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#define ALPHA 0.9
#define FIR_LENGTH 3
#define FILTER_DIFFERENCE 0.8
#define SI_PREFIXES "yzafpnµm kMGTPEZY"
#define TIMER_INTERVAL_1_SEC 1000

const QString ProgressManager::OPERATION_CANCELLED_BY_USER = "OPERATION CANCELLED";

ProgressManager::ProgressManager(QObject* parent) : QObject(parent) {
  updateStepTime.setInterval(TIMER_INTERVAL_1_SEC);
  updateStepTime.callOnTimeout([ = ]() {
    this->emitCurrentStep();
  });
}

QByteArray ProgressManager::download(QUrl downloadLink, QString stepName) {
  QNetworkAccessManager manager;
  if (!stepName.isEmpty()) setCurrentStep(stepName, QLatin1String("B"));
  else if (!QSslSocket::supportsSsl()) throw tr("SSL libraries are not available");
  downloadReply = manager.get(QNetworkRequest(downloadLink));
  connect(downloadReply, &QNetworkReply::downloadProgress, this, &ProgressManager::emitCurrentStepProgress);
  QEventLoop sleeper;
  QObject::connect(downloadReply, &QNetworkReply::finished, &sleeper, &QEventLoop::quit);
  sleeper.exec();
  downloadReply->deleteLater();
  if (operationCancelled) {
    throw OPERATION_CANCELLED_BY_USER;
  } else {
    if (downloadReply->error() == QNetworkReply::NetworkError::NoError) {
      return downloadReply->readAll();
    } else {
      throw downloadReply->errorString();
    }
  }
}

double ProgressManager::calculateFilteredSpeed(double& speed) {
  speedQueue.append(speed);
  if (speedQueue.length() > FIR_LENGTH) speedQueue.dequeue();
  double avgSpeed = std::accumulate(speedQueue.constBegin(), speedQueue.constEnd(), 0) / speedQueue.length();
  if (qMin(avgSpeed, speed_filtered) / qMax(avgSpeed, speed_filtered) > FILTER_DIFFERENCE) {
    return ALPHA * speed_filtered + (1 - ALPHA) * avgSpeed;
  } else return avgSpeed;
}

void ProgressManager::emitCurrentStepProgress(qint64 doneOps, qint64 totOps) {
  checkOperationCancelled();
  if (doneOps == 0 && totOps == 0) throw tr("Download not possible, nothing to download.");
  if (unit.isEmpty()) return;
  qint64 delta_t = currentStepTime.elapsed() - t_1;
  t_1 += delta_t;
  qint64 delta_ops = doneOps - doneOps_t_1;
  doneOps_t_1 = doneOps;
  double speed = 1000.0 * delta_ops / delta_t; // times 1000 to get seconds instead of milliseconds
  speed_filtered = calculateFilteredSpeed(speed);
  if (currentStepTime.elapsed() - t_lastUpdated > 250) {
    QString& format = totOps == -1 ? formatIndeterminateDoneSpeed : formatAllStats;
    double percentage = (double) doneOps / totOps;
    int estimatedSecondsLeft = qRound((totOps - doneOps) / speed_filtered);
    QString result = format, empty, tagReplacement;
    int i = -1, j = -1;
    while (true) {
      j = format.lastIndexOf("%>", i);
      i = format.lastIndexOf("<%", j);
      if (i == -1 || j == -1) break;
      QString tag = format.mid(i + 2, j - i - 2);
      if (tag == "speed") {
        tagReplacement = unitString(speed_filtered, unit);
      } else if (tag == "unit-l") {
        tagReplacement = unit.length() <= 2 ? empty : unit;
      } else if (QRegularExpression("^done\\.unit-[sl]$").match(tag).hasMatch()) {
        tagReplacement = unitString(doneOps, tag.endsWith(QLatin1Char('l')) || unit.length() <= 2 ? unit : empty);
      } else if (QRegularExpression("^tot\\.unit-[sl]$").match(tag).hasMatch()) {
        tagReplacement = unitString(totOps, tag.endsWith(QLatin1Char('l')) || unit.length() <= 2 ? unit : empty);
      } else if (tag == "percentage") {
        tagReplacement =  QString::number(100 * percentage, 'f', 0) % QLatin1String(" %");
      } else if (tag == "estimateFormat") {
        tagReplacement = tr("left: %1").arg(formatSecondsToTime(estimatedSecondsLeft));
      }
      result = result.replace(i, j + 2 - i, tagReplacement);
    }
    emit sendCurrentStepProgress(totOps == -1 ? -1 : percentage, result);
    t_lastUpdated = currentStepTime.elapsed();
    if (totOps > -1) {
      qDebug().noquote() << tr("Percentage: ") << QString::number(100 * percentage, 'f', 1) % QLatin1String(" %")
                         << QString(unitString(doneOps, unit) % "/" % unitString(totOps, unit))
                         << tr("Speed: ") << (unit.length() <= 2 ? unitString(speed_filtered, unit + "/s") :
                                              unitString(speed_filtered) + "/s")
                         << tr("Left: %1").arg(formatSecondsToTime(estimatedSecondsLeft));
    } else {
      qDebug().noquote() << tr("Done: ") << unitString(doneOps, unit)
                         << tr("Speed: ") << unitString(speed_filtered) << unit + "/s";
    }
  }
}

void ProgressManager::setFormat(QString formatAllStats, QString formatIndeterminateDoneSpeed) {
  this->formatAllStats = formatAllStats;
  this->formatIndeterminateDoneSpeed = formatIndeterminateDoneSpeed;
}

void ProgressManager::setCurrentStep(QString currentStepName, QString unit) {
  checkOperationCancelled();
  if (step > 0) qDebug().noquote() << tr("Step %1: %2 has taken %3").arg(step).arg(this->currentStepName)
                                     .arg(QTime(0, 0).addMSecs(currentStepTime.elapsed()).toString("HH:mm:ss.zzz"));
  this->unit = unit;
  this->currentStepName = currentStepName;
  updateStepTime.start();
  currentStepTime.start();
  stepSeconds = 0; // like this, the first displayed time will be 00:00
  t_1 = 0;
  t_lastUpdated = 0;
  doneOps_t_1 = 0;
  speed_filtered = 0;
  step++;
  speedQueue.clear();
  qDebug().noquote() << tr("Step %1: %2").arg(step).arg(currentStepName);
  emitCurrentStep(false);
  if (unit.isEmpty()) emit sendCurrentStepProgress(-1);
  else emit sendCurrentStepProgress(0, QLatin1String("0 %"));
}

void ProgressManager::emitCurrentStep(bool withTime) {
  QString currentStep(tr("Step %1: %2").arg(step).arg(currentStepName));
  if (withTime) emit sendCurrentStep(QLatin1String("%1 (%2)").arg(currentStep).arg(formatSecondsToTime(++stepSeconds)));
  else emit sendCurrentStep(currentStep);
}

bool ProgressManager::checkOperationCancelled() {
  if (operationCancelled) {
    if (downloadReply != nullptr && downloadReply->isRunning()) downloadReply->abort();
    else throw OPERATION_CANCELLED_BY_USER;
  }
  return operationCancelled;
}

QString ProgressManager::unitString(double value, QString unit, qint8 precision) {
  int i = 0;
  while (value < 1 && i > -8) {
    value *= 1000;
    i--;
  }
  while (value >= 1000 && i < 8) {
    value /= 1000;
    i++;
  }
  return QString(QString::number(value, 'G', precision) % QLatin1String(unit.isEmpty() ? "" : " ") %
                 (i == 0 ? QChar() : QString(SI_PREFIXES).at(i + 8)) % unit);
}

QString ProgressManager::formatSecondsToTime(int seconds) {
  QTime stepTime = QTime(0, 0).addSecs(seconds);
  return stepTime.hour() >= 1 ? stepTime.toString("HH:mm:ss") : stepTime.toString("mm:ss");
}
