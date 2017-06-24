moonforth = require 'moonforth'
m = moonforth()

print [[
 _____             _____         _   _   
|     |___ ___ ___|   __|___ ___| |_| |_ 
| | | | . | . |   |   __| . |  _|  _|   |
|_|_|_|___|___|_|_|__|  |___|_| |_| |_|_|
            --- THE REPL ---
]]
execLine = function(line)
    local res = m:executeLine(line)
    if res ~= '' then print(res) end
    return m.machineOn
end