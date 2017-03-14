#include "closingobject.h"

void ClosingObject::setWindow(MyQQuickWindow *window)
{
    m_window = window;
}

ClosingObject::ClosingObject()
{
}

void ClosingObject::closingToGeometry()
{
    m_window->saveGeometry();
}
