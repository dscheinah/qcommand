#ifndef COMMANDENGINE_H
#define COMMANDENGINE_H

#include <QObject>
#include <QString>
#include <iostream>
#include <stdexcept>
#include <stdio.h>
#include <string>

class CommandEngine : public QObject
{
    Q_OBJECT
public:
    explicit CommandEngine(QObject *parent = 0);

signals:

public slots:
    void exec(QString cmd);
};

#endif // COMMANDENGINE_H
