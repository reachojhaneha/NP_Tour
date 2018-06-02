CC = gcc

FLAGS = -g 

CFLAGS = ${FLAGS} -I/home/courses/cse533/Stevens/unpv13e_linux/lib

LIBUNP_NAME = /home/courses/cse533/Stevens/unpv13e_linux/libunp.a

LIBS = ${LIBUNP_NAME} -lpthread

all: nojha_arp nojha_tour
 	
nojha_arp: arp.o get_hw_addrs.o
	${CC} ${FLAGS} -o nojha_arp arp.o get_hw_addrs.o ${LIBS}

arp.o: arp.c
	${CC} ${CFLAGS} -c arp.c

# ping: ping.o get_hw_addrs.o
	# ${CC} ${FLAGS} -o ping ping.o get_hw_addrs.o ${LIBS}
	
# ping.o: ping.c
	# ${CC} ${CFLAGS} -c ping.c

nojha_tour: tour.o get_hw_addrs.o
	${CC} ${FLAGS} -o nojha_tour tour.o get_hw_addrs.o ${LIBS}
tour.o: tour.c
	${CC} ${CFLAGS} -c tour.c	
	
get_hw_addrs.o: get_hw_addrs.c
	${CC} ${CFLAGS} -c get_hw_addrs.c

clean:
	rm nojha_arp nojha_tour *.o

	
