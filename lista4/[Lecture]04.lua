
--- Replaces each tab in a line with a proper number of spaces to make column alignment
-- @param s String with tabs to expand
-- @param tab Tab size (default 8)
-- @return String with tabs replaced by spaces
function expandTabs (s, tab)
  tab = tab or 8 -- tab 'size' (deafult is 8)
  local corr = 0 -- correction
  s = string.gsub(s, '()\t', function (p)
        local sp = tab - (p - 1 + corr)%tab
        corr = corr - 1 + sp
        --print (corr, sp)
        return string.rep(' ', sp)
      end)
  return s
end

print (expandTabs('\tword\t12', t))
print (expandTabs('1)\tw\t12345', t))

print (('-'):rep(25))

--- Replaces spaces in proper columns with tabs
-- @param String to unexpand
-- @param Tab size (default 8)
-- @return String with tabs instead of spaces
function unexpandTabs(s, tab)
  tab = tab or 8 
  s = expandTabs(s, tab)
  local pat = string.rep(' ', tab)
  s = string.gsub(s, pat, '%0\1')
  s = string.gsub(s, ' +\1', '\t')
  s = string.gsub(s, '\1', '')
  return s
end

print (unexpandTabs('\tword\t12'))
print (unexpandTabs('1)\tw\t12345'))


------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------


print (('='):rep(35))

--- Converts every escaped character in string to its digital code representation
-- @param s Input string
-- @return String with escaped characters stored in \ddd form
function code (s)
  return (string.gsub(s, '\\(.)', function (x)
             return string.format('\\%03d', string.byte(x))
          end))
end

--- Converts every character in string from its digital code representation
-- @param s Input string containing digital-formed escape characters
-- @return String with standard characters
function decode (s)
  return (string.gsub(s, '\\(%d%d%d)', function (d)
             return '\\'..string.char(tonumber(d))
          end))
end

print (code([[Ala ma\n kota!]]))
print (decode(code([[Ala ma\n kota!]])))

print (('-'):rep(25))

s = [[xyz: q"This is \"great\" you know!".]]
print ((string.gsub(s, '".-"', string.upper)))
print (decode(string.gsub(code(s), '".-"', string.upper)))
