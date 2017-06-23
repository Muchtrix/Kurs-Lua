CXX = g++
CXXFLAGS = -O2 $(shell pkg-config --cflags lua5.3) 
LDLIBS = $(shell pkg-config --libs lua5.3)

all: prog

stackDump: prog.cpp

clean:
	rm -f prog