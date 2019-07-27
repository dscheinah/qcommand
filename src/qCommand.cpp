#include <QtQuick>
#include <sailfishapp.h>
#include "commandengine.h"
#include "develsu.h"
#include "completion.h"

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

    CommandEngine* engine = new CommandEngine();

    qmlRegisterType<DevelSu>("qCommand", 1, 0, "DevelSu");
    qmlRegisterType<Completion>("qCommand", 1, 0, "Completion");

    QQuickView* view = SailfishApp::createView();
    view->rootContext()->setContextProperty("cengine", engine);
    view->setSource(SailfishApp::pathTo("qml/qCommand.qml"));

    QObject* emitter = recursiveFind(view->rootObject(), "cengine");

    QObject::connect(emitter, SIGNAL(exec(QString, bool)), engine, SLOT(exec(QString, bool)));
    QObject::connect(emitter, SIGNAL(execAsRoot(QString, bool, QString)), engine, SLOT(execAsRoot(QString, bool, QString)));

    view->show();
    return app->exec();
}

