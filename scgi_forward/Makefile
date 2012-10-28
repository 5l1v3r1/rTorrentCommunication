scgi_forward: scgi.o client_protocol.o http_response.o test
	gcc main.c scgi.o client_protocol.o http_response.o -o scgi_forward

test: scgi.o
	gcc test.c scgi.o -o test

scgi.o:
	gcc -c scgi.c -o scgi.o

client_protocol.o: KBCKit/KBCKit.o
	gcc -c client_protocol.c -o client_protocol_dep.o
	ld -r client_protocol_dep.o KBCKit/KBCKit.o -o client_protocol.o
	rm client_protocol_dep.o

http_response.o:
	gcc -c http_response.c -o http_response.o

KBCKit/KBCKit.o:
	cd KBCKit; make

clean:
	rm *.o
	rm test
	rm scgi_forward
	cd KBCKit; make clean
