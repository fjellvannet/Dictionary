#ifndef MYQQUICKVIEW_H
#define MYQQUICKVIEW_H

#include <QQuickView>
#include <QSettings>
#include <QRect>
#include <QDesktopWidget>
#include <QApplication>


class MyQQuickView : public QQuickView
{
    Q_OBJECT
public:
    QSettings *m_settings;
    MyQQuickView();
    void loadGeometry();
    void setSettings(QSettings *settings);

public slots:
    void saveGeometry();
};

#endif // MYQQUICKVIEW_H
