--[[
    Wiktor Adamski
    Kurs Lua, lista 7 - zadanie 6
--]]

function table.map(f, t)
    local res = {}
    for i, v in pairs(t) do
        res[i] = f(v)
    end
    return res
end

function typecheck(f, ...)
    local args = {...}
    local retvals = 1
    if type(args[1]) == 'number' then
        retvals = args[1]
        args = table.move(args, 2, #args, 1, args)
        args[#args] = nil
    end
    for i = 1, #args do
        if type(args[i]) == 'string' 
            and args[i]:sub(-1 , -1) == '*'
            and args[i]:sub(1, 7) ~= 'string:' then
            args[i] = {args[i]:sub(1, -2), 'nil'}
        end
    end

    local function my_type(x)
        if type(x) == 'boolean' then return 'bool' end
        return type(x), type(x) == 'number' and math.type(x) or nil
    end

    local function print_type(ty)
        local function string_pattern(ty)
            return ty:sub(1, 7) == 'string:' and 'string matching ' .. ty:sub(8, -1) or ty
        end
        if type(ty) == 'string' then return string_pattern(ty)
        else return table.concat(table.map(string_pattern, ty),' or ') end
    end

    local function checktype(x, ty)
        if type(ty) == 'nil' then return true end
        if type(ty) == 'table' then
            for _, t in ipairs(ty) do
                if checktype(x, t) then return true end
            end
            return false
        end
        local t, mt = my_type(x)
        if t == ty or mt == ty then return true end
        if t == 'string' and ty:sub(1, 7) == 'string:' then
            return x:gsub(ty:sub(8, -1), '', 1) == '' 
        end
        return false
    end

    return function(...)
        local ar = table.pack(...)
        for i = 1, ar.n do
            if not checktype(ar[i], args[i + retvals]) then 
                error('Function call error: argument ' .. i .. ' is ' .. tostring(ar[i]) .. ' not a ' .. print_type(args[i + retvals]), 2) 
            end
        end
        local return_vals = table.pack(f(...))
        for i = 1, retvals do
            if not checktype(return_vals[i], args[i]) then
                error('Function call error: return value ' .. i .. ' is ' .. tostring(return_vals[i]) .. ' not a ' .. print_type(args[i]), 2)
            end 
        end
        return table.unpack(return_vals, 1, return_vals.n)
    end
end

-- Testy ----------------------------------------------------------------------

local fun = function(x, y)
    return x + y < 10 , x > 0 and {x, x+y, x+2*y} or print
end

local tcfun = typecheck(fun, 2, 'bool', 'table', 'integer', {'number', 'string'})

print(pcall(tcfun, 10, 20))
print(pcall(tcfun, 10, '20.0'))
print(pcall(tcfun, 10.0, '20.0'))
print(pcall(tcfun, 10, nil))
print(pcall(tcfun, -5, 20))

local function someF(...) return 0 end

local tcf = typecheck(someF, 'integer', nil, 'number*', 'string:[rgb]')

print(pcall(tcf, {}, nil, 'r'))
print(pcall(tcf, {}, nil, 'R'))
print(pcall(tcf, 127, 23.5, 'rgb'))
