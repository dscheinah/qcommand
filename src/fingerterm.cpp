#include "fingerterm.h"

Fingerterm::Fingerterm() : CommandEngine()
{
}

void Fingerterm::execInteractive(QString cmd)
{
    create(false);
    QStringList args;
    args << "-e" << "chmod +x " + cmd + " && " + cmd + "\nwhile read; do :; done; exit";
    process->start("fingerterm", args, QProcess::ReadOnly);
    process->closeWriteChannel();
    process->closeReadChannel(QProcess::ProcessChannel::StandardOutput);
    process->closeReadChannel(QProcess::ProcessChannel::StandardError);
}

void Fingerterm::execAsRootInteractive(QString cmd)
{
    create(false);
    QStringList args;
    args << "-e" << "chmod +x " + cmd + " && devel-su bash -c \"" + cmd + "\nwhile read; do :; done; exit\"";
    process->start("fingerterm", args, QProcess::ReadOnly);
    process->closeWriteChannel();
    process->closeReadChannel(QProcess::ProcessChannel::StandardOutput);
    process->closeReadChannel(QProcess::ProcessChannel::StandardError);
}

void Fingerterm::create(bool emitOutput)
{
    CommandEngine::create(emitOutput);
    process->disconnect();
}
