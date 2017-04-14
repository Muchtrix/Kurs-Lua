--[[
    Wiktor Adamski
    Kurs Lua, lista 6 - zadanie 2
--]]
Vector = require 'lista6.zadanie3.Vector'

tests = {
    [[Vector{1,2,3}                     ]], -- tworzenie wektora
    [[Vector{1,2,3} + Vector{2,3,4}     ]], -- sumowanie wektorów
    [[Vector{1,2,3} * 5                 ]], -- mnożenie przez skalar
    [[Vector{1,2,3} * Vector{2,2,-1}    ]], -- iloczyn wektorowy
    [[#Vector{3,4}                      ]], -- norma wektora
    [[2 * Vector{2,3} == Vector{2,3} * 2]], -- równość wektorów
    [[Vector{8,4} / 2                   ]], -- dzielenie przez skalar
    [[Vector{8,4} // 2                  ]], -- dzielenie całkowitoliczbowe przez skalar
    [[Vector{3,4,5,6}[3]                ]], -- indeksowanie
}

for i, v in ipairs(tests) do
    load( 'res = ' .. v)()
    print(string.format('test %2d: %s --> %s', i, v, res))
end

print '-------------------- iterowanie po wektorze -------------------'
for k, v in ipairs(Vector{2,3,4,5}) do print(k, '-->', v) end