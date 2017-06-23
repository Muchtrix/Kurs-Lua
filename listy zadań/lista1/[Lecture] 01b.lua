tab = {}
print (#tab)
tab[#tab+1] = 666
print (#tab)

---[[ -- uncommented comment ;-)
function fact(n)
  if n == 0 then
    return 1
  else
    return n * fact (n-1)
  end
end
--]]

print ('Enter a number:')
local k = tonumber(io.read())
print (fact(k))

local ff = fact
print (ff(10))

function printtab(tab)
  str = ''
  for i=1,#tab do
    str = str..tab[i]..' '
  end
  print (str)
end

printtab ( {'ala', 'ma', 127, 'kotów'} )

print (type({})=='table')

local function increment (n)
  return n+1
end
