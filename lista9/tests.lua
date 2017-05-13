lib = require 'zadanie1'

print "-- summation --"

print("summation(1,2,3,4,5) = ", lib.summation(1,2,3,4,5))
print("summation() = ", lib.summation())

print "-- reduce --"
print("reduce(summation, {1,2,3,4,5}, 0) = ", lib.reduce(lib.summation, {1,2,3,4,5}, 0))
print("reduce(summation, {1,2,3,4,5}) = ", lib.reduce(lib.summation, {1,2,3,4,5}))

print "-- merge --"
res = lib.merge({a = "a"}, {a = "", b = "b"}, {b = "bb"}, {c = "c"})
print 'res = lib.merge({a = "a"}, {a = "", b = "b"}, {b = "bb"}, {c = "c"})'
print('res.a = ', res.a)
print('res.b = ', res.b)
print('res.c = ', res.c)

print "-- splitAt --"
print 'res = {lib.splitAt({1,2,3,4,5,6,7,8,9}, 1, 2, 3, 5)}'
res = {lib.splitAt({1,2,3,4,5,6,7,8,9}, 1, 2, 3, 5)}
for i, v in ipairs(res) do
    print("wynik nr:", i)
    for _, vv in ipairs(v) do
        print(vv)
    end
end