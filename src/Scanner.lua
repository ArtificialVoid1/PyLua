local TokenType = require "src.TokenType"
local Token = require "src.Token"


---------- Constructor ----------
local Scanner = {}
Scanner.__index = Scanner

function Scanner:new(source)
  self = setmetatable({
      ["source"] = source,
      ["tokens"] = {},

      ['start'] = 0,
      ['current'] = 0,
      ['line'] = 1,

      ['keywords'] = {
        ['def'] = 'def',
        ['return'] = 'return',
        ['class'] = 'class',
        ['if'] = 'if',
        ['else'] = 'else',
        ['elif'] = 'elif',
        ['for'] = 'for',
        ['while'] = 'while',
        ['continue'] = 'continue',
        ['break'] = 'break',
        ['in'] = 'in',
        ['and'] = 'and',
        ['or'] = 'or',
        ['not'] = 'not',
        ['is'] = 'is',
      }
  }, Scanner)
  return self
end

------------- Helper functions ----------------

local function isAlpha(char) --return boolean if char is Alpha
  return char:match("%a") ~= nil or char == '_'
end

local function isAlphaNumeric(char)
  return isAlpha(char) or (tonumber(char) ~= nil)
end

function Scanner:_isAtEnd()
  return self.current >= #self.source
end

function Scanner:_advance()
  self.current = self.current + 1
  return self.source:sub(self.current, self.current)
end

