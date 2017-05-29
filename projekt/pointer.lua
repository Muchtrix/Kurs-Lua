local pointer = {}
local mt = {__index = pointer, __metatable = 'pointer'}

function pointer:new(table, index)
    return setmetatable({table = table, index = index}, mt)
end

function mt.__add(p, v)
    return pointer(p.table, p.index + v)
end

function mt.__sub(p, v)
    if type(v) == 'number' then return pointer(p.table, p.index - v)
    else return p.index - v.index end
end

setmetatable(pointer, {__call = pointer.new, __metatable = 'pointer module'})
return pointer