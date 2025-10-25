#include <stdio.h>
#include "handlers.h"

static int streaming = 0;
static int paused = 0;
static float telemetryRate = 100.0f;
static float yaw = 0.0f;
static float pitch = 0.0f;
static float lgff[2] = {0.0f, 0.0f};

void handleStart(void){
streaming = 1; 
paused = 0; 
printf("EVT Streaming\n"); 
}

void handleStop(void){
streaming = 0; 
printf("EVT Stopped\n"); 
}

void handlePause(void){
paused = 1; 
printf("EVT Paused\n"); 
}

void handleResume(void){
paused = 0; 
printf("EVT Resumed\n");
}

void handlePing(void){ 
printf("PONG\n");
}

void handleEcho(const char *msg){
printf("%s\n", msg);
}

void handleSetRate(float hz){
telemetryRate = hz; 
printf("EVT Rate\n"); 
}

void handleQueryRate(void){
printf("rate=%.2f\n", telemetryRate);
}

void handleReset(void){
streaming = 0;
paused = 0;
yaw = 0; 
pitch = 0; 
printf("EVT Reset\n");
}

void handleAbort(void){
printf("EVT Fault\n"); 
}

void handleSetYaw(float a){
yaw = a; 
printf("EVT Yaw\n"); 
}

void handleQueryYaw(void){
printf("yaw=%.2f\n", yaw);
}

void handleSetPitch(float a){
pitch = a; 
printf("EVT Pitch\n");
}

void handleQueryPitch(void){ 
printf("pitch=%.2f\n", pitch);
}

void handleQueryLGFF(void){
printf("[%.2f,%.2f]\n", lgff[0], lgff[1]);
}