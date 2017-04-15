local Object = {}

function Object.__call(self, ...)
    return self.new(...)
end

local Vector2 = {}
setmetatable(Vector2, Object)

Vector2.__index = Object
Vector2.new = function (x, y) return setmetatable({x = x, y = y}, Vector2) end
Vector2.__add = function(v1, v2) return Vector2(v1.x + v2.x, v1.y + v2.y) end
Vector2.__tostring = function(v) return '(' .. v.x .. ', ' .. v.y ..')' end

return Vector2


