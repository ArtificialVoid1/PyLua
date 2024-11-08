return {
  --Single char tokens
  ['LEFT_PAREN'] = "LEFT_PAREN", -- (
  ['RIGHT_PAREN'] = "RIGHT_PAREN", -- )
  ['LEFT_BRACE'] = "LEFT_BRACE", -- {
  ['RIGHT_BRACE'] = "RIGHT_BRACE", -- }
  ['LEFT_BRACKET'] = "LEFT_BRACKET", -- [
  ['RIGHT_BRACKET'] = "RIGHT_BRACKET", -- ]
  ['COMMA'] = "COMMA", -- ,
  ['DOT'] = "DOT", -- .
  ['SEMICOLON'] = "SEMICOLON", -- ;
  ['COLON'] = "COLON", -- :
  
  ['MINUS'] = "MINUS", -- -
  ['PLUS'] = "PLUS", -- +
  ['STAR'] = "STAR", -- *
  ['SLASH'] = "SLASH", -- /
  ['SNAIL'] = "SNAIL", -- @
  ['INVERT'] = "INVERT", -- ~
  ['MOD'] = "MOD", -- %
  ['CAROT'] = "CAROT", -- ^
  ['BANG'] = "BANG", -- !
  ['PIPE'] = "PIPE", -- |
  ['AMPERSAND'] = "AMPERSAND", -- &

  --Two char tokens
  ['POW'] = 'POW', -- **
  ['SLASH_SLASH'] = "SLASH_SLASH", -- //

  --comparison tokens
  ['EQUAL'] = "EQUAL", -- =
  ['EQUAL_EQUAL'] = "EQUAL_EQUAL", -- ==
  ['GREATER'] = "GREATER", -- >
  ['GREATER_EQUAL'] = 'GREATER_EQUAL', -- >=
  ['LESS'] = "LESS", -- <
  ['LESS_EQUAL'] = "LESS_EQUAL", -- <=
  ['BANG_EQUAL'] = "BANG_EQUAL", -- !=

  --inplace operators
  ['PLUS_EQUAL'] = "PLUS_EQUAL", -- +=
  ['MINUS_EQUAL'] = "MINUS_EQUAL", -- -=
  ['STAR_EQUAL'] = "STAR_EQUAL", -- *=
  ['SLASH_EQUAL'] = "SLASH_EQUAL", -- /=
  ['SLASH_SLASH_EQUAL'] = "SLASH_SLASH_EQUAL", -- //=
  ['MOD_EQUAL'] = "MOD_EQUAL", -- %=
  ['POW_EQUAL'] = "POW_EQUAL", -- **=
  ['CAROT_EQUAL'] = "CAROT_EQUAL", -- ^=
  ['SNAIL_EQUAL'] = "SNAIL_EQUAL", -- @=
  ['PIPE_EQUAL'] = "PIPE_EQUAL", -- |=
  ['AMPERSAND_EQUAL'] = "AMPERSAND_EQUAL", -- &=


  --literal tokens
  ['NONE'] = "NONE", -- nil
  ['STRING'] = "STRING", -- "string"
  ['NUMBER'] = "NUMBER", -- 123
  ['IDENTIFIER'] = "IDENTIFIER", -- my_identifier
  ['KEYWORD'] = "KEYWORD",
  ['FALSE'] = 'FALSE',
  ['TRUE'] = 'TRUE',

  ['SPACE'] = "SPACE",
  ['LINE_BREAK'] = "LINE_BREAK",
  ["EOF"] = "EOF",
}
