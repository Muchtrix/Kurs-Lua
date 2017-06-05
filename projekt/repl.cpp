#include <stdio.h>
#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <lua.hpp>

bool isCompileMode(lua_State *L){
    lua_getglobal(L, "m");
    lua_pushstring(L, "compileMode");
    lua_gettable(L, -2);
    bool res = lua_toboolean(L, -1);
    lua_pop(L, 2);
    return res;
}

int main(){
    lua_State *L;
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_dofile(L, "main.lua");
    while(true){
        char * linijka = readline(isCompileMode(L) ? "C> " : "I> ");
        lua_getglobal(L, "execLine");
        lua_pushstring(L, linijka);
        lua_call(L, 1, 0);
    }
    return 0;
}