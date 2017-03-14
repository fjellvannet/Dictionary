#ifndef CLOSINGOBJECT_H
#define CLOSINGOBJECT_H

#include "myqquickwindow.h"

class ClosingObject : public QObject
{
    Q_OBJECT
private:
    MyQQuickWindow *m_window;
public:
    ClosingObject();
    void setWindow(MyQQuickWindow *window);

public slots:
    void closingToGeometry();
};

#endif // CLOSINGOBJECT_H
