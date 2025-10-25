#include <stdio.h>
#include "parser.h"

int main(void)
{
    char line[64];
    printf("IMU Parser Ready. Type commands:\n");

    while (fgets(line, sizeof(line), stdin))
    {
        parseCommand(line);
    }

    return 0;
}