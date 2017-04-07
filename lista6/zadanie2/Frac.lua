local Frac = {}
local mt = {__metatable = 'Frac'}

local function gcd(a, b)
    while b > 0 do
        a, b = b, a % b
    end
    return a
end

local function normalize(fr)
    local gc = gcd(fr.num, fr.den)
    fr.num, fr.den = math.floor(fr.num // gc), math.floor(fr.den // gc)
end

-- Funkcje arytmetyczne -------------------------------------------------------

function mt.__add(fr1, fr2)
    if type(fr1) == 'number' then fr1 = Frac.toFrac(fr1) end
    if type(fr2) == 'number' then fr2 = Frac.toFrac(fr2) end
    local res = Frac(fr1.num * fr2.den + fr2.num * fr1.den, fr1.den * fr2.den)
    normalize(res)
    return res
end

function mt.__unm(fr)
    return Frac(-fr.num, fr.den)
end

function mt.__sub(fr1, fr2)
    return fr1 + (- fr2)
end

function mt.__mul(fr1, fr2)
    res = Frac(fr1.num * fr2.num, fr1.den * fr2.den)
    normalize(res)
    return res
end

function mt.__div(fr1, fr2)
    return fr1 * Frac(fr2.den, fr2.num)
end

function mt.__pow(fr, ex)
    if type(ex) ~= 'number' or math.floor(ex) ~= ex then error('Wrong argument 2', 2)
    else return Frac(math.floor(fr.num ^ ex), math.floor(fr.den ^ ex)) end
end

-- Operatory porównania -------------------------------------------------------

function mt.__eq(fr1, fr2)
    return fr1.num == fr2.num and fr1.den == fr2.den
end

function mt.__lt(fr1, fr2)
    return fr1.num * fr2.den < fr2.num * fr1.den
end

function mt.__le(fr1, fr2)
    return fr1 == fr2 or fr1 < fr2
end

function mt.__tostring(fr)
    if fr.num < 0 then return '-' .. tostring(- fr) end
    local whole = fr.num // fr.den
    if whole == 0 then return fr.num .. '/' .. fr.den
    else return whole .. ' i ' .. fr.num % fr.den .. '/' .. fr.den end
end

-- Funkcje napisowe -----------------------------------------------------------

function mt.__concat(arg1, arg2)
    return tostring(arg1) .. tostring(arg2)
end

function Frac:new(num, den)
    if den == 0 then error("Denominator can't be 0.", 2) end
    if num == 0 then den = 1 end
    if den < 0 then num, den = -num, -den end
    local obj = {num = num, den = den}
    normalize(obj)
    setmetatable(obj, mt)
    return obj
end

function Frac.toFrac(num)
    if type(num) ~= 'number' then error('Invalid argument type.', 2) end
    local den = 1
    while num ~= math.floor(num) do num, den = num * 10, den * 10 end
    return Frac(num, den)
end

function Frac.tofloat(fr)
    return fr.num / fr.den
end

setmetatable(Frac, {__call = Frac.new, __metatable = 'Modification protection!'})
return Frac