#include "commandengine.h"
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>

CommandEngine::CommandEngine(QObject *parent) : QObject(parent)
{
    int fd[2];
    if (pipe(fd) < 0)
    {
        throw;
    }
    main[0] = fd[1];
    child[0] = fd[0];
    for (int i = 1; i < 3; i++)
    {
        if (pipe(fd) < 0)
        {
            throw;
        }
        main[i] = fd[0];
        child[i] = fd[1];
        fcntl(main[i], F_SETFL, O_NONBLOCK);
    }
}

CommandEngine::~CommandEngine()
{
    for (int i = 0; i < 3; i++)
    {
        close(main[i]);
        close(child[i]);
    }
}

void CommandEngine::exec(QString cmd, bool emitOutput)
{
    int pid = run(cmd);
    if (!pid)
    {
        throw;
    }
    waitpid(pid, NULL, 0);

    QString result = "";
    char buffer[128] = "";
    while (read(main[1], &buffer, 128) > 0)
    {
        result += buffer;
    }
    if (emitOutput) {
        emit output(result);
    }
}

int CommandEngine::run(QString command)
{
    int pid = fork();
    if (pid > 0)
    {
        return pid;
    }
    if (pid < 0)
    {
        return 0;
    }
    close(0);
    dup2(child[1], 1);
    dup2(child[2], 2);
    execl("/bin/sh", "sh", "-c", command.toUtf8().data(), NULL);
    exit(errno);
}
