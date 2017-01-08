#include "myqquickview.h"

MyQQuickView::MyQQuickView()
{
    QObject::connect(this, SIGNAL(closing(QQuickCloseEvent*)), this, SLOT(saveGeometry()));
}


void MyQQuickView::loadGeometry()
{
    if(windowState() == Qt::WindowNoState)
    {
        QRect screen = QApplication::desktop()->screenGeometry(geometry().topLeft());
        QRect defaultSize = screen.height() <= screen.width() ? QRect(screen.width()/2-screen.height()/3, screen.height()/4, screen.height()*2/3, screen.height()/2) :
                                                              QRect(screen.height()/2-screen.width()/6, screen.width()/4, screen.width()/2, screen.width()*1/3) ;
        setGeometry(m_settings->value("geometry", defaultSize).toRect());
    }
}

void MyQQuickView::saveGeometry() {
    if(windowState() == Qt::WindowNoState) m_settings->setValue("geometry",geometry());
}

void MyQQuickView::setSettings(QSettings *a_settings)
{
    m_settings = a_settings;
}
