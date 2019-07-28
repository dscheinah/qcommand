#ifndef DEVELOPER_H
#define DEVELOPER_H

#include <QValidator>
#include <QMap>
#include <QString>
#include <QProcess>

class Developer : public QValidator
{
    Q_OBJECT
    Q_PROPERTY(bool develSuAvailable READ develSuAvailable CONSTANT)
    Q_PROPERTY(bool fingertermAvailable READ fingertermAvailable CONSTANT)
private:
    QMap<QString, QProcess*>* validations;

public:
    explicit Developer(QObject *parent = nullptr);
    virtual State validate(QString& input, int& pos) const;
    bool develSuAvailable();
    bool fingertermAvailable();

public slots:
    void validated();
};

#endif // DEVELOPER_H
