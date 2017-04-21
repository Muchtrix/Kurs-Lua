#include <iostream>
#include <cstdlib>
#include <lua.hpp>

using namespace std;

void error (lua_State *L, const char *fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    lua_close(L);
    exit(1);
}

// zwracamy wartość typu int zapisaną w globalnej zmiennej varname
int getglobalint (lua_State *L, const char *varname) {
    int isnum, result;
    
    lua_getglobal(L, varname); // wstawiamy zmienną globalną varname na stos
    result = (int)lua_tointegerx(L, -1, &isnum); // odczytujemy ze stosu jej wartość
    
    if (!isnum) // sprawdzamy czy się poprawnie wczytała
        error(L, "'%s' should be an integer\n", varname);
        
    lua_pop(L, 1); // usuwamy wczytaną wartość ze stosu
    return result;
}

// zwracamy wartość typu double zapisaną w globalnej zmiennej varname
double getglobaldouble (lua_State *L, const char *varname) {
    int isnum;
    double result;
    
    lua_getglobal(L, varname); // wstawiamy zmienną globalną varname na stos
    result = (double)lua_tonumberx(L, -1, &isnum); // odczytujemy ze stosu jej wartość
    
    if (!isnum) // sprawdzamy czy się poprawnie wczytała
        error(L, "'%s' should be a double\n", varname);
        
    lua_pop(L, 1); // usuwamy wczytaną wartość ze stosu
    return result;
}

// zwracamy wartość typu bool zapisaną w globalnej zmiennej varname
bool getglobalbool (lua_State *L, const char *varname) {
    bool result;

    lua_getglobal(L, varname); // wstawiamy zmienną globalną varname na stos
    result = (bool) lua_toboolean(L, -1); // odczytujemy ze stosu jej wartość

    lua_pop(L, 1); // usuwamy wczytaną wartość ze stosu
    return result;
}

// zwracamy wartość typu string zapisaną w globalnej zmiennej varname
const char * getglobalstring (lua_State *L, const char *varname) {
    const char* result;

    lua_getglobal(L, varname); // wstawiamy zmienną globalną varname na stos
    result = lua_tostring(L, -1); // odczytujemy ze stosu jej wartość

    lua_pop(L, 1); // usuwamy wczytaną wartość ze stosu
    return result;
}

int main(){
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    int width = 400, height;
    double ratio;

    lua_pushnumber(L, width);
    lua_setglobal(L, "width");
    if (luaL_loadfile(L, "config.lua")  || lua_pcall(L, 0, 0, 0))
        error(L, "cannot load config file: %s\n", lua_tostring(L, -1));

    ratio = getglobaldouble(L, "height_to_width");
    height = getglobalint(L, "height");

    bool high_window = getglobalbool(L, "high_window");

    lua_pushstring(L, "NA NA NA NA NA NA NA NA BATMAN");
    lua_setglobal(L, "Batman");

    const char * title = getglobalstring(L, "title");

    cout << title << '\n'
         << ratio << ' ' << height << ' ' << (high_window ? "true" : "false") << endl;

    if (luaL_loadfile(L, "batman.lua")  || lua_pcall(L, 0, 0, 0))
        error(L, "cannot load Batman file: %s\n", lua_tostring(L, -1));

    lua_close(L);
    return 0;
}