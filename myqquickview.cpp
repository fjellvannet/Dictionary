#include "myqquickview.h"

MyQQuickView::MyQQuickView()
{
    connect(this, SIGNAL(closing(QQuickCloseEvent*)), this, SLOT(saveGeometry()));
    //setColor(QColor("transparent"));
    //defaultFlags = flags();
    //setFlags(Qt::SplashScreen);
    m_settings = new QSettings();
}

void MyQQuickView::loadGeometry()
{
    QRect screen = QApplication::desktop()->screenGeometry(geometry().topLeft());
    QRect defaultSize = screen.height() <= screen.width() ? QRect(screen.width()/2-screen.height()/3, screen.height()/4, screen.height()*2/3, screen.height()/2) :
        QRect(screen.height()/2-screen.width()/6, screen.width()/4, screen.width()/2, screen.width()*1/3) ;
    setGeometry(m_settings->value("geometry", defaultSize).toRect());
    setResizeMode(QQuickView::SizeRootObjectToView);
    //setColor(QColor("white"));
    //setFlags(defaultFlags);
    switch(static_cast<Qt::WindowState>((quint8)m_settings->value("Window State").toUInt()))
    {
        case Qt::WindowNoState :
            show();
            break;
        case Qt::WindowMaximized :
            showMaximized();
            break;
        case Qt::WindowFullScreen :
            showFullScreen();
            break;
        default:
            show();
            break;
    }
}

void MyQQuickView::saveGeometry() {
    if(windowState() == Qt::WindowNoState) m_settings->setValue("geometry", geometry());
    m_settings->setValue("Window State", windowState());
}

void MyQQuickView::setSettings(QSettings *a_settings)
{
    m_settings = a_settings;
}
