local moonforth = {}
local mt = {__metatable = 'MoonForth', __index = moonforth}
local pointer = require 'pointer'

local function push(stack, var)
    stack[#stack + 1] = var
end

local function pop(stack)
    local var = stack[#stack]
    stack[#stack] = nil
    return var
end

local function printTable(table)
    local res = '{'
    for i, v in pairs(table) do
        res = res .. ' ' .. i .. ' = ' .. ((type(v) == 'table') and printTable(v) or tostring(v)) .. ','
    end
    res = res:gsub(',$', '}')
    return res
end

local primitives = {
    -- Słowa arytmetyczne
    ['+'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a + b)
        end
    },
    ['-'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a - b)
        end
    },
    ['*'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a * b)
        end
    },
    ['/'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a // b)
        end
    },
    ['='] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a == b and 1 or 0)
        end
    },
    ['>'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a > b and 1 or 0)
        end
    },
    ['<'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a < b and 1 or 0)
        end
    },
    ['and'] = { -- Uwaga: operacje bitowe
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a & b)
        end
    },
    ['or'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a | b)
        end
    },
    ['xor'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a ~ b)
        end
    },
    ['invert'] = {
        body = function(forth)
            forth:pushStack(~ forth:popStack())
        end
    },
    -- Słowa drukujące na ekran
    ['.'] = { -- (x --- ) Pisze x na ekran
        body = function(forth)
            forth.outputBuffer = forth.outputBuffer .. forth:popStack() .. ' '
        end
    },
    ['..'] = { -- ( --- ) Wypisuje następne słowo na ekran
        body = function(forth)
            forth.outputBuffer = forth.outputBuffer .. forth:getNextWord()
        end
    },
    ['."'] = { -- ( --- ) (Słowo kompilacji) Wypisuje na ekran napis zakończony "
        immediate = true,
        body = function(forth)
            str = ''
            tmp = forth:getNextWord()
            while tmp:sub(-1, -1) ~= '"' do str, tmp = str .. tmp .. ' ', forth:getNextWord() end
            str = str .. tmp:sub(1, -2)
            forth:compileToken('..')
            forth:compileToken(str)
        end
    },
    ['emit'] = { -- ( c --- ) Wypisuje znak o kodzie c
        body = function(forth) forth.outputBuffer = forth.outputBuffer .. string.char(forth:popStack()) end
    },
    ['cr'] = { -- ( --- ) Wstawia znak nowej linii
        body = function(forth) forth.outputBuffer = forth.outputBuffer .. '\n' end
    },
    -- Słowa sterujące
    [':'] = { -- ( --- ) Rozpoczyna definicję nowego słowa
        immediate = true,
        body = function(forth)
            local newWord = forth:getNextWord()
            forth.compileMode = true
            forth.dictionaryPointer.table = newWord
            forth.dictionaryPointer.index = 0
            forth.dictionary[newWord] = {immediate = false, body = {}}
        end
    },
    ['exit'] = { -- ( --- ) W trybie interpretacji kończy działanie maszyny.
                 -- W trybie kompilacji wychodzi z aktualnie wykonywanego słowa
        body = function(forth)
            if #forth.returnStack == 0 then
                forth.machineOn = false
            else
                local ret = pop(forth.returnStack)
                forth.currentWordstream, forth.currentInstruction = ret.table, ret.index
            end
        end
    },
    [';'] = { -- ( --- ) Kończy definicję słowa
        immediate = true,
        body = function(forth)
            forth:compileToken('exit')
            forth.compileMode = false
        end
    },
    ['immediate'] = { -- ( --- ) Zmienia definowane słowo na słowo natychmiastowe
        immediate = true,
        body = function(forth)
            forth.dictionary[forth.dictionaryPointer.table].immediate = true
        end
    },
    ['\\'] = { -- ( --- ) Komentarz linijkowy
        immediate = true,
        body = function(forth)
            forth.wordBuffer = {}
        end
    },
    ['branch'] = { -- ( --- ) Skok bezwarunkowy
        body = function(forth)
            local jumpV = forth:getNextWord()
            forth.currentInstruction = forth.currentInstruction + jumpV
        end
    },
    ['?branch'] = { -- ( x --- ) Skok warunkowy gdy x == 0
        body = function(forth)
            local jumpV = forth:getNextWord()
            if forth:popStack() == 0 then forth.currentInstruction = forth.currentInstruction + jumpV end
        end
    },
    -- Słowa modyfikujące stos
    ['clear'] = { -- (wszystko --- ) Czyści stos zmiennych
        body = function(forth)
            forth.variableStack = {}
        end
    },
    ['dup'] = { -- ( x --- x x ) Podwaja zmienną na szczycie stosu
        body = function(forth) 
            local a = forth:popStack()
             forth:pushStack(a)
             forth:pushStack(a)
        end
    },
    ['drop'] = { -- ( x --- ) Usuwa zmienną ze szczytu stosu
        body = function(forth)
            forth:popStack()
        end
    },
    ['swap'] = { -- ( a b --- b a ) Zamienia miejscami 2 zmienne na szczycie
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(b)
            forth:pushStack(a)
        end
    },
    ['over'] = { -- ( a b --- a b a )
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a)
            forth:pushStack(b)
            forth:pushStack(a)
        end
    },
    ['r>'] = { -- ( --- x ) (R: x --- ) Przenosi zmienną ze stosu powrotów na stos zmiennych
        body = function(forth)
            forth:pushStack(pop(forth.returnStack))
        end
    },
    ['>r'] = { -- ( x --- ) (R: --- x ) Przenosi zmienną ze stosu zmiennych na stos powrotów
        body = function(forth)
            push(forth.returnStack, forth:popStack())
        end
    },
    ['here'] = { -- ( --- addr ) Umieszcza na stosie wskaźnik aktualnie kompilowanego słowa (dla instrukcji warunkowych)
        body = function(forth)
            forth:pushStack(pointer(forth.dictionaryPointer.table, forth.dictionaryPointer.index))
        end
    },
    ["'"] = { -- ( --- x ) Umieszcza następne słowo na stosie
        body = function(forth)
            forth:pushStack(forth:getNextWord())
        end
    },
    [','] = { -- ( x --- ) Umieszcza szczyt stosu w aktualnej definicji
        body = function(forth)
            forth:compileToken(forth:popStack())
        end
    },
    -- Słowa obsługi zmiennych
    ['@'] = { -- ( addr --- x ) Umieszcza na stosie zawartość zmiennej pod addr
        body = function(forth)
            local adress = forth:popStack()
            forth:pushStack(forth.dictionary[adress.table].body[adress.index])
        end
    },
    ['!'] = { -- (x addr --- ) Przypisuje zmiennej pod addr wartość x
        body = function(forth)
            local x, adress = forth:popStack2()
            forth.dictionary[adress.table].body[adress.index] = x
        end
    },
    ['variable'] = { -- ( --- ) Definicja nowej zmiennej
        immediate = true,
        body = function(forth)
            local varName = forth:getNextWord()
            forth.dictionary[varName] = {
                immediate = false,
                body = {
                    '\'',
                    pointer(varName, 4),
                    'exit'
                }
            }
        end
    },
    ['s"'] = { -- ( addr --- ) Umieszcza w zmiennej pod addr napis zakończony "
        body = function(forth)
            addr = forth:popStack()
            str = ''
            tmp = forth:getNextWord()
            while tmp:sub(-1, -1) ~= '"' do str, tmp = str .. tmp .. ' ', forth:getNextWord() end
            str = str .. tmp:sub(1, -2)
            forth.dictionary[addr.table].body[addr.index] = #str
            for i = 1, #str do
                forth.dictionary[addr.table].body[addr.index + i] = str:sub(i,i):byte()
            end
        end
    },
    -- Słowa obsługi plików
    ['r/o'] = { -- ( --- 1 ) Umieszcza na stosie wskaźnik trybu read-only
        body = function(forth)
            forth:pushStack(1)
        end
    },
    ['w/o'] = { -- ( --- 2 ) Umieszcza na stosie wskaźnik trybu write-only
        body = function(forth)
            forth:pushStack(2)
        end
    },
    ['open-file'] = { -- (fam --- handle status ) Otwiera plik o nazwie w następnym słowie w trybie fam.
                      -- Umieszcza na stosie uchwyt do pliku i 0 jeśli otwarcie się powiodło, w.p.p. 1
        body = function(forth)
            mode = forth:popStack() == 1 and 'r' or 'w'
            filename = forth:getNextWord()
            handle = io.open(filename, mode)
            if handle then 
                forth.fileHandles[#forth.fileHandles + 1] = handle
                forth:pushStack(#forth.fileHandles)
                forth:pushStack(0)
            else
                forth:pushStack(0)
                forth:pushStack(1)
            end
        end
    },
    ['close-file'] = { -- (handle --- ) Zamyka plik o uchwycie handle
        body = function(forth)
            handle = forth:popStack()
            io.close(forth.fileHandles[handle])
            forth.fileHandles[handle] = nil
        end
    },
    ['read-line'] = { -- (addr handle --- len status) Wczytuje linijkę tekstu z pliku handle do zmiennej addr.
                      -- Jeśli odczyt się udał, len to liczba wczytanych znaków, status to 1.
                      -- w.p.p. len = status = 0
        body = function(forth)
            handle = forth.fileHandles[forth:popStack()]
            variableAddr = forth:popStack()
            line = handle:read()
            if line then
                forth:pushStack(#line)
                forth:pushStack(1)
                forth.dictionary[variableAddr.table].body[variableAddr.index] = #line
                for i = 1, #line do
                    forth.dictionary[variableAddr.table].body[variableAddr.index + i] = line:sub(i, i):byte()
                end
            else
                forth:pushStack(0)
                forth:pushStack(0)
            end
        end
    },
    ['write-line'] = { -- (addr handle --- ) Zapisuje linijkę tekstu ze zmiennej pod addr do pliku handle
        body = function(forth)
            handle = forth.fileHandles[forth:popStack()]
            variable = forth:popStack()
            length = forth.dictionary[variable.table].body[variable.index]
            line = ''
            for i = 1, length do
                line = line .. string.char(forth.dictionary[variable.table].body[variable.index + i])
            end
            handle:write(line .. '\n')
        end
    },
    -- Słowa debugujące
    ['stack'] = { -- ( --- ) Wypisuje na ekran zawartość stosu zmiennych
        immediate = true,
        body = function(forth)
            print '------- Stack dump ------'
            for i = #forth.variableStack, 1, -1 do
                local v = forth.variableStack[i]
                print(i .. ':',type(v),  type(v) == 'table' and printTable(v) or v)
            end
            print '--- End of stack dump ---'
        end
    },
    ['word-info'] = { -- ( --- ) Wypisuje informacje o następnym słowie
        immediate = true,
        body = function(forth)
            local word = forth:getNextWord()
            print(word, ':', forth.dictionary[word] and printTable(forth.dictionary[word]) or 'This word is either primitive or not defined')
        end
    }
}

moonforth.defaultInit = {
    -- słowa manipulijące stosem
    ': tuck swap >r dup r> swap ;', -- (a b   --- b a b)
    ': nip swap drop ;',            -- ( a b  --- b)
    ': rot >r swap r> swap ;',      -- (a b c --- b c a)
    ': -rot rot rot ;',             -- (a b c --- c a b)
    ': dup2 over over ;',           -- (a b   --- a b a b)
    ': drop2 drop drop ;',          -- (a b   --- )
    -- słowa operacji logicznych
    ': 0= 0 = ;',
    ': <> = 0= ;',
    ': not 0= ;',
    ': >= < not ;',
    ': <= > not ;',
    ': logical not not ;',
    ': min dup2 > if swap then drop ;',
    ': max dup2 < if swap then drop ;',
    -- słowa na zmiennych
    ': ? @ . ;',
    ': +! dup -rot @ + swap ! ;',
    -- słowa warunkowe
    ": >mark ' 0 , here ;",
    ": if immediate ' ?branch , >mark r> swap >r >r ;",
    ": else immediate ' branch , r> r> swap >r >mark r> swap >r >r swap dup here swap - swap ! ;",
    ': then immediate r> r> swap >r dup here swap - swap ! ;',
    ': begin immediate here r> swap >r >r ;',
    ": until immediate ' ?branch , r> r> swap >r here - 1 - , ;",
    -- implementacja pętli for
    'variable i',
    ': for swap i ! ;', -- (a b --- ) for i in [a, b]
    ": do immediate here r> swap >r >r ;", -- exapmle: : test 0 10 for do i ? done ;
    ": done immediate ' dup , ' 1 , ' i , ' +! , ' i , ' @ , ' < , ' ?branch , r> r> swap >r here - 1 - , ' drop , ;",
    -- pętla for dla zmiany licznika podanej jako 3ci argument
    'variable delta',
    ": for? delta ! for ;", -- example: : test 0 10 2 for? do? i ? done? ; --> 0 2 4 6 8
    ": do? immediate here r> swap >r >r ;",
    ": done? immediate ' dup , ' delta , ' @ , ' i , ' +! , ' i , ' @ , ' = , ' ?branch , r> r> swap >r here - 1 - , ' drop , ;",
    -- słowa na napisach
    ': type dup 0= if drop drop exit then 0 swap 1 - for do over i @ + @ emit done drop ;', -- (c-addr len --- ) wypisanie len znaków zaczynając od c-addr
    ': .type dup @ swap 1 + swap type ;', -- (addr --- ) wypisanie napisu pod addr
    ': copy 1 swap for do -rot dup2 swap @ swap ! 1 + swap 1 + swap rot done drop2 ;', -- (c-addr1 c-addr2 u ---) kopiuje u znaków z c-addr1 do c-addr2
    ': copy-str dup2 swap ! swap 1 + swap copy ;', -- (c-addr addr u ---) kopiuje u znaków z c-addr do nowego napisu w addr
    ': copy-str-str swap dup @ swap 1 + -rot copy-str ;', -- (addr1 addr2 ---) kopiuje napis z addr1 do addr2
    [[: equal dup2 @ swap @ = if
            dup @ 0= if 
                drop2 1 exit then
            dup @ 1 swap for do
                -rot dup2 i @ + @ swap i @ + @ <> if drop drop2 0 exit then rot
            done drop2 1
        else drop2 0 then ;]], -- (addr1 addr2 --- u) sprawdza równość napisów pod zadanymi adresami
}

function moonforth:pushStack(value)
    push(self.variableStack, value)
end

function moonforth:popStack()
    return pop(self.variableStack)
end

function moonforth:popStack2()
    local res2 = self:popStack()
    local res1 = self:popStack()
    return res1, res2
end

function moonforth:loadWordBuffer(tokens)
    self.wordBuffer = tokens
end

function moonforth:compileToken(token)
    self.dictionaryPointer.index = self.dictionaryPointer.index + 1
    self.dictionary[self.dictionaryPointer.table].body[self.dictionaryPointer.index] = token
end

function moonforth:getNextWord()
    self.currentInstruction = self.currentInstruction + 1
    return self.currentWordstream 
        and self.dictionary[self.currentWordstream].body[self.currentInstruction]
        or self.wordBuffer[self.currentInstruction]
end

function moonforth.tokenizer(line)
    local res = {}
    for token in string.gmatch(line, '([^%s]+)') do res[#res + 1] = token end
    return res
end

function moonforth:execute(token, overrideCompile)
    token = token:lower()
    overrideCompile = overrideCompile or false
    if self.compileMode and (not overrideCompile) then 
        if tonumber(token) then 
            self:compileToken(token)
            return
        end
        local def = self.dictionary[token] and self.dictionary[token] or primitives[token]
        if def == nil then error(token .. '?', 0) end
        if def.immediate then self:execute(token, true)
        else self:compileToken(token)
        end
    else
        -- Czy token jest w słowniku?
        if self.dictionary[token] then
            push(self.returnStack, pointer(self.currentWordstream, self.currentInstruction))
            self.currentWordstream = token
            self.currentInstruction = 0
        -- Czy token jest prymitywem?
        elseif primitives[token] then
            primitives[token].body(self)
        -- Czy token jest liczbą?
        elseif tonumber(token) then self:pushStack(tonumber(token))
        else error(token .. '?', 0)
        end
    end
end

function moonforth:executeLine(line)
    self:loadWordBuffer(moonforth.tokenizer(line))
    self.outputBuffer = ''

    while self.currentInstruction < #(self.currentWordstream and self.dictionary[self.currentWordstream].body or self.wordBuffer) do 
        local token = self:getNextWord()
        local override = self.currentWordstream ~= nil
        local is_correct, msg = pcall(self.execute, self, token, override)
        if not is_correct then 
            self.outputBuffer = self.outputBuffer .. msg
            self.wordBuffer = {}
        end
    end
    self.currentInstruction = 0
    return self.outputBuffer
end

function moonforth:new(init)
    local initialProgram = init or moonforth.defaultInit
    local obj = {
        variableStack = {},
        dictionary = {},
        compileMode = false,
        dictionaryPointer = pointer(null, 0),
        wordBuffer = {},
        currentWordstream = nil,
        currentInstruction = 0,
        returnStack = {},
        outputBuffer = '',
        fileHandles = {},
        machineOn = true
    }
    setmetatable(obj, mt)
    for _, v in ipairs(initialProgram) do obj:executeLine(v) end
    return obj
end

function moonforth.findMatching(seq, startPos, incWord, decWord)
    local depth = 0
    for i = startPos, #seq do
        if     seq[i] == incWord then depth = depth + 1 
        elseif seq[i] == decWord then depth = depth - 1 end
        if depth == -1 then return end
    end
    return 0
end

setmetatable(moonforth, {__call = moonforth.new, __metatable = 'Moonforth module'})
return moonforth