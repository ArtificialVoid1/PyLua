local TokenType = require "src.TokenType"
local AST = require "src.AST"


------------ Constructor -----------

local Parser = {}
Parser.__index = Parser

function Parser:new(tokens)
  self = setmetatable({
    ['current'] = 1,
    ['line'] = 1,
    ['lineindents'] = {},
    ['isAtStartOfLine'] = true,
    ['isInMethod'] = 0,

    ['tokens'] = tokens,
    ['program'] = AST.program:new(),

    ['variable_cache'] = {},
  }, Parser)
  return self
end

-------------- Helper Functions -------------

function Parser:_isAtEnd()
  return self:_peek(0).TokenType == TokenType.EOF
end

function Parser:_check(tknType)
  if self:_peek() == nil then return false end
  return self:_peek().TokenType == tknType
end

function Parser:_advance()
  self.current = self.current + 1
  return self:_peek(0)
end

function Parser:_peek(amount)
  amount = amount or 1
  return self.tokens[self.current + amount]
end

function Parser:_previous()
  return self:_peek(-1)
end

function Parser:_findVar(lexeme)
  for _, thing in pairs(self.variable_cache) do
    if thing == lexeme then
      return true
    end
  end
  return false
end

------------- Parser Functions -------------

function Parser:_rid_whitespace()
  local newTokens = {}

  for _, token in ipairs(self.tokens) do

    if token.TokenType == TokenType.LINE_BREAK then
      self.isAtStartOfLine = true
    end

    
    if token.TokenType ~= TokenType.SPACE and token.TokenType ~= TokenType.LINE_BREAK then
      table.insert(newTokens, token)
      self.isAtStartOfLine = false
    else
      if self.isAtStartOfLine then
        table.insert(newTokens, token)
      end
    end

  end

  return newTokens
end







function Parser:_parseNonWhitespace()
  local token = self:_peek(0)


  if token.TokenType == TokenType.IDENTIFIER then

    if self:_check(TokenType.LEFT_PAREN) then
      local identifier = token.Lexeme
      self:_advance() --consume identifier
      self:_advance() --consume (
      local args = ""

      while self:_peek(0).TokenType ~= TokenType.LINE_BREAK do
        token = self:_peek(0)
        args = args .. token.Lexeme
        self:_advance()
      end

      args = args:sub(1, -2)
      if self:_previous().TokenType ~= TokenType.RIGHT_PAREN then
        error('Unterminated call')
      end

      local newCall = AST.Call:new(identifier, args)
      return newCall
    end



    if self:_check(TokenType.EQUAL) then

      if self:_findVar(token.Lexeme) then
        --var assignment
        local varName = token.Lexeme
        self:_advance() --consume indentifier
        self:_advance() -- consume equal
        local finalValue = ""

        while self:_peek(0) ~= nil and self:_peek(0).TokenType ~= TokenType.LINE_BREAK do
          token = self:_peek(0)
          finalValue = finalValue .. token.Lexeme
          self:_advance()
        end
        self.line = self.line + 1
        
        local newvar = AST.VariableAssign:new(varName, finalValue)
        return newvar
      else
        -- var declaration
        local varName = token.Lexeme
        self:_advance() --consume indentifier
        self:_advance() -- consume equal
        local finalValue = ""

        while self:_peek(0) ~= nil and self:_peek(0).TokenType ~= TokenType.LINE_BREAK do
          token = self:_peek(0)
          finalValue = finalValue .. token.Lexeme
          self:_advance()
        end
        self.line = self.line + 1

        local newvar = AST.Variable:new(varName, finalValue)
        table.insert(self.variable_cache, varName)
        return newvar
      end
    end
  end

  

  if token.TokenType == TokenType.KEYWORD then

    if token.Lexeme == 'if' then
      self:_advance() --consume if

      local comparison = ""

      while self:_peek(0).TokenType ~= TokenType.COLON or self:_peek(0).TokenType ~= TokenType.LINE_BREAK do
        self:_advance()
        token = self:_peek(0)
        comparison = comparison .. token.Lexeme
      end

      if self:_peek(0).TokenType == TokenType.LINE_BREAK then
        error('Unterminated if statement')
      end

      local expectedIndents = self.lineindents[self.line + 1]
      if expectedIndents == 0 then
        error('cannot use 0 indents')
      end

      local codeBody = {}

      while self.lineindents[self.line] == expectedIndents do
        token = self:_peek(0)

        if token.TokenType == TokenType.LINE_BREAK then
          self.line = self.line + 1
        end

        self:_advance()
        local newpart = self:_parseNonWhitespace()
        if newpart ~= nil then
          table.insert(codeBody, newpart)
        end
      end
        

      
    elseif token.Lexeme == "def" then
      print 'ye'


      
    elseif token.Lexeme == 'return' then
      self:_advance() --consume return
      local finalValue = ""

      while self:_peek(0) ~= nil and self:_peek(0).TokenType ~= TokenType.LINE_BREAK do
        token = self:_peek(0)
        finalValue = finalValue .. token.Lexeme
        self:_advance()
      end
      self.line = self.line + 1

      local newvar = AST.Return:new(finalValue)
      return newvar
    end



    if token.Lexeme == 'class' then
      --class declaration
      local baseclass = nil
      self:_advance() --consume class
      local className = self:_peek(0).Lexeme
      self:_advance() --consume classname
      if self:_peek(0).TokenType == TokenType.LEFT_PAREN then
        self:_advance() --consume (
        local baseclass = ""
        while self:_peek(0).TokenType ~= TokenType.RIGHT_PAREN do
          token = self:_peek(0)
          baseclass = baseclass .. token.Lexeme
          self:_advance()
        end
        self:_advance() --consume )
        if self:_peek(0).TokenType == TokenType.COLON then
          self:_advance() --consume :
        else
          error('Error at line '..tostring(self.line) .." Expected :")
        end
      elseif self:_peek(0).TokenType == TokenType.COLON then
        self:_advance() --consume :
      else
        error('Error at line '..tostring(self.line) .." Expected :")
      end

      if self:_peek(0).TokenType == TokenType.LINE_BREAK then
        self.line = self.line + 1
        self:_advance() --consume \n
      end

      local expectedIndents = self.lineindents[self.line]

      local functionbody = {}

      for i=1, expectedIndents do
        self:_advance() -- consume spaces
      end

      while true do
        local statement = self:_parseNonWhitespace()

        if statement ~= nil then
          table.insert(functionbody, statement)
        end

        self:_advance()
        if self.lineindents[self.line] ~= expectedIndents then
          break
        end
      end

      local newclass = AST.Class:new(className, baseclass, functionbody)
      return newclass
      
    end
  end



  if token.TokenType == TokenType.LINE_BREAK then
    self.line = self.line + 1
  end
end

function Parser:_getLineIndents()
  local line = 1
  local indents = 0

  for _, token in pairs(self.tokens) do
    if token.TokenType == TokenType.LINE_BREAK then
      table.insert(self.lineindents, line, indents)
      line = line + 1
      indents = 0
    end
    if token.TokenType == TokenType.SPACE then
      indents = indents + 1
    end
  end
end


function Parser:parse()

  self.tokens = self:_rid_whitespace()
  self.isAtStartOfLine = true
  self:_getLineIndents()

  while not self:_isAtEnd() do
    local statement = self:_parseNonWhitespace()
    if statement ~= nil then
      self.program:add_statement(statement)
    end
    self:_advance()
  end

  
  self.program:add_statement('EOF')
  return self.program
end

return Parser
