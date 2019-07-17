#include "commandengine.h"
#include <iostream>
#include <stdexcept>

CommandEngine::CommandEngine(QObject *parent) : QObject(parent)
{

}

void CommandEngine::exec(QString cmd)
{
    QString result = "";
    FILE* pipe = popen(cmd.toUtf8().data(), "r");
    if (!pipe)
    {
        throw std::runtime_error("popen failed");
    }
    char buffer[128];
    try
    {
        while (!feof(pipe))
        {
            if (fgets(buffer, 128, pipe) != NULL)
            {
                result += buffer;
            }
        }
    }
    catch (...)
    {
        pclose(pipe);
        throw;
    }
    if (result != "")
    {
        emit output(result);
    }
    pclose(pipe);
}

