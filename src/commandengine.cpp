#include "commandengine.h"

CommandEngine::CommandEngine(QObject *parent) : QObject(parent)
{
    process = nullptr;
}

void CommandEngine::exec(QString cmd, bool emitOutput)
{
    create(emitOutput);
    QStringList args;
    args << "-c" << cmd;
    process->start("bash", args, QProcess::ReadOnly);
    process->closeWriteChannel();
}

void CommandEngine::execAsRoot(QString cmd, bool emitOutput, QString password)
{
    create(emitOutput);
    process->start("devel-su");
    process->write((password + "\n").toUtf8().data());

    process->waitForReadyRead(500);
    process->readAllStandardError();

    process->write((cmd + "\n").toUtf8().data());
    process->closeWriteChannel();
}

void CommandEngine::create(bool emitOutput)
{
    if (process)
    {
        process->disconnect();
    }
    process = new QProcess();
    process->setReadChannel(QProcess::ProcessChannel::StandardError);
    if (emitOutput)
    {
        QObject::connect(process, SIGNAL(finished(int)), this, SLOT(finished(int)));
    }
}

void CommandEngine::finished(int status)
{
    if (!process)
    {
        return;
    }
    emit output(process->readAllStandardOutput());
    QString errors = process->readAllStandardError();
    if (status || errors != "")
    {
        emit error(errors);
    }
}
