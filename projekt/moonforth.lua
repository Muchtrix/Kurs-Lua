local moonforth = {}
local mt = {__metatable = 'MoonForth', __index = moonforth}

local function push(stack, var)
    stack[#stack + 1] = var
end

local function pop(stack)
    local var = stack[#stack]
    stack[#stack] = nil
    return var
end

local primitives = {
    ['+'] = {
        immediate = false,
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a + b)
        end
    },
    ['-'] = {
        immediate = false,
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a - b)
        end
    },
    ['*'] = {
        immediate = false,
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a * b)
        end
    },
    ['/'] = {
        immediate = false,
        body = function(forth)
            local a, b = forth:popStack2()
            forth:pushStack(a / b)
        end
    },
    ['.'] = {
        immediate = false,
        body = function(forth) io.write(forth:popStack()) end
    },
    ['cr'] = {
        immediate = false,
        body = function() print "" end
    },
    [':'] = {
        immediate = true,
        body = function(forth)
            local newWord = forth:getNextWord()
            forth.compileMode, forth.compileBuffer, forth.dictionary[newWord] = true, newWord, {immediate = false, body = {}} 
        end
    },
    ['STOP'] = {
        immediate = false,
        body = function(forth)
            local ret = pop(forth.returnStack)
            forth.currentWordstream, forth.currentInstruction = ret.wordStream, ret.pos
            end
    },
    [';'] = {
        immediate = true,
        body = function(forth)
            forth:compileToken('STOP')
            forth.compileMode = false
            end
    },
    ['dup'] = {
        immediate = false,
        body = function(forth) 
            local a = forth:popStack()
             forth:pushStack(a)
             forth:pushStack(a)
        end
    }
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
    self.dictionary[self.compileBuffer].body[#(self.dictionary[self.compileBuffer].body) + 1] = token
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

    while (#self.returnStack > 0) or self.currentInstruction < (#self.wordBuffer) do 
        local token = self:getNextWord()
        if self:execute(token) then print (token .. '?') end
    end
    self.currentInstruction = 0
end

function moonforth:new()
    local obj = {
        variableStack = {},
        dictionary = {},
        compileMode = false,
        compileBuffer = nil,
        wordBuffer = {},
        currentWordstream = nil,
        currentInstruction = 0,
        returnStack = {}
    }
    return setmetatable(obj, mt)
end

setmetatable(moonforth, {__call = moonforth.new, __metatable = 'Modification Protection'})
return moonforth