moonforth = require 'moonforth'
m = moonforth()

print 'MoonForth --- a Lua Forth interpreter'
print 'A.D. 2017 by Wiktor Adamski'
print ''
io.write (m.compileMode and 'C> ' or 'I> ')

for linijka in io.lines() do
    m:executeLine(linijka)
    io.write (m.compileMode and 'C> ' or 'I> ')
end