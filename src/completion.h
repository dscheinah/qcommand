#ifndef COMPLETION_H
#define COMPLETION_H

#include <QObject>
#include <QProcess>

class Completion : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString part MEMBER part)
private:
    QProcess* process;
    QString part;

public:
    explicit Completion(QObject *parent = nullptr);
    Q_INVOKABLE void complete(QString command);

signals:
    void result(QStringList list);

public slots:
    void ready();
    void cleanup();
};

#endif // COMPLETION_H
