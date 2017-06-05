#!/usr/bin/env lua5.3
moonforth = require 'moonforth'

lu = require 'luaunit'

TestMoonForth = {}

    function TestMoonForth:setUp()
        self.m = moonforth()
    end

    function TestMoonForth:testArithmetic()
        local res = 
        lu.assertEquals(self.m:executeLine('3 5 + .'), '8 ')
        lu.assertEquals(self.m:executeLine('2 1 - .'), '1 ')
        lu.assertEquals(self.m:executeLine('4 4 * .'), '16 ')
        lu.assertEquals(self.m:executeLine('8 2 / .'), '4 ')
    end

    function TestMoonForth:testNewDefinition()
        lu.assertEquals(self.m:executeLine('5 sqr .'), 'sqr?\n')
        lu.assertEquals(self.m:executeLine(': sqr dup * ;'), '')
        lu.assertEquals(self.m:executeLine('sqr .'), '25 ')        
    end

    function TestMoonForth:testIfStatement()
        lu.assertEquals(self.m:executeLine(': test if 1 . else 2 . then ;'), '')
        lu.assertEquals(self.m:executeLine('1 test'), '1 ')
        lu.assertEquals(self.m:executeLine('0 test'), '2 ')
    end

local runner = lu.LuaUnit.new()
runner:setOutputType('tap')
os.exit( runner:runSuite() )