CXX = g++
CXXFLAGS = -O2 $(shell pkg-config --cflags lua5.3) 
LDLIBS = $(shell pkg-config --libs lua5.3) -lreadline

all: repl

repl: repl.cpp

clean:
	rm -f repl