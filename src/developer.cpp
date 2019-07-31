#include "developer.h"
#include <QFile>
#include <QDir>

Developer::Developer(QObject *parent) : QValidator(parent)
{
    validations = new QMap<QString, QProcess*>();
}

bool Developer::develSuAvailable()
{
    return QFile::exists("/usr/bin/devel-su");
}

bool Developer::fingertermAvailable()
{
    return QFile::exists("/usr/bin/fingerterm");
}


QString Developer::getFileToOpen(QString line)
{
    QString file = line[0] == '/' ? line : "/" + line;
    if (!QFile(file).exists())
    {
        QList<QRegExp> expressions;
        expressions << QRegExp("^\\S+\\s+") << QRegExp("\\s+\\S+$");
        return replaceAndGetFile(line, expressions);
    }
    if (QDir(file).exists())
    {
        return "";
    }

    QMimeType mime = mimeDb.mimeTypeForFile(file);
    QString type = mime.name();

    if (readyToOpen.contains(type) && readyToOpen.value(type))
    {
        return file;
    }

    QProcess* process = new QProcess();
    QStringList args;
    args << "query" << "default" << type;
    process->start("xdg-mime", args);
    process->waitForFinished();
    QString output = process->readAllStandardOutput();
    delete process;

    if (output != "")
    {
        readyToOpen.insert(type, true);
        return file;
    }
    readyToOpen.insert(type, false);
    return "";
}

QString Developer::replaceAndGetFile(QString line, QList<QRegExp> expressions)
{
    QString reduced;
    QString file;
    for (QRegExp exp: expressions)
    {
        reduced = line;
        reduced.replace(exp, "");
        if (line != reduced)
        {
            file = getFileToOpen(reduced);
            if (file != "")
            {
                return file;
            }
        }
    }
    return "";
}

void Developer::open(QString file)
{
    if (getFileToOpen(file) == "")
    {
        return;
    }
    QProcess* process = new QProcess();
    QStringList args;
    args << file;
    process->start("xdg-open", args);
    process->waitForFinished();
    delete process;
}

QValidator::State Developer::validate(QString& input, int& pos) const
{
    Q_UNUSED(pos)
    if (input == "")
    {
        return Intermediate;
    }
    QProcess* process;
    if (validations->contains(input))
    {
        process = validations->value(input);
        if (process->state() == QProcess::ProcessState::NotRunning)
        {
            return process->exitCode() ? Intermediate : Acceptable;
        }
    }
    else
    {
        process = new QProcess();
        validations->insert(input, process);

        QObject::connect(process, SIGNAL(finished(int)), this, SLOT(validated()));
        process->start("devel-su");
        process->write((input + "\n").toUtf8().data());
        process->write("exit\n");
    }
    return Intermediate;
}

void Developer::validated()
{
    emit changed();
}
