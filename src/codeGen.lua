local functionlevel = 0

function genlua(statements)
  local code = ""

  
  for _, statement in pairs(statements) do
    print(statement)
    for i = 1,functionlevel do
      code = code .. '\t'
    end

    if statement.type == 'declaration' then
      code = code .. 'local ' .. statement.name .. ' = ' .. statement.value .. "\n"


    elseif statement.type == 'assignment' then
      code = code .. statement.name .. ' = ' .. statement.value .. "\n"


    elseif statement.type == 'call' then
      code = code .. statement.callee .. '(' .. statement.arguments .. ")\n"

    elseif statement.type == 'if' then
      code = code .. 'if ' .. statement.condition .. ' then\n'
      functionlevel = functionlevel + 1
      code = code .. genlua(statement.body)
      functionlevel = functionlevel - 1

      if statement.ELIFS ~= nil then
        for _, branch in pairs(statement.elseif_branches) do
          code = code .. 'elseif ' .. branch.condition .. ' then\n'
          functionlevel = functionlevel + 1
          code = code .. genlua(branch.body)
          functionlevel = functionlevel - 1
        end
      end

      if statement.ELSE ~= nil then
        code = code .. 'else\n'
        functionlevel = functionlevel + 1
        code = code .. genlua(statement.ELSE.body)
        functionlevel = functionlevel - 1
      end

      code = code .. 'end\n'
    end


    elseif statement.type == 'function' then
      code = code .. 'function ' .. statement.name .. '(' .. statement.parameters .. ')\n'
      functionlevel = functionlevel + 1
      local newcode = genlua(statement.body)
      code = code .. newcode .. 'end\n'
      functionlevel = functionlevel - 1


    elseif statement.type == 'return' then
      code = code .. 'return ' .. statement.value .. '\n'

    elseif statement == 'EOF' then
      break
    end
  end
  return code
end


return function(syntaxTree)
  local finalCode = genlua(syntaxTree.statements)
  print('\n\n\n\n')
  return finalCode
end
