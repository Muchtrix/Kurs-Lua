--[[
    Wiktor Adamski
    Kurs Lua, lista 3
--]]

-- Zadanie 1 ------------------------------------------------------------------
---[[
utf8.reverse = function( word )
    local letters = {utf8.codepoint(word, 1, -1)}
    local res = {}
    for i = 1, #letters do
        res[i] = letters[#letters + 1 - i]
    end
    return utf8.char(table.unpack(res))
end

x = utf8.reverse('Księżyc')
x = utf8.reverse('♠♣♥♦')
--]]
-- Zadanie 2 ------------------------------------------------------------------
---[[
utf8.normalize = function( word )
    local res = {}
    for i, c in utf8.codes(word) do
        if 0 <= c and c <= 127 then
            res[#res + 1] = c
        end
    end
    return utf8.char(table.unpack(res))
end

x = utf8.normalize('Księżyc:\nNów')
x = utf8.normalize('Gżegżółka')
--]]
-- Zadanie 3 ------------------------------------------------------------------
---[[
utf8.sub = function(word, be, en)
    local begin_ind = be or 1
    local end_ind = en or -1
    local word_len = utf8.len(word)
    if begin_ind < 0 then begin_ind = word_len + begin_ind + 1 end
    if end_ind < 0 then end_ind = word_len + end_ind + 1 end
    local result = {}
    for i, c in ipairs({utf8.codepoint(word, 1, -1)}) do
        if begin_ind <= i and i <= end_ind then 
            result[#result + 1] = c
        end
    end
    return utf8.char(table.unpack(result))
end

x = utf8.sub('Księżyc:\nNów', 5, 10)
--]]
-- Zadanie 4 ------------------------------------------------------------------
---[[
string.strip = function(word, chars)
    local removal_chars = chars or ' \t\n'
    local removal_map = {}
    for _, c in ipairs({removal_chars:byte(1, -1)}) do
        removal_map[c] = 1
    end
    local letters = {word:byte(1, -1)}
    while removal_map[letters[#letters]] ~= nil do
        letters[#letters] = nil
    end
    return string.char(table.unpack(letters))
end

x = string.strip('test string \t \n     ')
x = string.strip ('test string', 'tng')
--]]
-- Zadanie 5 ------------------------------------------------------------------
---[[
string.split = function(word, sep)
    local separator = sep or ' '
    separator = separator:byte()
    local res = {}
    local beginning = 1
    local ending = 1
    local word_chars = {word:byte(1, -1)}
    while ending <= #word_chars do
        if separator == word_chars[ending] then 
            res[#res + 1] = word:sub(beginning, ending - 1)
            beginning, ending = ending + 1, ending + 1
        else
            ending = ending + 1
        end
    end
    res[#res + 1] = word:sub(beginning, ending - 1)
    return res
end

x = string.split(' test string  ')
x = string.split('test,12,5,,xyz', ',')
print ''
--]]
-- Zadanie 6 ------------------------------------------------------------------
--[[
function lreverser(source, target)
    local inp, out
    if source == nil then 
        inp = io.stdin
    else
        inp = io.open(source, 'r')
    end
    if target == nil then
        out = io.stdout
    else
        out = io.open(target, 'r')
        if out ~= nil then
            print ('Plik ' .. target .. ' istnieje. Nadpisać? [t/n]')
            local response = io.read('line')
            if response ~= 't' then
                return false
            end
            io.close(out)
        end
        out = io.open(target, 'w')
    end
    local tmp = {}
    for line in inp:lines() do
        tmp[#tmp + 1] = line
    end
    for i = #tmp, 1, -1 do
        out:write(tmp[i]..'\n')
    end
    if inp ~= io.stdin then io.close(inp) end
    if out ~= io.stdout then io.close(out) end
    return true
end

lreverser('wejscie.txt', 'wyjscie.txt')
--]]
-- Zadanie 7 ------------------------------------------------------------------
--[[
lorem_input = io.open('lorem.html', 'r')
lorem_output = io.open('lorem-copy.html', 'w')
lorem_output:setvbuf('no')
czas = os.clock()
for byte in lorem_input:lines(1) do
    lorem_output:write(byte)
end
print(string.format("Metoda bajt-po-bajcie: %.2fs", os.clock() - czas))
io.close(lorem_input)
io.close(lorem_output)

lorem_input = io.open('lorem.html', 'r')
lorem_output = io.open('lorem-copy.html', 'w')
lorem_output:setvbuf('no')
czas = os.clock()
for line in lorem_input:lines('line') do
    lorem_output:write(line)
end
print(string.format("Metoda linijka-po-linijce: %.2fs", os.clock() - czas))
io.close(lorem_input)
io.close(lorem_output)

lorem_input = io.open('lorem.html', 'r')
lorem_output = io.open('lorem-copy.html', 'w')
lorem_output:setvbuf('no')
czas = os.clock()
for block in lorem_input:lines(2^13) do
    lorem_output:write(block)
end
print(string.format("Metoda bloków 8kB: %.2fs", os.clock() - czas))
io.close(lorem_input)
io.close(lorem_output)

lorem_input = io.open('lorem.html', 'r')
lorem_output = io.open('lorem-copy.html', 'w')
lorem_output:setvbuf('no')
czas = os.clock()
lorem_output:write(lorem_input:read('all'))
print(string.format("Cały plik za jednym razem: %.2fs", os.clock() - czas))
io.close(lorem_input)
io.close(lorem_output)
--]]