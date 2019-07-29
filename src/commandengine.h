#ifndef COMMANDENGINE_H
#define COMMANDENGINE_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QVariant>

class CommandEngine : public QObject
{
    Q_OBJECT
protected:
    QProcess* process;

public:
    CommandEngine();

protected:
    void create(bool emitOutput);

private:
    QVariantList parse(QString output);

signals:
    void output(QVariantList data);
    void error(QVariantList data);
    void errorState();

public slots:
    void exec(QString cmd, bool emitOutput);
    void execAsRoot(QString cmd, bool emitOutput, QString password);
    void finished(int status);
    void finishedErrorOnly(int status);
};

#endif // COMMANDENGINE_H
