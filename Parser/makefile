CC = gcc
CFLAGS = -Wall -Wextra
OBJS = main.o parser.o handlers.o

imu_parser_test: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o imu_parser_test