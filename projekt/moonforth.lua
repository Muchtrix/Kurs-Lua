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
    -- Instrukcje arytmetyczne
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
    -- Instrukcje We/wy
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
    -- Instrukcje sterujące
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
            local ret = pop(forth.returnStack)
            forth.currentWordstream, forth.currentInstruction = ret.wordStream, ret.pos
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
    -- Instrukcje modyfikujące stos
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
            forth:pushStack(pointer(forth.dictionaryPointer.table, forth.dictionaryPointer.index + 1))
        end
    },
    ['\''] = {
        body = function(forth)
            forth:pushStack(forth:getNextWord())
        end
    },
    [','] = {
        body = function(forth)
            forth:compileToken(forth:popStack())
        end
    },
    ['!'] = {
        body = function(forth)
            local x, adress = forth:popStack2()
            forth.dictionary[adress.table].body[adress.index] = x
        end
    },
    -- Instrukcje debugujące
    ['stack'] = {
        immediate = true,
        body = function(forth)
            print '---Stack dump---'
            for i = #forth.variableStack, 1, -1 do
                local v = forth.variableStack[i]
                print(i .. ':',type(v),  type(v) == 'table' and printTable(v) or v)
            end
            print '---Stack dump end ---'
        end
    },
    ['word-info'] = {
        immediate = true,
        body = function(forth)
            local word = forth:getNextWord()
            print(word, ':', printTable(forth.dictionary[word]))
        end
    }
}

moonforth.defaultInit = {
    ': rot >r swap r> swap ;',
    ': -rot rot rot ;',
    ': >mark here \' 0 , ;',
    ': if immediate \' ?branch , >mark ;',
    ': else immediate \' branch , >mark swap dup here swap - 1 - swap ! ;',
    ': then immediate dup here swap - 1 - swap ! ;',
    ': begin immediate here ;',
    ': until immediate \' ?branch , here - 1 - , ;'
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
        if def == nil then return true end
        if def.immediate then self:execute(token, true)
        else self:compileToken(token)
        end
    else
        -- Czy token jest w słowniku?
        if self.dictionary[token] then
            push(self.returnStack, {wordStream = self.currentWordstream, pos = self.currentInstruction})
            self.currentWordstream = token
            self.currentInstruction = 0
        -- Czy token jest prymitywem?
        elseif primitives[token] then
            primitives[token].body(self)
        -- Czy token jest liczbą?
        elseif tonumber(token) then self:pushStack(tonumber(token))
        else return true
        end
    end
end

function moonforth:executeLine(line)
    self:loadWordBuffer(moonforth.tokenizer(line))
    self.printBuffer = ""

    while self.currentInstruction < #(self.currentWordstream and self.dictionary[self.currentWordstream].body or self.wordBuffer) do 
        local token = self:getNextWord()
        local override = self.currentWordstream ~= nil
        if self:execute(token, override) then 
            self.printBuffer = self.printBuffer .. token .. '?'
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
        printBuffer = ''
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