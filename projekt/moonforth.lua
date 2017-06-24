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
    ['and'] = {
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
    -- Słowa We/wy
    ['.'] = {
        body = function(forth)
            forth.printBuffer = forth.printBuffer .. forth:popStack() .. ' '
        end
    },
    ['emit'] = {
        body = function(forth) forth.printBuffer = forth.printBuffer .. string.char(forth:popStack()) end
    },
    ['cr'] = {
        body = function(forth) forth.printBuffer = forth.printBuffer .. '\n' end
    },
    -- Słowa sterujące
    [':'] = {
        immediate = true,
        body = function(forth)
            local newWord = forth:getNextWord()
            forth.compileMode = true
            forth.dictionaryPointer.table = newWord
            forth.dictionaryPointer.index = 0
            forth.dictionary[newWord] = {immediate = false, body = {}}
        end
    },
    ['exit'] = {
        body = function(forth)
            if #forth.returnStack == 0 then
                forth.machineOn = false
            else
                local ret = pop(forth.returnStack)
                forth.currentWordstream, forth.currentInstruction = ret.table, ret.index
            end
        end
    },
    [';'] = {
        immediate = true,
        body = function(forth)
            forth:compileToken('exit')
            forth.compileMode = false
        end
    },
    ['immediate'] = {
        immediate = true,
        body = function(forth)
            forth.dictionary[forth.dictionaryPointer.table].immediate = true
        end
    },
    ['\\'] = {
        immediate = true,
        body = function(forth)
            forth.wordBuffer = {}
        end
    },
    ['branch'] = {
        body = function(forth)
            local jumpV = forth:getNextWord()
            forth.currentInstruction = forth.currentInstruction + jumpV
        end
    },
    ['?branch'] = {
        body = function(forth)
            local jumpV = forth:getNextWord()
            if forth:popStack() == 0 then forth.currentInstruction = forth.currentInstruction + jumpV end
        end
    },
    -- Słowa modyfikujące stos
    ['clear'] = {
        body = function(forth)
            forth.variableStack = {}
        end
    },
    ['dup'] = {
        body = function(forth) 
            local a = forth:popStack()
             forth:pushStack(a)
             forth:pushStack(a)
        end
    },
    ['drop'] = {
        body = function(forth)
            forth:popStack()
        end
    },
    ['swap'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(b)
            forth:pushStack(a)
        end
    },
    ['over'] = {
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a)
            forth:pushStack(b)
            forth:pushStack(a)
        end
    },
    ['r>'] = {
        body = function(forth)
            forth:pushStack(pop(forth.returnStack))
        end
    },
    ['>r'] = {
        body = function(forth)
            push(forth.returnStack, forth:popStack())
        end
    },
    ["'('"] = {
        body = function(forth)
            forth:pushStack(('('):byte())
        end
    },
    ['here'] = {
        body = function(forth)
            forth:pushStack(pointer(forth.dictionaryPointer.table, forth.dictionaryPointer.index))
        end
    },
    ["'"] = {
        body = function(forth)
            forth:pushStack(forth:getNextWord())
        end
    },
    [','] = {
        body = function(forth)
            forth:compileToken(forth:popStack())
        end
    },
    ['@'] = {
        body = function(forth)
            local adress = forth:popStack()
            forth:pushStack(forth.dictionary[adress.table].body[adress.index])
        end
    },
    ['!'] = {
        body = function(forth)
            local x, adress = forth:popStack2()
            forth.dictionary[adress.table].body[adress.index] = x
        end
    },
    ['variable'] = {
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
    -- Słowa obsługi plików
    ['r/o'] = {
        body = function(forth)
            forth:pushStack(1)
        end
    },
    ['w/o'] = {
        body = function(forth)
            forth:pushStack(2)
        end
    },
    ['open-file'] = {
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
    ['close-file'] = {
        body = function(forth)
            handle = forth:popStack()
            io.close(forth.fileHandles[handle])
            forth.fileHandles[handle] = nil
        end
    },
    ['read-line'] = {
        body = function(forth)
            handle = forth.fileHandles[forth:popStack()]
            variableAddr = forth:popStack()
            line = handle:read()
            if line then
                forth:pushStack(#line)
                forth:pushStack(1)
                forth.dictionary[variableAddr.table].body[variableAddr.index] = #line
                for i = 1, #line do
                    letter = line:sub(i, i)
                    forth.dictionary[variableAddr.table].body[variableAddr.index + i] = letter:byte()
                end
            else
                forth:pushStack(0)
                forth:pushStack(0)
            end
        end
    },
    ['write-line'] = {
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
    ['stack'] = {
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
    ['word-info'] = {
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
    ': .type dup @ swap 1 + swap type ;' -- (addr --- ) wypisanie napisu pod addr
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
    for token in string.gmatch(line, '([^%s]+)') do res[#res + 1] = token:lower() end
    return res
end

function moonforth:execute(token, overrideCompile)
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
    self.printBuffer = ""

    while self.currentInstruction < #(self.currentWordstream and self.dictionary[self.currentWordstream].body or self.wordBuffer) do 
        local token = self:getNextWord()
        local override = self.currentWordstream ~= nil
        local is_correct, msg = pcall(self.execute, self, token, override)
        if not is_correct then 
            self.printBuffer = self.printBuffer .. msg
            self.wordBuffer = {}
        end
    end
    self.currentInstruction = 0
    return self.printBuffer
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
        printBuffer = '',
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