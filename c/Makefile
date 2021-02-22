#
# Makefile
#
# Paul Reiners
#

# name for executable
EXE = model_tsvd

# default target
$(EXE): model_tsvd.o
	gcc -Wall -I/home/miran045/reine097/c-libs/include/ -c model_tsvd.o

model_tsvd.o : model_tsvd.c
	gcc -std=c99 -L/home/miran045/reine097/c-libs/lib model_tsvd.c -lgsl -lgslcblas -lm

# housekeeping
clean:
	rm -f core $(EXE) *.o
