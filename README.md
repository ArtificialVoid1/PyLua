# PyLua
Pylua is a transpiler written in lua that i am constantly updating

```lua
local pylua = require 'PyLua'

local luasource = pylua([[
print('Hello world!')
]])

load(luasource)()
```
