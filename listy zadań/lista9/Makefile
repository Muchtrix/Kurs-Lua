CXX = g++
CXXFLAGS = -Wall -O2 $(shell pkg-config --cflags lua5.3) -fPIC
LDLIBS = $(shell pkg-config --libs lua5.3)
RM = rm -v -f

all: zadanie1.so

zadanie1.so: zadanie1.cpp
	$(CXX) $(CXXFLAGS) $^ $(LDLIBS) -shared -o zadanie1.so

clean:
	@$(RM) zadanie1.so 
	@$(RM) *~
