#ifndef DEVELOPER_H
#define DEVELOPER_H

#include <QValidator>
#include <QProcess>
#include <QMimeDatabase>

class Developer : public QValidator
{
    Q_OBJECT
    Q_PROPERTY(bool develSuAvailable READ develSuAvailable CONSTANT)
    Q_PROPERTY(bool fingertermAvailable READ fingertermAvailable CONSTANT)
private:
    QMap<QString, QProcess*>* validations;
    QMap<QString, bool> readyToOpen;
    QMimeDatabase mimeDb;

public:
    explicit Developer(QObject *parent = nullptr);
    virtual State validate(QString& input, int& pos) const;
    bool develSuAvailable();
    bool fingertermAvailable();
    Q_INVOKABLE void open(QString file);
    Q_INVOKABLE QString getFileToOpen(QString line);
    Q_INVOKABLE bool fileExists(QString file);
    Q_INVOKABLE void deleteFile(QString file);

private:
    QString replaceAndGetFile(QString line, QList<QRegExp> expressions);

public slots:
    void validated();
};

#endif // DEVELOPER_H
