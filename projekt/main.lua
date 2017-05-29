moonforth = require 'moonforth'
m = moonforth()

print [[
 _____             _____         _   _   
|     |___ ___ ___|   __|___ ___| |_| |_ 
| | | | . | . |   |   __| . |  _|  _|   |
|_|_|_|___|___|_|_|__|  |___|_| |_| |_|_|

]]
io.write (m.compileMode and 'C> ' or 'I> ')

for linijka in io.lines() do
    m:executeLine(linijka)
    io.write (m.compileMode and 'C> ' or 'I> ')
end