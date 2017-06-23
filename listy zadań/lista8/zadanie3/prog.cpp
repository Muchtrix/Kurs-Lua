#include <lua.hpp>
#include <iostream>
#include <string>
#include <cstdlib>

using namespace std;

void error (lua_State *L, const char *fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    lua_close(L);
    exit(1);
}

bool prfx(string name){
    string prefix = "level_";
    if(name.length() > prefix.length()){
        return mismatch(prefix.begin(), prefix.end(), name.begin()).first == prefix.end();
    } else return mismatch(name.begin(), name.end(), prefix.begin()).first == name.end();
}

bool jestPlansza(lua_State *L, string nazwa){
    lua_getglobal(L, nazwa.c_str());
    if(lua_type(L, -1) != LUA_TTABLE) {
        lua_pop(L, 1);
        return false;
    }
    lua_len(L, -1);
    int wiersze = (int) lua_tointeger(L, -1);
    lua_pop(L, 1);
    for(int i = 1; i <=wiersze; ++i){
        lua_pushnumber(L, i);
        if(lua_gettable(L, -2) != LUA_TTABLE) {
            lua_pop(L, 2);
            return false;
        }
        lua_pop(L, 1);
    }
    lua_pop(L, 1);
    return true;
}

void rysujPlansze(lua_State *L, string nazwa){
    lua_getglobal(L, nazwa.c_str());
    if(lua_type(L, -1) == LUA_TNIL){
        cout << "Zmienna " << nazwa << " nie istnieje!" << endl;
        lua_pop(L, 1);
        return;
    }
    if (! jestPlansza(L, nazwa)){
        cout << nazwa << " nie jest planszą!" << endl;
        lua_pop(L, 1);
        return;
    }
    lua_len(L, -1);
    int wiersze = (int) lua_tointeger(L, -1);
    lua_pop(L, 1);
    for(int i = 1; i <= wiersze; ++i){
        lua_pushnumber(L, i);
        lua_gettable(L, -2);
        lua_len(L, -1);
        int kolumny = (int) lua_tointeger(L, -1);
        lua_pop(L, 1);

        for(int j = 1; j <= kolumny; ++j){
            lua_pushnumber(L, j);
            lua_gettable(L, -2);
            cout << lua_tostring(L, -1);
            lua_pop(L, 1);
        }
        cout << endl;
        lua_pop(L, 1);
    }
    lua_pop(L, 1);
    cout << endl;
}

void rysujWszystkie(lua_State *L){
    lua_getglobal(L, "_G");
    lua_pushnil(L);
    while(lua_next(L, -2) != 0){
        lua_pop(L,1);
        if(lua_type(L, -1) == LUA_TSTRING){
            string nazwa = lua_tostring(L, -1);
            if (prfx(nazwa)){
                cout << nazwa << ":\n";
                rysujPlansze(L, nazwa);
            }
        }
    }
    lua_pop(L, 1);
}

int main(){
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    if (luaL_loadfile(L, "plansze.lua")  || lua_pcall(L, 0, 0, 0))
        error(L, "Błąd przy otwieraniu pliku: %s\n", lua_tostring(L, -1));

    while(true){
        string nazwa_planszy;
        cout << "> ";
        cin >> nazwa_planszy;
        if(nazwa_planszy == "*ALL") rysujWszystkie(L);
        else rysujPlansze(L, "level_" + nazwa_planszy);
    }
    return 0;
}