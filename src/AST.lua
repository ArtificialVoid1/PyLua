local AST = {}

----------- PROGRAM STRUCT -------------

AST.program = {}
AST.program.__index = AST.program

function AST.program:new()
  self = setmetatable({
      ['statements'] = {},
  }, AST.program)
  return self
end

function AST.program:add_statement(statement)
  table.insert(self.statements, statement)
end

-----------Expression Nodes-----------------

AST.Expression = {}
AST.Expression.__index = AST.Expression

AST.Binary = {}
AST.Binary.__index = AST.Binary

function AST.Binary:new(left, operator, right)
  self = setmetatable({
      ['left'] = left,
      ['operator'] = operator,
      ['right'] = right,
  }, AST.Binary)
  return self
end

function AST.Binary:__tostring()
  return tostring(self.left) .. " " .. self.operator.lexeme .. " " .. tostring(self.right)
end

---------------------------------------

AST.Unary = {}
AST.Unary.__index = AST.Unary

function AST.Unary:new(operator, right)
  self = setmetatable({
      ['operator'] = operator,
      ['right'] = right,
  }, AST.Unary)
  return self
end

function AST.Unary:__tostring()
  return self.operator.lexeme .. " " .. tostring(self.right)
end

----------------------------------------

AST.Grouping = {}
AST.Grouping.__index = AST.Grouping

function AST.Grouping:new(expression)
  self = setmetatable({
      ['expression'] = expression,
    }, AST.Grouping)
  return self
end

function AST.Grouping:__tostring()
  return '(' .. tostring(self.expression) .. ')'
end

---------------------------------------

AST.Literal = {}
AST.Literal.__index = AST.Literal

function AST.Literal:new(value)
  self = setmetatable({
      ['value'] = value,
      ['type'] = 'literal'
    }, AST.Literal)
  return self
end

function AST.Literal:__tostring()
  if self.value == nil then
    return "nil"
  elseif self.value == true then
    return 'true'
  elseif self.value == false then
    return 'false'
  else
    return tostring(self.value)
  end
end



----------- Variables -----------------

AST.Variable = {}
AST.Variable.__index = AST.Variable

function AST.Variable:new(name, value)
  self = setmetatable({
      ['name'] = name,
      ['value'] = value,
      ['type'] = 'declaration'
    }, AST.Variable)
  return self
end

function AST.Variable:__tostring()
  return self.name .. ": " .. self.value
end
---------------------------------------

AST.VariableAssign = {}
AST.VariableAssign.__index = AST.VariableAssign

function AST.VariableAssign:new(name, value)
  self = setmetatable({
      ['name'] = name,
      ['value'] = value,
      ['type'] = 'assignment'
    }, AST.VariableAssign)
  return self
end

function AST.VariableAssign:__tostring()
  return self.name .. " updated to: " .. self.value
end

--------------------------------------

AST.Return = {}
AST.Return.__index = AST.Return

function AST.Return:new(value)
  self = setmetatable({
      ['value'] = value,
      ['type'] = 'return'
    }, AST.Return)
  return self
end

function AST.Return:__tostring()
  return 'RETURN: ' .. self.value
end

---------------------------------------

AST.Function = {}
AST.Function.__index = AST.Function

function AST.Function:new(name, parameters, body)
  self = setmetatable({
      ['name'] = name,
      ['parameters'] = parameters,
      ['body'] = body,
      ['type'] = 'function'
    }, AST.Function)
  return self
end

function AST.Function:__tostring()
  local fin = 'FUNCTION: '..self.name..' (' .. self.parameters .. ') {'
  for _, statement in pairs(self.body) do
    fin = fin .. '\n  ' .. tostring(statement)
  end
  fin = fin .. '\n}'
  return fin
end


----------------------------------------

AST.Call = {}
AST.Call.__index = AST.Call

function AST.Call:new(callee, arguments)
  self = setmetatable({
      ['callee'] = callee,
      ['arguments'] = arguments,
      ['type'] = 'call'
    }, AST.Call)
  return self
end

function AST.Call:__tostring()
  return 'CALL: ' .. self.callee.. ' ' .. self.arguments
end

----------------------------------------

AST.Class = {}
AST.Class.__index = AST.Class

function AST.Class:new(name, superclass, methods)
  self = setmetatable({
      ['name'] = name,
      ['superclass'] = superclass,
      ['body'] = methods,
      ['type'] = 'class'
    }, AST.Class)
  return self
end

function AST.Class:__tostring()
  local fin = ""
  if self.superclass == nil then
    fin = 'CLASS: ' .. self.name .. ' {'
  else
    fin = 'CLASS: ' .. self.name .. ' INHERITS ' .. self.superclass .. ' {'
  end

  for _, method in pairs(self.body) do
    fin = fin .. '\n  ' .. tostring(method)
  end

  fin = fin .. '\n}'
  return fin
end

----------- IF STUFF ------------------

AST.IF = {}
AST.IF.__index = AST.IF
function AST.IF:new(condition, body, ELSE_Branch, ELIF_Branches)
  ELSE_Branch = ELSE_Branch or nil
  ELIF_Branches = ELIF_Branches or nil
  
  self = setmetatable({
      ['condition'] = condition,
      ['body'] = body,
      ['ELIFS'] = ELIF_Branches,
      ['ELSE'] = ELSE_Branch,
      ['type'] = 'if',
    }, AST.IF)
  return self
end

AST.ELIF = {}
AST.ELIF.__index = AST.ELIF

function AST.ELIF:new(condition, body)
  
  self = setmetatable({
      ['condition'] = condition,
      ['body'] = body,
      ['type'] = 'elif',
    }, AST.ELIF)
  return self
end

AST.ELSE = {}
AST.ELSE.__index = AST.ELSE

function AST.ELSE:new(body)
  self = setmetatable({
      ['body'] = body,
      ['type'] = 'else',
    }, AST.ELSE)
  return self
end


----------------------------------------
return AST


