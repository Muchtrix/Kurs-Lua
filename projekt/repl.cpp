#include <stdio.h>
#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <fstream>
#include <iostream>
#include <lua.hpp>

using namespace std;

bool isCompileMode(lua_State *L){
    lua_getglobal(L, "m");
    lua_pushstring(L, "compileMode");
    lua_gettable(L, -2);
    bool res = lua_toboolean(L, -1);
    lua_pop(L, 2);
    return res;
}

int main(int argc, char** argv){
    lua_State *L;
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_dofile(L, "repl.lua");
    for(int i = 1; i < argc; ++i) {
        ifstream plik(argv[i]);
        string linijka;
        if (plik.is_open()) {
            while(getline(plik, linijka)){
                lua_getglobal(L, "execLine");
                lua_pushstring(L, linijka.c_str());
                lua_call(L, 1, 1);
                bool isOn = lua_toboolean(L, -1);
                lua_pop(L, 1);
                if (!isOn) {
                    plik.close();
                    return 0;
                }
            }

            plik.close();
        } else {
            cout << "File " << argv[i] << " could not be open." << endl ;
        }
    }
    while(true){
        char * linijka = readline(isCompileMode(L) ? "C> " : "I> ");
        lua_getglobal(L, "execLine");
        lua_pushstring(L, linijka);
        lua_call(L, 1, 1);
        add_history(linijka);
        bool isOn = lua_toboolean(L, -1);
        lua_pop(L, 1);
        if (!isOn) break;
    }
    return 0;
}