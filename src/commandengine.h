#ifndef COMMANDENGINE_H
#define COMMANDENGINE_H

#include <QObject>
#include <QString>

class CommandEngine : public QObject
{
    Q_OBJECT
private:
    int main[3];
    int child[3];

public:
    explicit CommandEngine(QObject *parent = 0);
    ~ CommandEngine();

private:
    int run(QString command);

signals:
    void output(QString data);

public slots:
    void exec(QString cmd, bool emitOutput);
};

#endif // COMMANDENGINE_H
