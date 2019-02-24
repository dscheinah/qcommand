#include "commandengine.h"

CommandEngine::CommandEngine(QObject *parent) : QObject(parent)
{

}

void CommandEngine::exec(QString cmd)
{
    char buffer[128];
    std::string result = "";
    FILE* pipe = popen(cmd.toUtf8().data(), "r");
    if (!pipe)
    {
        throw std::runtime_error("popen failed");
    }
    try
    {
        while (!feof(pipe))
        {
            if (fgets(buffer, 128, pipe) != NULL)
            {
                result += buffer;
            }
        }
    } catch (...)
    {
        pclose(pipe);
        throw;
    }
    pclose(pipe);
}

