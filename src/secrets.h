#ifndef SECRETS_H
#define SECRETS_H

#include <QObject>
#include <QString>
#include <QByteArray>

#include <Sailfish/Secrets/secretmanager.h>
#include <Sailfish/Secrets/secret.h>

class Secrets : public QObject
{
    Q_OBJECT
public:
    explicit Secrets(QObject *parent = nullptr);
    Q_INVOKABLE QString read();
    Q_INVOKABLE bool store(QString password);

private:
    Sailfish::Secrets::SecretManager manager;
    Sailfish::Secrets::Secret::Identifier identifier;
};

#endif // SECRETS_H
