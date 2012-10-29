file_server: protocol.o
	gcc protocol.o main.c -o file_server

protocol.o:
	gcc -c protocol.c -o protocol.o

clean:
	rm *.o
	rm file_server
