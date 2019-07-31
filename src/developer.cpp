#include "developer.h"
#include <QFile>

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


bool Developer::isReadyToOpen(QString file)
{
    QMimeType mime = mimeDb.mimeTypeForFile(file);
    QString type = mime.name();
    if (readyToOpen.contains(type))
    {
        return readyToOpen.value(type);
    }
    QProcess* process = new QProcess();
    QStringList args;
    args << "query" << "default" << type;
    process->start("xdg-mime", args);
    process->waitForFinished();
    if (process->readAllStandardOutput() != "")
    {
        readyToOpen.insert(type, true);
        return true;
    }
    readyToOpen.insert(type, false);
    return false;
}

void Developer::open(QString file)
{
    if (!isReadyToOpen(file))
    {
        return;
    }
    QProcess* process = new QProcess();
    QStringList args;
    args << file;
    process->start("xdg-open", args);
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
