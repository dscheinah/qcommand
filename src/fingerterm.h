#ifndef FINGERTERM_H
#define FINGERTERM_H

#include "commandengine.h"

class Fingerterm : public CommandEngine
{
    Q_OBJECT
public:
    explicit Fingerterm();

protected:
    void create(bool emitOutput);

public slots:
    void execInteractive(QString cmd);
    void execAsRootInteractive(QString cmd);
};

#endif // FINGERTERM_H
