test_algos:test_algos.o list_algos.o list.o
	gcc test_algos.o list_algos.o list.o -o test_algos

test_algos.o:test_algos.c list_algos.h
	gcc -c -g $< 
list_algos.o:list_algos.c list_algos.h
	gcc -c -g $< 
list.o:list.c LinkList.h
	gcc -c -g $< 

.PHONY: clean
clean :
	-rm *_algos.o test_algos 
