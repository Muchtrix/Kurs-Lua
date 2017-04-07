--[[
    Wiktor Adamski
    Kurs Lua, lista 2
--]]

-- Zadanie 1 -> Zrobione na Codingame

-- Zadanie 2

-- Zadanie 3

-- Zadanie 4

KALENDARZ = {}

function dzienTygodnia(dzien, miesiac, rok)
    local miesiace = {6, 2, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4}
    local dni = {[0] = 'niedziela', 'poniedziałek', 'wtorek', 'środa', 'czwartek', 'piątek', 'sobota'}
    local res = dzien + miesiace[miesiac] + ((rok % 100) % 12) + 2
    if rok % 4 == 0 and miesiac <= 2 then res = res - 1 end
    return dni[res % 7]
end

function stringWydarzenie(wydarzenie)
    return string.format('%02d:%02d - %02d:%02d  %s', 
        wydarzenie.poczatek // 60, wydarzenie.poczatek % 60,
        wydarzenie.koniec // 60,wydarzenie.koniec % 60, wydarzenie.opis)
end

function dodajWydarzenie(dzien, miesiac, rok, opis, poczatekH, poczatekM, koniecH, koniecM)
    local hash = dzien..'.'..miesiac..'.'..rok
    local poczatek = poczatekH * 60 + poczatekM
    local koniec = koniecH * 60 + koniecM
    if(KALENDARZ[hash] == nil) then
        KALENDARZ[hash] = {wydarzenia={}, dzienTygodnia=dzienTygodnia(dzien, miesiac, rok)}
    end
    local wydarzenia = KALENDARZ[hash].wydarzenia
    for _, v in ipairs(wydarzenia) do
        if (v.poczatek <= poczatek and poczatek <= v.koniec) or (v.poczatek <= koniec and koniec <= v.koniec) then
            return false, 'Kolizja na wydarzeniu: '.. stringWydarzenie(v)
        end
    end
    wydarzenia[# wydarzenia + 1] = {opis = opis, poczatek = poczatek, koniec = koniec}
    return true
end

function wypiszDzien(dzien, miesiac, rok)
    local kalDzien = KALENDARZ[dzien..'.'..miesiac..'.'..rok]
    local miesiace = {'stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca', 'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia'}
    if kalDzien == nil then return false end
    print(string.format('%s, %2d %s %4d', kalDzien.dzienTygodnia, dzien, miesiace[miesiac], rok))
    print 'Lp.  Pocz.   Kon.   Opis'
    for i, v in ipairs(kalDzien.wydarzenia) do
        print (i .. ': ' .. stringWydarzenie(v))
    end
    return true
end

res, err = dodajWydarzenie(9, 3, 2017, 'Ćwiczenia JFiZO', 14, 15, 16, 15)
if(res == false) then print (err) end
res, err = dodajWydarzenie(9, 3, 2017, 'Kolidująca randka z żuczkiem, osą i topolami', 15, 15, 17, 15)
if(res == false) then print (err) end
res, err = dodajWydarzenie(9, 3, 2017, 'Repeta JFiZO', 8, 15, 10, 15)
if(res == false) then print (err) end
wypiszDzien(9, 3, 2017)