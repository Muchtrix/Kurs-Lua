--[[
    Wiktor Adamski
    Kurs Lua, lista 5
--]]

-- Przydatne funkcje pomocnicze -----------------------------------------------

table.reverse = function(table)
    local res = {}
    for i = #table, 1, -1 do
        res[#res + 1] = table[i]
    end
    return res
end

table.map = function(f, table)
    local res = {}
    for i = 1, #table do
        res[i] = f(table[i])
    end
    return res
end

-- Zadanie 1 ------------------------------------------------------------------
---[[
print '--- Zadanie 1 ---'

function chain(...)
    return function (state)
        while state[#state] and #(state[#state]) == 0 do
            state[#state] = nil
        end
        if #state > 0 then
            local res = state[#state][#(state[#state])]
            state[#state][#(state[#state])] = nil
            return res
        end
    end, table.map(table.reverse, table.reverse{...})
end

for x in chain({'a', 'b', 'c'}, {40, 50}, {}, {6, 7}) do
    print(x)
end

print(chain({'a', 'b', 'c'}, {40, 50}, {}, {6, 7}))
print(chain({1,2,3,5,6,7}, {2,5,5,4,7}))
--]]
-- Zadanie 2 ------------------------------------------------------------------
---[[
print '--- Zadanie 2 ---'

function zip(...)
    return function (state)
        local res = {}
        for i = 1, #state do
            if #(state[i]) == 0 then return end
            res[#res + 1] = state[i][#(state[i])]
            state[i][#(state[i])] = nil
        end
        return table.unpack(res)
    end, table.map(table.reverse, {...})
end

for x, y in zip({'a', 'b', 'c', 'd'}, {40, 50, 60}) do
    print(x, y)
end

print(zip({'a', 'b', 'c', 'd'}, {40, 50, 60}, {'Abacki', 'Babacki', 'Cabacki', 'Dabacki'}))
print(zip({}, {}))
--]]
-- Zadanie 3 ------------------------------------------------------------------
---[[
print '--- Zadanie 3 ---'

function subsets(t)
    local elements, res = {}, {}
    for k, _ in pairs(t) do
        elements[#elements + 1] = {element = k, wziety = false}
    end
    return function ()
        local carry = true
        for _, v in ipairs(elements) do
            v.wziety, carry = (v.wziety and not carry) or (not v.wziety and carry), v.wziety and carry
            res[v.element] = v.wziety or nil
        end
        if not carry then return res end
    end
end

function keys(t)
    local res = {}
    for k, _ in pairs(t) do res[#res + 1] = k end
    return res
end

for s in subsets{a = true, b = true, [3] = true} do
    print(table.concat(keys(s)))
end

--]]
-- Zadanie 4 ------------------------------------------------------------------
---[[
print '--- Zadanie 4 ---'
function cache(f, maxsize)
    local c = {}
    return function(...)
        args = table.pack(...)
        for i = 1, #c do
            if c[i].args.n == args.n then
                good_args = true
                for j = 1, args.n do
                    if args[j] ~= c[i].args[j] then good_args = false break end
                end
                if good_args then
                    local tmp = c[i]
                    c = table.move(c, 1, i - 1, 2, c)
                    c[1] = tmp
                    return tmp.res, true
                end
            end
        end

        c = table.move(c, 1, maxsize and maxsize - 1 or #c, 2, c)
        c[1] = {args = args, res = f(...)}
        return c[1].res, false
    end
end

function fun(n)
    sum = 0
    for i = 1, 1000000 do sum = sum + i end
    return n
end

fi = cache(fun, 3)

for i, v in ipairs{1, 2, 3, 4, 4, 3, 5, 3, 2, 3} do
    print(i, fi(v))
end
--]]