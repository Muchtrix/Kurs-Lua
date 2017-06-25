#!/usr/bin/env lua
package.path = package.path .. ';../?.lua'
moonforth = require 'moonforth'
lu = require 'luaunit'

TestMoonForth = {}

    function TestMoonForth:setUp()
        self.m = moonforth()
    end

    function TestMoonForth:testArithmetic()
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

    function TestMoonForth:testMultipleIfs()
        lu.assertEquals(self.m:executeLine(': test dup 5 > if 10 > if 1 . then 2 . else 3 . then ;'), '')
        lu.assertEquals(self.m:executeLine('4 test'), '3 ')
        lu.assertEquals(self.m:executeLine('7 test'), '2 ')
        lu.assertEquals(self.m:executeLine('15 test'), '1 2 ')
    end

    function TestMoonForth:testUnbalancedIf()
        lu.assertEquals(self.m:executeLine(': test 1 2 rot if drop . else . drop then ;'), '')
        lu.assertEquals(self.m:executeLine('1 test'), '1 ')
        lu.assertEquals(self.m:executeLine('0 test'), '2 ')
    end

    function TestMoonForth:testVariable()
        lu.assertEquals(self.m:executeLine('variable test-variable'), '')
        lu.assertEquals(self.m:executeLine('10 test-variable !'), '')
        lu.assertEquals(self.m:executeLine('test-variable ?'), '10 ')
        lu.assertEquals(self.m:executeLine('11 test-variable +!'), '')
        lu.assertEquals(self.m:executeLine('test-variable ?'), '21 ')
        lu.assertEquals(self.m:executeLine('test-variable @ 10 + test-variable !'), '')
        lu.assertEquals(self.m:executeLine('test-variable ?'), '31 ')
    end

    function TestMoonForth:testStringVariable()
        lu.assertEquals(self.m:executeLine('variable line'), '')
        lu.assertEquals(self.m:executeLine('line s" This is a test line"'), '')
        lu.assertEquals(self.m:executeLine('line .type'), 'This is a test line')
    end

    function TestMoonForth:testString()
        lu.assertEquals(self.m:executeLine(': test 0= if ." Zero!" else ." Nie zero!" then ;'), '')
        lu.assertEquals(self.m:executeLine('0 test'), 'Zero!')
        lu.assertEquals(self.m:executeLine('1 test'), 'Nie zero!')
    end

    function TestMoonForth:testFactorial()
        lu.assertEquals(self.m:executeLine(': fac dup 1 = if exit else dup 1 - fac * then ;'), '')
        lu.assertEquals(self.m:executeLine('1 fac .'), '1 ')
        lu.assertEquals(self.m:executeLine('3 fac .'), '6 ')
        lu.assertEquals(self.m:executeLine('5 fac .'), '120 ')
    end

    function TestMoonForth:testReadFile()
        lu.assertEquals(self.m:executeLine('variable linijka'), '')
        lu.assertEquals(self.m:executeLine('r/o open-file test_file drop'), '')
        lu.assertEquals(self.m:executeLine('linijka swap read-line drop2 linijka .type 1 close-file'), 'This is a test msg')
    end

os.exit( lu.LuaUnit:runSuite('--output', 'tap') )