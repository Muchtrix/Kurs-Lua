CXX = g++
CXXFLAGS = -Wall -O2 $(shell pkg-config --cflags lua5.3) 
LDLIBS = $(shell pkg-config --libs lua5.3)

all: stackDump

stackDump: stackDump.cpp

clean:
	rm -f stackDump