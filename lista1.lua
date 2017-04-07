--[[
    Wiktor Adamski
    Kurs Lua, lista 1
--]]

function stringf(tab)
  if type(tab) == 'table' then
    local str = '{'
    for i = 1, #tab do
      if type(tab[i]) == 'table' then
        str = str..stringf(tab[i])
      else
        str = str..tab[i]
      end
      if i == #tab then
        str = str..'}'
      else
        str = str..', '
      end
    end
    return str
  else
    return tostring(tab)
  end
end

function printf(elem)
  print(stringf(elem))
end

function map(t, fun)
  local res = {}
  for i, v in ipairs(t) do
    res[i] = fun(v)
  end
  return res
end

  
function printtab(tab)
  str = ''
  for i=1,#tab do
    str = str..tab[i]..' '
  end
  print (str)
end