Frac = require 'lista6.zadanie2.Frac'

x = Frac(2,3)
print ('Wynik : '..Frac (2, 3) + Frac (3, 4)) --> Wynik : 1 i 5/12
print ( Frac.tofloat ( Frac (2 ,3) * Frac (3 ,4))) --> 0.5
print ( Frac (2 ,3) < Frac (3 ,4)) --> true
print ( Frac (2, 3) == Frac (8 ,12)) --> true
print (Frac(2,3) + 2.5) --> 3 i 1/6
print (Frac(-3, 2))