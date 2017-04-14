Frac = require 'lista6.zadanie2.Frac'

tests = {
    [['Wynik : ' .. Frac(2, 3) + Frac(3, 4)]], -- sumowanie i konkatenacja z napisami
    [[Frac.tofloat(Frac(2, 3) * Frac(3, 4))]], -- mnożenie i konwersja na float
    [[Frac(2, 3) < Frac(3, 4)              ]], -- porównywanie ułamków
    [[Frac(2, 3) == Frac(8, 12)            ]], -- równość ułamków
    [[Frac(2, 3) + 2                       ]], -- dodawanie liczb do ułamków
    [[Frac(2, 3) + 2.5                     ]], -- dodawanie liczb do ułamków
    [[Frac(2, 3) ^ 3                       ]], -- potęgowanie ułamków
    [[Frac(7, 3) & Frac(2, 3)              ]], -- bitowy AND
    [[Frac(2, 3) << 2                      ]], -- shift w lewo
    [[Frac(2, 3) >> 1                      ]], -- shift w prawo
}

for i, v in ipairs(tests) do
    load( 'res = ' .. v)()
    print(string.format('test %2d: %s --> %s', i, v, res))
end