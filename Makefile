# Ichim Dan Gabriel 331CC
build:
	flex main.l
	gcc lex.yy.c -lfl
clean:
	rm a.out
	rm lex.yy.c
run:
	./a.out test0.go
