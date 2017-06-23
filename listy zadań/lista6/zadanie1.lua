--[[
    Wiktor Adamski
    Kurs Lua, lista 5 - zadanie 1
--]]

local LRU_decorator = {}
function LRU_decorator:cacheClear()
    self.c = {}
end
function LRU_decorator:cacheInfo()
    return {hits = self.hits, misses = self.misses, maxsize = self.maxsize, currsize = #(self.c)}
end
function LRU_decorator:embeddedFunction()
    return self.originalFunction
end
function LRU_decorator:decoratedFunction(...)
    local args = table.pack(...)
    for i = 1, #(self.c) do
        if self.c[i].args.n == args.n then
            local good_args = true
            for j = 1, args.n do
                if args[j] ~= self.c[i].args[j] then good_args = false break end
            end
            if good_args then
                local tmp = self.c[i]
                self.c = table.move(self.c, 1, i - 1, 2, self.c)
                self.c[1] = tmp
                self.hits = self.hits + 1
                return tmp.res, true
            end
        end
    end

    self.c = table.move(self.c, 1, maxsize and maxsize - 1 or #(self.c), 2, self.c)
    self.c[1] = {args = args, res = self.originalFunction(...)}
    self.misses = self.misses + 1
    return self.c[1].res, false
end

local mt = {__index = LRU_decorator, __call = LRU_decorator.decoratedFunction}

function cache(f, maxsize)
    return setmetatable({c = {}, hits = 0, misses = 0, maxsize = maxsize, originalFunction = f}, mt)
end

function fib(n)
    if n < 2 then return n
    else return fib(n - 1) + fib(n - 2) end
end

cfib = cache(fib, 32)
czas = os.clock()
for i = 15, 23 do print(cfib(i)) end
print ('czas: ' .. os.clock() - czas)
czas = os.clock()
for i = 1, 23 do print(cfib(i)) end
print ('czas: ' .. os.clock() - czas)

print(cfib:embeddedFunction() == fib)
cfib:cacheClear()