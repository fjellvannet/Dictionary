#ifndef MYQQUICKWINDOW_H
#define MYQQUICKWINDOW_H

#include <QQuickWindow>
#include <QSettings>
#include <QRect>
#include <QDesktopWidget>
#include <QApplication>

class MyQQuickWindow : public QQuickWindow
{
    Q_OBJECT

public:
    QSettings *m_settings;
    MyQQuickWindow();
    void loadGeometry();
    void setSettings(QSettings *settings);

public slots:
    void saveGeometry();
};

#endif // MYQQUICKWINDOW_H
