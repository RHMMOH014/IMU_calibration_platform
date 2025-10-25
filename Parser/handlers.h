#ifndef HANDLERS_H
#define HANDLERS_H

void handleStart(void);
void handleStop(void);
void handlePause(void);
void handleResume(void);
void handlePing(void);
void handleEcho(const char *msg);
void handleSetRate(float hz);
void handleQueryRate(void);
void handleReset(void);
void handleAbort(void);
void handleSetYaw(float angle);
void handleQueryYaw(void);
void handleSetPitch(float angle);
void handleQueryPitch(void);
void handleQueryLGFF(void);

#endif