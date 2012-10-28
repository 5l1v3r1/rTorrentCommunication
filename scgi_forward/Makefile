scgi_forward: scgi.o client_protocol.o test
	gcc main.c scgi.o client_protocol.o -o scgi_forward
	rm *.o

test: scgi.o
	gcc test.c scgi.o -o test

scgi.o:
	gcc -c scgi.c -o scgi.o

client_protocol.o: KBCKit/KBCKit.o
	gcc -c client_protocol.c -o client_protocol.o

KBCKit/KBCKit.o:
	cd KBCKit; make

clean:
	rm test
