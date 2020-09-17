#include <QtQuick>
#include <sailfishapp.h>
#include "commandengine.h"
#include "developer.h"
#include "completion.h"
#include "fingerterm.h"
#include "secrets.h"

QObject* recursiveFind(QObject* item, QString name)
{
  if (item->objectName() == name)
  {
    return item;
  }
  QObject* result = NULL;
  QObjectList list = item->children();
  int length = list.count();
  for (int i = 0; i < length; i++)
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
    Fingerterm* finger = new Fingerterm();

    qmlRegisterType<Developer>("qCommand", 1, 0, "Developer");
    qmlRegisterType<Completion>("qCommand", 1, 0, "Completion");
    qmlRegisterType<Secrets>("qCommand", 1, 0, "Secrets");

    QQuickView* view = SailfishApp::createView();
    view->rootContext()->setContextProperty("cengine", engine);
    view->setSource(SailfishApp::pathTo("qml/qCommand.qml"));

    QObject* emitter = recursiveFind(view->rootObject(), "cengine");

    QObject::connect(emitter, SIGNAL(exec(QString, bool)), engine, SLOT(exec(QString, bool)));
    QObject::connect(emitter, SIGNAL(execAsRoot(QString, bool, QString)), engine, SLOT(execAsRoot(QString, bool, QString)));
    QObject::connect(emitter, SIGNAL(execInteractive(QString)), finger, SLOT(execInteractive(QString)));
    QObject::connect(emitter, SIGNAL(execAsRootInteractive(QString)), finger, SLOT(execAsRootInteractive(QString)));

    view->show();
    return app->exec();
}

