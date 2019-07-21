#ifndef DEVELSU_H
#define DEVELSU_H

#include <QValidator>
#include <QMap>
#include <QString>
#include <QProcess>

class DevelSu : public QValidator
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available CONSTANT)
private:
    QMap<QString, QProcess*>* validations;

public:
    explicit DevelSu(QValidator *parent = nullptr);
    virtual State validate(QString& input, int& pos) const;
    bool available();

public slots:
    void validated();
};

#endif // DEVELSU_H
