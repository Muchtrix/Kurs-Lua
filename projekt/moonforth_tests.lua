moonforth = require 'moonforth'

m = moonforth()

lines = {
    '5 3 + . cr',
    ': sqr dup * ;',
    '5 sqr . cr'
}

for _, line in ipairs(lines) do
    m:executeLine(line)
end