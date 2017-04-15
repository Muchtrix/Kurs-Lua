// Wiktor Adamski
// Kurs Lua - Lista 7 zadanie 1

#include <iostream>
#include <lua.hpp>

using namespace std;

void stackDump(lua_State *L){
    int top = lua_gettop(L);
    cout << "------- Lua stack dump --------\n";
    for (int i = top; 1 <= i; --i){
        int typ = lua_type(L, i);
        cout << "index: "<< i << ", type: " << lua_typename(L, typ) << ", value: ";
        switch(typ){
            case LUA_TNIL:
                cout << " nil\n";
                break;
            case LUA_TSTRING:
                cout << lua_tostring(L, i) << '\n';
                break;
            case LUA_TBOOLEAN:
                cout << (lua_toboolean(L, i) ? "true" : "false") << '\n';
                break;
            case LUA_TNUMBER:
                cout << lua_tonumber(L, i) << '\n';
                break;
            case LUA_TTABLE:
                cout << "table " << lua_topointer(L, i) << '\n';
                break;
            case LUA_TFUNCTION:
                cout << "function " << lua_topointer(L, i) << '\n';
                break;
        }
    }
    cout << "---- End of Lua stack dump ----\n\n";
}

int main(){

    lua_State *L = luaL_newstate();
    
    lua_pushboolean(L, 1);
    lua_pushnumber(L, 10);
    lua_pushnil(L);
    lua_pushstring(L, "hello");
                          stackDump(L); // true 10 nil ’hello’ 
    lua_pushvalue(L, -4); stackDump(L); // true 10 nil ’hello’ true 
    lua_replace(L, 3);    stackDump(L); // true 10 true ’hello’ 
    lua_settop(L, 6);     stackDump(L); // true 10 true ’hello’ nil nil 
    lua_rotate(L, 3, 1);  stackDump(L); // true 10 nil true 'hello' nil 
    lua_remove(L, -3);    stackDump(L); // true 10 nil 'hello' nil 
    lua_settop(L, -5);    stackDump(L); // true 
    
    lua_close(L);

    return 0;
}