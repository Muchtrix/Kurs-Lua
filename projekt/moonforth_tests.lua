return_values = ''
returned = false

old_print = print

-- function io.write(...) 
--     for i, v in ipairs{...} do
--         return_values = return_values .. v
--     end
--     returned = true 
--end
--function print(...) end

moonforth = require 'moonforth'

m = moonforth()

lines = {
    '5 3 + . cr',
    ': sqr dup * ;',
    '5 sqr . cr',
    ': test if 1 . else 2 . then cr',
    '0 test',
    '1 test',
}

for _, line in ipairs(lines) do
    m:executeLine(line)
    if returned then 
        old_print ('MoonForth returned value ' .. return_values)
        returned = false
        return_values = ''
    end
end