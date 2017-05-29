return_values = {}
returned = false

function io.write(...) return_values, returned = {...}, true end
function print(...) end

moonforth = require 'moonforth'

m = moonforth()

lines = {
    '5 3 + . cr',
    ': sqr dup * ;',
    '5 sqr . cr'
}

for _, line in ipairs(lines) do
    m:executeLine(line)
    if returned then 
        print ('MoonForth returned value ' .. tostring(return_values[1]))
        returned = false
    end
end