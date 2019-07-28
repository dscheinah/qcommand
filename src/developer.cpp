#include "developer.h"
#include <QFile>
#include <QStandardPaths>

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
