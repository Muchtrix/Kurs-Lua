CXX = g++
# CXXFLAGS = -O2 $(shell pkg-config --cflags lua5.3) 
# LDLIBS = $(shell pkg-config --libs lua5.3) -lreadline
LUA_PATH = ~/Documents/lua-5.3.4/src
LDLIBS = -L $(LUA_PATH) -lreadline -llua
CXXFLAGS = -O2 -I $(LUA_PATH)

all: repl

repl: repl.cpp

clean:
	rm -f repl