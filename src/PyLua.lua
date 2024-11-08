local Scanner = require "src.Scanner"
local Parser = require "src.Parser"
local codeGen = require 'src.codeGen'

return function(source)
  local scanner = Scanner:new(source)
  local tokens = scanner:scanTokens() --lexer

  local parser = Parser:new(tokens)
  local AST = parser:parse() --parser

  local luacode = codeGen(AST) --transpiler
  return luacode
end
