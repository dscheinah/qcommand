#include "completion.h"
#include <QDir>
#include <QSet>

Completion::Completion(QObject *parent) : QObject(parent)
{
    process = nullptr;
}

void Completion::complete(QString command)
{
    if (process)
    {
        process->disconnect();
        QObject::connect(process, SIGNAL(finished(int)), this, SLOT(cleanup()));
        if (process->state() == QProcess::ProcessState::Running)
        {
            process->kill();
        }
        else
        {
            delete process;
        }
        process = nullptr;
    }
    QRegExp separator("[\\s\"'${}()#;&`,:!@\\[\\]<>|=%^\\\\]");
    QStringList parts = command.split(separator);
    if (!parts.isEmpty())
    {
        part = parts.last();
        if (part != "")
        {
            process = new QProcess();
            QObject::connect(process, SIGNAL(finished(int)), this, SLOT(ready()));

            QStringList args;
            args << "-c" << "compgen -bcdf -- '" + part + "' | head -n23";
            process->start("bash", args, QProcess::ReadOnly);
        }
    }
}

void Completion::ready()
{
    if (!process)
    {
        return;
    }

    QRegExp pattern("^.+/");
    pattern.indexIn(part);
    QString replace = pattern.cap(0);
    if (!QDir(replace).exists())
    {
        replace = "";
    }
    int replaceLength = replace.length();

    part = part.replace(0, replaceLength, "");

    QString output = process->readAll();
    QStringList split = output.split("\n").toSet().toList();

    QStringList collected;
    for (QString output: split)
    {
        if (output == "")
        {
            continue;
        }
        output += QDir(output).exists() ? "/" : " ";
        if (output.indexOf(replace) == 0)
        {
            output.replace(0, replaceLength, "");
        }
        collected << output;
    }
    emit result(collected);
}

void Completion::cleanup()
{
    delete QObject::sender();
}
