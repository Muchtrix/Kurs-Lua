//-----------------------------------------------------------------------------
// Wiktor Adamski
// Kurs Lua - Lista 9
//-----------------------------------------------------------------------------
#include <lua.hpp>

static int summation (lua_State *L) {
    double res = 0;
    for(int i = 1; i <= lua_gettop(L); ++i) {
        res += (double) luaL_checknumber(L, i);
    }
    lua_settop(L, 0);
    lua_pushnumber(L, res);
    return 1;
}

static int reduce(lua_State *L) {
    int pozycja = 1;
    lua_len(L, 2);
    int rozmiar = (int) lua_tointeger(L, -1);
    lua_pop(L, 1);
    if (lua_gettop(L) == 2) {
        lua_pushnumber(L, pozycja++);
        lua_gettable(L, -2);
    }
    for(; pozycja <= rozmiar; ++pozycja){
        lua_pushvalue(L, 1);
        lua_insert(L, -2);
        lua_pushnumber(L, pozycja);
        lua_gettable(L, 2);
        lua_call(L, 2, 1);
    }
    return 1;
}

static int merge(lua_State *L) {
    int liczba_tablic = lua_gettop(L);
    for(int akt_tab = 2; akt_tab <= liczba_tablic; ++akt_tab){
        lua_pushnil(L);
        while(lua_next(L, akt_tab) != 0){
            lua_pushvalue(L, -2);
            lua_pushvalue(L, -2);
            lua_pushvalue(L, -2);
            lua_gettable(L, 1);
            if(lua_type(L, -1) == LUA_TNIL) {
                lua_pop(L, 1);
                lua_settable(L, 1);
            } else lua_pop(L, 1);
            lua_pop(L, 1);
        }
    }
    lua_settop(L, 1);
    return 1;
}

static int splitAt(lua_State *L) {
    int podzialy = lua_gettop(L);
    int rezultaty = 0;
    lua_len(L, 1);
    int rozmiar = (int) lua_tointeger(L, -1);
    lua_pop(L, 1);
    int aktualny_indeks = 1;
    for(int i = 2; i <=podzialy && aktualny_indeks <= rozmiar; ++i){
        int akt_podzial = (int) luaL_checkinteger(L, i);
        ++rezultaty;
        lua_createtable(L, akt_podzial, 0);
        for(int j = 1; j <= akt_podzial && aktualny_indeks <= rozmiar; ++j){
            lua_pushnumber(L, j);
            lua_pushnumber(L, aktualny_indeks++);
            lua_gettable(L, 1);
            lua_settable(L, -3);
        }
    }
    if (aktualny_indeks <= rozmiar){
        ++rezultaty;
        lua_createtable(L, rozmiar - aktualny_indeks + 1, 0);
        for(int j = 1; aktualny_indeks <= rozmiar; ++j){
            lua_pushnumber(L, j);
            lua_pushnumber(L, aktualny_indeks++);
            lua_gettable(L, 1);
            lua_settable(L, -3);
        }
    }
    return rezultaty;
}

static const struct luaL_Reg mylib [] = {
    {"summation", summation},
    {"reduce", reduce},
    {"merge", merge},
    {"splitAt", splitAt},
    {NULL, NULL}  // sentinel
};

extern "C" int luaopen_zadanie1(lua_State *L) { // wystawienie na zewnątrz (z extern C)
    luaL_newlib(L, mylib);
    return 1;
}