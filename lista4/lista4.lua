--[[
    Wiktor Adamski
    Kurs Lua, lista 4
--]]

function stringf(tab)
    if type(tab) == 'table' then
        local str = '{'
        for i, v in pairs(tab) do
            if type(v) == 'table' then
                str = str..stringf(v)
            elseif type(i) == 'string' then
                str = str..i..'='..tostring(v)
            elseif type(i) == 'nil' then
                str = str..'nil'
            else
                str = str..tostring(v)
            end
            str = str..', '
        end
        return str .. '}'
    else
        return tostring(tab)
    end
end

function printf(elem)
    local s = stringf(elem):gsub(', }', '}')
    print(s)
end

-- Zadanie 1 ------------------------------------------------------------------
---[[
function lisp_coder(s)
    s = s:sub(2, -2)
    local elements, sub_exp, strings, elem_count = {}, {}, {}, 0
    s = s:gsub('%b()', function(sub)
            sub_exp[#sub_exp + 1] = lisp_coder(sub)
            return string.rep( string.char(0), #sub_exp)
        end)
    s = s:gsub('%b""', function(sub)
            strings[#strings + 1] = sub
            return string.rep( string.char(1), #strings)
        end)
    s:gsub('([%a+-]*)(-?%d*)(%z*)(\001*)', function(symb, num, brac, str)
            elem_count = elem_count + 1
            if symb ~= '' then
                if symb ~= 'nil' then
                    elements[elem_count] = {symbol = symb}
                end
            elseif num ~= '' then
                elements[elem_count] = tonumber(num)
            elseif brac ~= '' then
                elements[elem_count] = sub_exp[#brac]
            else
                elements[elem_count] = strings[#str]
            end
        end)
    return elements
end

print '--- Zadanie 1 ---'
printf(lisp_coder('(ala 12 ma (34) kota)'))
printf(lisp_coder('(if nil (list 1 2 "foo bar") (+ 1 2 var 4))'))

--]]
-- Zadanie 2 ------------------------------------------------------------------
---[[
num_exp = '[+-]?%d+%.?%d*'
exp_exp = num_exp .. '%s*[+-/*]%s*' .. num_exp

function correct_exp(s)
    s = s:gsub('%b()',
        function (sub)
            sub = sub:sub(2, -2)
            if correct_exp(sub) then return ' 0 ' else return 'a' end
        end)
    local last_substitutions = 1
    while last_substitutions > 0 do
        s, last_substitutions = s:gsub(exp_exp, ' 0 ')
    end
    return s:gsub('%s*' .. num_exp .. '%s*', '0') == '0'
end

print '--- Zadanie 2 ---'
for _, x in ipairs{'-2+ 4.503', '(2*3.5*4)- (+12)/3', '+18.3', '12.4 - ', 'wcale nie wyrażenie', '1 + 1 + 1 + 1'} do
    print('"' .. x .. '"  -->  ' .. tostring(correct_exp(x)))
end
--]]
-- Zadanie 3 ------------------------------------------------------------------
---[[
separator = package.config:sub(1,1)
last_file = separator .. [[?([^]] .. separator ..[[]-)%.(%w+)$]]
path = 'K:/hidden-name/Teaching/2016_Lua/[Lab]/Lecture 04.pdf'

function unpath(s)
    local res = {}
    s:gsub( separator .. [[?([^]] .. separator .. [[]*)]],
        function(s)
            res[#res + 1] = s
        end)
    res[#res] = {s:match(last_file)}
    return res
end

print '--- Zadanie 3 ---'
printf(unpath(path))
print ''
--]]
-- Zadanie 4 ------------------------------------------------------------------
---[[

--]]