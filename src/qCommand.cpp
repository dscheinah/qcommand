//#ifdef QT_QML_DEBUG
#include <QtQuick>
//#endif

#include <sailfishapp.h>
#include "commandengine.h"

QObject* recursiveFind(QObject* item, QString name)
{
  if (item->objectName() == name)
  {
    return item;
  }
  QObject* result = NULL;
  QObjectList list = item->children();
  for (int i = 0; i < list.count(); i++)
  {
    QObject* element = list[i];
    result = recursiveFind(element, name);
    if (result != NULL)
    {
        return result;
    }
  }
  return result;
}

int main(int argc, char *argv[])
{
    QGuiApplication* app = SailfishApp::application(argc, argv);
    QQuickView* view = SailfishApp::createView();
    view->setSource(SailfishApp::pathTo("qml/qCommand.qml"));
    view->show();

    QObject* emitter = recursiveFind(view->rootObject(), "Main");
    CommandEngine* engine = new CommandEngine();
    emitter->connect(emitter, SIGNAL(exec(QString)), engine, SLOT(exec(QString)));

    return app->exec();
}

