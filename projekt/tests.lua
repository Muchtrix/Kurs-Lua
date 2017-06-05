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
        lu.assertEquals(self.m:executeLine('5 sqr .'), 'sqr?')
        lu.assertEquals(self.m:executeLine(': sqr dup * ;'), '')
        lu.assertEquals(self.m:executeLine('sqr .'), '25 ')        
    end

    function TestMoonForth:testIfStatement()
        lu.assertEquals(self.m:executeLine(': test if 1 . else 2 . then ;'), '')
        lu.assertEquals(self.m:executeLine('1 test'), '1 ')
        lu.assertEquals(self.m:executeLine('0 test'), '2 ')
    end

    function TestMoonForth:testLoop()
        lu.assertEquals(self.m:executeLine(': dup2 over over ;'), '')
        lu.assertEquals(self.m:executeLine(': loop begin dup . 1 - dup2 > until ;'), '')
        lu.assertEquals(self.m:executeLine('0 5 loop'), '5 4 3 2 1 0 ')
        lu.assertEquals(self.m:executeLine('9 12 loop'), '12 11 10 9 ')
    end

    function TestMoonForth:testVariable()
        lu.assertEquals(self.m:executeLine('variable test-variable'), '')
        lu.assertEquals(self.m:executeLine('10 test-variable !'), '')
        lu.assertEquals(self.m:executeLine('test-variable ?'), '10 ')
        lu.assertEquals(self.m:executeLine('11 test-variable +!'), '')
        lu.assertEquals(self.m:executeLine('test-variable ?'), '21 ')
    end

os.exit( lu.LuaUnit:runSuite('--output', 'tap') )