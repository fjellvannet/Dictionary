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

private:
    Qt::WindowFlags defaultFlags;
public:
    QSettings *m_settings;
    MyQQuickView();
    void setSettings(QSettings *settings);

public slots:
    void loadGeometry();
    void saveGeometry();
};

#endif // MYQQUICKVIEW_H
