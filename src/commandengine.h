#ifndef COMMANDENGINE_H
#define COMMANDENGINE_H

#include <QObject>
#include <QProcess>
#include <QString>

class CommandEngine : public QObject
{
    Q_OBJECT
protected:
    QProcess* process;

public:
    CommandEngine();

protected:
    void create(bool emitOutput);

signals:
    void output(QString data);
    void error(QString data);
    void errorState();

public slots:
    void exec(QString cmd, bool emitOutput);
    void execAsRoot(QString cmd, bool emitOutput, QString password);
    void finished(int status);
    void finishedErrorOnly(int status);
};

#endif // COMMANDENGINE_H
