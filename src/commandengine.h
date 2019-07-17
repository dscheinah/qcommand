#ifndef COMMANDENGINE_H
#define COMMANDENGINE_H

#include <QObject>
#include <QString>

class CommandEngine : public QObject
{
    Q_OBJECT
public:
    explicit CommandEngine(QObject *parent = 0);

signals:
    void output(QString data);

public slots:
    void exec(QString cmd);
};

#endif // COMMANDENGINE_H
