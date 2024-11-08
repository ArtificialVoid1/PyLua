local token = {}
token.mt = {}

token.mt.__index = token

function token.mt.__tostring(self)
  local lexemeValue = self.Lexeme
  local literalValue = self.Literal
  if self.Lexeme == nil then
    lexemeValue = "nil"
  end
  if self.Literal == nil then
    literalValue = "nil"
  end

  if lexemeValue == "\n" then lexemeValue = '\\n'
  elseif lexemeValue == " " then lexemeValue = '_'
  end
  return self.TokenType .. " " .. lexemeValue .. " " .. literalValue .. " :" .. tostring(self.Line)
end

function token:new(TokenType, Lexeme, Literal, Line)
  Literal = Literal or nil
  self = setmetatable({
    ["TokenType"] = TokenType,
    ["Lexeme"] = tostring(Lexeme),
    ["Literal"] = Literal,
    ["Line"] = Line
  }, token.mt)
  return self
end

return token
