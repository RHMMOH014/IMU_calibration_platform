#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.h"
#include "handlers.h"

#define CMD_BUFFER_SIZE 64

static void dispatchCommand(const char *cmd, char *args[]);

void parseCommand(const char *cmdString)
{
    char buffer[CMD_BUFFER_SIZE];
    strncpy(buffer, cmdString, CMD_BUFFER_SIZE - 1);
    buffer[CMD_BUFFER_SIZE - 1] = '\0';


    size_t len = strlen(buffer);
    while (len > 0 && (buffer[len - 1] == '\r' || buffer[len - 1] == '\n')) {
        buffer[--len] = '\0';
}


    char *tokens[4] = {0};
    int count = 0;
    char *token = strtok(buffer, " ");
    while (token && count < 4)
    {
        tokens[count++] = token;
        token = strtok(NULL, " ");
    }

    if (count == 0)
        return;

    char *command = tokens[0];
    char *args[3] = {tokens[1], tokens[2], tokens[3]};

    dispatchCommand(command, args);
}

static void dispatchCommand(const char *command, char *args[])
{
    if (strcmp(command, "$START") == 0)
        handleStart();
    else if (strcmp(command, "$STOP") == 0)
        handleStop();
    else if (strcmp(command, "$PAUSE") == 0)
        handlePause();
    else if (strcmp(command, "$RESUME") == 0)
        handleResume();
    else if (strcmp(command, "$PING") == 0)
        handlePing();
    else if (strcmp(command, "$ECHO") == 0 && args[0])
        handleEcho(args[0]);
    else if (strcmp(command, "$RATE") == 0)
    {
        if (args[0] && strcmp(args[0], "?") == 0)
            handleQueryRate();
        else if (args[0])
            handleSetRate(atof(args[0]));
    }
    else if (strcmp(command, "$RESET") == 0)
        handleReset();
    else if (strcmp(command, "$ABORT") == 0)
        handleAbort();
    else if (strcmp(command, "$YAWPOS") == 0)
    {
        if (args[0] && strcmp(args[0], "?") == 0)
            handleQueryYaw();
        else if (args[0])
            handleSetYaw(atof(args[0]));
    }
    else if (strcmp(command, "$PITCHPOS") == 0)
    {
        if (args[0] && strcmp(args[0], "?") == 0)
            handleQueryPitch();
        else if (args[0])
            handleSetPitch(atof(args[0]));
    }
    else if (strcmp(command, "$LGFF") == 0)
        handleQueryLGFF();
    else
        printf("[PARSER] Unknown command: %s\n", command);
}