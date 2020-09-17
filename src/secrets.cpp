#include "secrets.h"

#include <Sailfish/Secrets/createcollectionrequest.h>
#include <Sailfish/Secrets/deletesecretrequest.h>
#include <Sailfish/Secrets/storesecretrequest.h>
#include <Sailfish/Secrets/storedsecretrequest.h>
#include <Sailfish/Secrets/result.h>

Secrets::Secrets(QObject *parent) : QObject(parent)
{
    identifier = Sailfish::Secrets::Secret::Identifier(
        QStringLiteral("RootPassword"),
        QStringLiteral("qCommand"),
        Sailfish::Secrets::SecretManager::DefaultEncryptedStoragePluginName
    );
}

QString Secrets::read()
{
    Sailfish::Secrets::StoredSecretRequest request;
    request.setManager(&manager);
    request.setUserInteractionMode(Sailfish::Secrets::SecretManager::SystemInteraction);
    request.setIdentifier(identifier);
    request.startRequest();
    request.waitForFinished();
    if (request.result().code() == Sailfish::Secrets::Result::Succeeded) {
       return request.secret().data();
    }
    return "";
}

bool Secrets::store(QString password)
{
    Sailfish::Secrets::Secret secret(identifier);
    secret.setData(password.toUtf8());

    Sailfish::Secrets::CreateCollectionRequest createCollection;
    createCollection.setManager(&manager);
    createCollection.setCollectionLockType(Sailfish::Secrets::CreateCollectionRequest::DeviceLock);
    createCollection.setDeviceLockUnlockSemantic(Sailfish::Secrets::SecretManager::DeviceLockRelock);
    createCollection.setAccessControlMode(Sailfish::Secrets::SecretManager::OwnerOnlyMode);
    createCollection.setUserInteractionMode(Sailfish::Secrets::SecretManager::SystemInteraction);
    createCollection.setCollectionName(identifier.collectionName());
    createCollection.setStoragePluginName(identifier.storagePluginName());
    createCollection.setEncryptionPluginName(identifier.storagePluginName());
    createCollection.startRequest();
    createCollection.waitForFinished();

    Sailfish::Secrets::Result result = createCollection.result();
    if (result.code() != Sailfish::Secrets::Result::Succeeded && result.errorCode() != Sailfish::Secrets::Result::CollectionAlreadyExistsError) {
        return false;
    }

    Sailfish::Secrets::DeleteSecretRequest purge;
    purge.setManager(&manager);
    purge.setUserInteractionMode(Sailfish::Secrets::SecretManager::ApplicationInteraction);
    purge.setIdentifier(identifier);
    purge.startRequest();
    purge.waitForFinished();

    Sailfish::Secrets::StoreSecretRequest request;
    request.setManager(&manager);
    request.setSecretStorageType(Sailfish::Secrets::StoreSecretRequest::CollectionSecret);
    request.setUserInteractionMode(Sailfish::Secrets::SecretManager::SystemInteraction);
    request.setSecret(secret);
    request.startRequest();
    request.waitForFinished();

    return request.result().code() == Sailfish::Secrets::Result::Succeeded;
}