function Scanner:_addToken(tokenType, literal)
  literal = literal or nil
  local text = self.source:sub(self.start + 1, self.current)
  table.insert(self.tokens, #self.tokens + 1, Token:new(tokenType, text, literal, self.line))
end

function Scanner:_peek(amount) --1 gets the next character, 2 gets the character after next character, etc...
  amount = amount or 1
  if self:_isAtEnd() then return '\n' end
  return self.source:sub(self.current + amount, self.current + amount)
end

function Scanner:match(expected_char, ...)
  if self:_peek() == expected_char then
    if ... then
      for i, char_expected_new in ipairs({...}) do
        if self:_peek(i + 1) ~= char_expected_new then
          return false end
        return true end
    else return true end
  end
end

function Scanner:_number()
  while tonumber(self:_peek()) ~= nil do
    self:_advance()
  end

  if self:_peek() == '.' and tonumber(self:_peek(2)) ~= nil then
    self:_advance()
  end

  while tonumber(self:_peek()) ~= nil do
    self:_advance()
  end

  self:_addToken(TokenType.NUMBER, tonumber(self.source:sub(self.start + 1, self.current)))
end

function Scanner:_string()
  while (self:_peek() ~= "'" and self:_peek() ~= '"') and not self:_isAtEnd() do
    if self:_peek() == '\n' then
      self.line = self.line + 1
    end
    self:_advance()
  end

  self:_advance()

  -- Trim the surrounding quotes.
  local value = self.source:sub(self.start + 2, self.current - 1)
  self:_addToken(TokenType.STRING, value)
end

function Scanner:_identifier()
  while isAlphaNumeric(self:_peek()) do
    self:_advance()
  end

  if self.source:sub(self.start + 1, self.current) == 'True' then
    self:_addToken(TokenType.TRUE)
  elseif self.source:sub(self.start + 1, self.current) == 'False' then
    self:_addToken(TokenType.FALSE)
  elseif self.source:sub(self.start + 1, self.current) == 'None' then
    self:_addToken(TokenType.NONE)
  elseif self.keywords[self.source:sub(self.start + 1, self.current)] then
    self:_addToken(TokenType.KEYWORD)
  else
    self:_addToken(TokenType.IDENTIFIER)
  end
end

------------- Scanner Functions ----------------

function Scanner:_scanToken()
  local char = self:_advance()

  if char == " " then self:_addToken(TokenType.SPACE)
  elseif char == '(' then self:_addToken(TokenType.LEFT_PAREN)
  elseif char == ')' then self:_addToken(TokenType.RIGHT_PAREN)
  elseif char == '{' then self:_addToken(TokenType.LEFT_BRACE)
  elseif char == '}' then self:_addToken(TokenType.RIGHT_BRACE)
  elseif char == '[' then self:_addToken(TokenType.LEFT_BRACKET)
  elseif char == ']' then self:_addToken(TokenType.RIGHT_BRACKET)
  elseif char == ',' then self:_addToken(TokenType.COMMA)
  elseif char == '.' then self:_addToken(TokenType.DOT)
  elseif char == ':' then self:_addToken(TokenType.COLON)
  elseif char == '~' then self:_addToken(TokenType.INVERT)

  elseif char == '\n' then
    self:_addToken(TokenType.LINE_BREAK)
    self.line = self.line + 1

  elseif char == '"' or char == "'" then
    self:_string()

  elseif char == '=' then
    if self:match('=') then 
    self:_advance()
    self:_addToken(TokenType.EQUAL_EQUAL)
    else self:_addToken(TokenType.EQUAL) end

  elseif char == '<' then
    if self:match('=') then 
    self:_advance()
    self:_addToken(TokenType.LESS_EQUAL)
    else self:_addToken(TokenType.LESS) end

  elseif char == '>' then
    if self:match('=') then 
    self:_advance()
    self:_addToken(TokenType.GREATER_EQUAL)
    else self:_addToken(TokenType.GREATER) end

  elseif char == '!' then
    if self:match('=') then 
    self:_advance()
    self:_addToken(TokenType.BANG_EQUAL)
    else self:_addToken(TokenType.BANG) end

  --Operators
  elseif char == '+' then
    if self:match('=') then 
      self:_advance()
      self:_addToken(TokenType.PLUS_EQUAL)
    else self:_addToken(TokenType.PLUS) end

  elseif char == '-' then
    if self:match('=') then
      self:_advance()
      self:_addToken(TokenType.MINUS_EQUAL)
    else self:_addToken(TokenType.MINUS) end

  elseif char == '*' then
    if self:match('*') then
      if self:match('*','=') then
        self:_advance()
        self:_advance()
        self:_addToken(TokenType.POW_EQUAL)
      else
        self:_advance()
        self:_addToken(TokenType.POW)
      end
    else
      if self:match('=') then 
        self:_advance()
        self:_addToken(TokenType.STAR_EQUAL)
      else self:_addToken(TokenType.STAR) end
    end

  elseif char == '/' then
    if self:match('/') then
      if self:match('/','=') then
        self:_advance()
        self:_advance()
        self:_addToken(TokenType.SLASH_SLASH_EQUAL)
      else 
        self:_advance()
        self:_addToken(TokenType.SLASH_SLASH) end
   else
      if self:match('=') then 
        self:_advance()
        self:_addToken(TokenType.SLASH_EQUAL)
      else self:_addToken(TokenType.SLASH) end
    end

  elseif char == '@' then
    if self:match('=') then
      self:_advance()
      self:_addToken(TokenType.SNAIL_EQUAL)
    else self:_addToken(TokenType.SNAIL) end
  elseif char == '%' then
    if self:match('=') then
      self:_advance()
      self:_addToken(TokenType.MOD_EQUAL)
    else self:_addToken(TokenType.MOD) end
  elseif char == '^' then
    if self:match('=') then
      self:_advance()
      self:_addToken(TokenType.CAROT_EQUAL)
    else self:_addToken(TokenType.CAROT) end
  elseif char == '|' then
    if self:match('=') then
      self:_advance()
      self:_addToken(TokenType.PIPE_EQUAL)
    else self:_addToken(TokenType.PIPE) end
  elseif char == '&' then
    if self:match('=') then
      self:_advance()
      self:_addToken(TokenType.AMPERSAND_EQUAL)
    else self:_addToken(TokenType.AMPERSAND) end

  elseif char == '#' then 
    while (self:_peek() ~= '\n') and not self:_isAtEnd() do
      self:_advance()
    end
  else
    if tonumber(char) then
      self:_number()
    elseif isAlpha(char) then
      self:_identifier()
    else
      error('Error at line '..tostring(self.line)..": Unexpected Character: "..char)
    end
  end
end

function Scanner:scanTokens()
  self.source = self.source:gsub("  ", "  ")
  self.source = self.source:gsub(';', '\n')

  table.insert(self.tokens, #self.tokens + 1, Token:new(TokenType.LINE_BREAK, nil, nil, self.line))
  while not self:_isAtEnd() do
    self.start = self.current
    self:_scanToken()
  end

  table.insert(self.tokens, #self.tokens + 1, Token:new(TokenType.LINE_BREAK, nil, nil, self.line))
  table.insert(self.tokens, #self.tokens + 1, Token:new(TokenType.LINE_BREAK, nil, nil, self.line))
  table.insert(self.tokens, #self.tokens + 1, Token:new(TokenType.EOF, nil, nil, self.line))
  return self.tokens
end




return Scanner
