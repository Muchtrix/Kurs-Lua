#include <lua.hpp>
#include <cstdlib>
#include <iostream>
#include <string>

using namespace std;

string plansza[3][3];

void wypiszPlansze(){
    cout << plansza[0][0] << '|' << plansza[0][1] << '|' << plansza[0][2] << '\n';
    cout << "-+-+-\n";
    cout << plansza[1][0] << '|' << plansza[1][1] << '|' << plansza[1][2] << '\n';
    cout << "-+-+-\n";
    cout << plansza[2][0] << '|' << plansza[2][1] << '|' << plansza[2][2] << '\n';
    cout << endl;
}

int sprawdzWygrana(){
    string linie[8] = {
        plansza[0][0] + plansza[0][1] + plansza[0][2],
        plansza[1][0] + plansza[1][1] + plansza[1][2],
        plansza[2][0] + plansza[2][1] + plansza[2][2],
        plansza[0][0] + plansza[1][0] + plansza[2][0],
        plansza[0][1] + plansza[1][1] + plansza[2][1],
        plansza[0][2] + plansza[1][2] + plansza[2][2],
        plansza[0][0] + plansza[1][1] + plansza[2][2],
        plansza[2][0] + plansza[1][1] + plansza[0][2]
    };
    for(int i = 0; i < 8; ++i){
        if(linie[i] == "OOO") return 1;
        if(linie[i] == "XXX") return 2;
    }
    return 0;
}

void wrzucPlansze(lua_State *L){
    lua_createtable(L, 3, 0);
    for(int i = 0; i < 3; ++i){
        lua_pushnumber(L, i+1);
        lua_createtable(L, 3, 0);
        for(int j = 0; j < 3; ++j){
            lua_pushnumber(L, j + 1);
            lua_pushstring(L, plansza[i][j].c_str());
            lua_settable(L, -3);
        }
        lua_settable(L, -3);
    }
}

void error (lua_State *L, const char *fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    lua_close(L);
    exit(1);
}

int main(int argc, char** argv){
    bool szczegolowe_info = false;
    int liczba_rozgrywek = 5;
    int wygrane1 = 0, wygrane2 = 0;
    char* nazwa_pliku1, *nazwa_pliku2;
    lua_State *boty[2] = {
        luaL_newstate(), 
        luaL_newstate()
    };
    luaL_openlibs(boty[0]);
    luaL_openlibs(boty[1]);

    if(argc >= 3){
        nazwa_pliku1 = argv[1];
        nazwa_pliku2 = argv[2];
    } else {
        int a;
        cout << "Podaj nazwę pliku z pierwszym botem:" << endl;
        a = scanf("%s", nazwa_pliku1);
        cout << "Podaj nazwę pliku z drugim botem:" << endl;
        a= scanf("%s", nazwa_pliku2);
    }    
    if (luaL_loadfile(boty[0], nazwa_pliku1)  || lua_pcall(boty[0], 0, 0, 0))
        error(boty[0], "Błąd przy otwieraniu pliku: %s\n", lua_tostring(boty[0], -1));
    if (luaL_loadfile(boty[1], nazwa_pliku2)  || lua_pcall(boty[1], 0, 0, 0))
        error(boty[1], "Błąd przy otwieraniu pliku: %s\n", lua_tostring(boty[1], -1));
    
    if(argc >= 4) liczba_rozgrywek = atoi(argv[3]);
    szczegolowe_info = (argc < 5);

    for(int rozgrywka = 1; rozgrywka <= liczba_rozgrywek; ++rozgrywka){
        cout << "Rozgrywka nr " << rozgrywka << (szczegolowe_info? "\n" : ": ");
        for(int i = 0; i < 3; ++i) for(int j = 0; j < 3; ++j) plansza[i][j] = " ";
        for(int i = 0; i < 9; ++i){
            if (szczegolowe_info) cout << "Ruch gracza nr " << (i%2) + 1 << endl;
            lua_State *B = boty[i%2];
            lua_getglobal(B, "AI");
            lua_pushstring(B, i%2 ? "X": "O");
            wrzucPlansze(B);
            lua_call(B, 2, 2);
            int isnum1, isnum2;
            int x = (int)lua_tointegerx(B, -2, &isnum1), y = (int)lua_tointegerx(B, -1, &isnum2);
            if(!isnum1 || !isnum2)
                error(B, "Funkcja nie zwróciła 2 liczb całkowitych!");
            lua_pop(B, 2);
            
            if(1 > x || x > 3 || 1 > y || y > 3)
                error(B, "Zwrócono indeksy spoza tablicy");
            
            if(plansza[x-1][y-1] == " "){
                plansza[x-1][y-1] = i%2 ? "X" : "O";
            } else error(B, "Próba zapisania zajętego wcześniej pola");

            if (szczegolowe_info) wypiszPlansze();

            int zwyc = sprawdzWygrana();
            if(zwyc){
                cout << "Wygrywa gracz nr " << zwyc << endl;
                if (zwyc == 1) ++wygrane1; else ++wygrane2;
                break;
            } else if(i == 8) cout << "Remis!" << endl;
        }
    }

    cout << "Stosunek zwycięstw: " << wygrane1 << '/' << wygrane2 << " (" << ((int)(100.0 * wygrane1/liczba_rozgrywek))<< "% ogółu) Remisy: " << liczba_rozgrywek - (wygrane1 + wygrane2) << endl;
    lua_close(boty[0]);
    lua_close(boty[1]);
    return 0;
}