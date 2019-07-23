#include "completion.h"
#include <QDir>

#include <QDebug>

Completion::Completion(QObject *parent) : QObject(parent)
{
    process = nullptr;
}

void Completion::complete(QString command)
{
    if (process)
    {
        process->disconnect();
        process->kill();
    }

    QRegExp separator("[\\s\"'${}()#;&`,+:!@\\[\\]<>|=+%^\\\\]");
    QStringList parts = command.split(separator);
    if (!parts.isEmpty())
    {
        part = parts.last();
        if (part != "" && part[0] != '-')
        {
            process = new QProcess();
            QObject::connect(process, SIGNAL(finished(int)), this, SLOT(ready()));

            QStringList args;
            args << "-c" << "compgen -c " + part;
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

    QRegExp pattern("^.*/");
    pattern.indexIn(part);
    QString replace = pattern.cap(0);
    if (!QDir(replace).exists())
    {
        replace = "";
    }

    part = part.replace(replace, "");

    QString output = process->readAll();
    QStringList split = output.split("\n");

    QStringList collected;
    for (QString output: split)
    {
        if (output == "")
        {
            continue;
        }
        output += QDir(output).exists() ? "/" : " ";
        collected << output.replace(replace, "");
    }
    emit result(collected);
}
