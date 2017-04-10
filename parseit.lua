-- Thomas Marquez
-- CSCE 331
-- Assignment 4
-- Parseit
-- The purpose of this program is to parse a simple programming language created
-- by Prof Chappel
-- This program uses the lexit program as well
-- 

local parseit = {}    -- declare parseit module

lexit = require "lexit"   -- import lexit module

STMT_LIST   = 1
CR_STMT     = 2
PRINT_STMT  = 3
INPUT_STMT  = 4
SET_STMT    = 5
SUB_STMT    = 6
CALL_STMT   = 7
IF_STMT     = 8
WHILE_STMT  = 9
BIN_OP      = 10
UN_OP       = 11
NUMLIT_VAL  = 12
STRLIT_VAL  = 13
BOOLLIT_VAL = 14
VARID_VAL   = 15
ARRAY_REF   = 16


-- Variables

-- For lexer iteration
local iter          -- Iterator returned by lexer.lex
local state         -- State for above iterator (maybe not used)
local lexer_out_s   -- Return value #1 from above iterator
local lexer_out_c   -- Return value #2 from above iterator

-- For current lexeme
local lexstr = ""   -- String form of current lexeme
local lexcat = 0    -- Category of current lexeme:
                    --  one of categories below, or 0 for past the end

-- matchString by Prof Chappel
-- Given string, see if current lexeme string form is equal to it. If
-- so, then advance to next lexeme & return true. If not, then do not
-- advance, return false.
-- Function init must be called before this function is called.
local function matchString(s)
    if lexstr == s then
        advance()
        return true
    else
        return false
    end
end


-- matchCat by Prof Chappel
-- Given lexeme category (integer), see if current lexeme category is
-- equal to it. If so, then advance to next lexeme & return true. If
-- not, then do not advance, return false.
-- Function init must be called before this function is called.
local function matchCat(c)
    if lexcat == c then
        advance()
        return true
    else
        return false
    end
end

function advance()
    -- Advance the iterator by Prof Chappel. lexit.preferOp added to the oringal code
    -- Advance also checks to see if lexit.preferOp is needed to be called by checking
    -- the lexeme
    lexer_out_s, lexer_out_c = iter(state, lexer_out_s)
    
    -- If we're not past the end, copy current lexeme into vars
    if lexer_out_s ~= nil then
        lexstr, lexcat = lexer_out_s, lexer_out_c
        --check to see if lexit.preferOp is needed
        if lexcat == 2 or lexcat == 4 or lexstr == "]" or lexstr == ")"
        or lexstr == "true" or lexstr == "false" then
            lexit.preferOp()
        end
        
    else
        lexstr, lexcat = "", 0
    end
    
end


-- init by Prof Chappel
-- Initial call. Sets input for parsing functions.
local function init(prog)
    iter, state, lexer_out_s = lexit.lex(prog)
    advance()
end


-- atEnd by Prof Chappel
-- Return true if pos has reached end of input.
-- Function init must be called before this function is called.
local function atEnd()
    return lexcat == 0
end

-- parse_program by Prof Chappel
-- Parsing function for nonterminal "program".
-- Function init must be called before this function is called.
function parseit.parse(program)
    local good, ast
    
    init(program)
  
    good, ast = parse_stmt_list()
    local done = atEnd()
    print(lexcat)
    return good, done, ast

end

-- parse_stmt_list by Prof Chappel
-- Parsing function for nonterminal "stmt_list".
-- Function init must be called before this function is called.
function parse_stmt_list()
    local good, ast, newast
    ast = { STMT_LIST }

    while true do
        if lexstr ~= "cr"
          and lexstr ~= "print"
          and lexstr ~= "input"
          and lexstr ~= "set"
          and lexstr ~= "sub"
          and lexstr ~= "call"
          and lexstr ~= "if"
          and lexstr ~= "while" then
            return true, ast
        end

        good, newast = parse_statement()
        if not good then
            return false, nil
        end
        table.insert(ast, newast)

    end
end


-- parse_statement
-- Parsing function for nonterminal "statement".
-- Function init must be called before this function is called.
function parse_statement()
    local good, ast1, ast2, savelex
    
    if matchString("cr") then
        return true, { CR_STMT }

    elseif matchString("print") then
        savelex = lexstr
        if matchCat(lexit.STRLIT) then
            return true, { PRINT_STMT, { STRLIT_VAL, savelex } }
        end

        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end
        return true, { PRINT_STMT, ast1 }

    elseif matchString("input") then
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end
        return true, { INPUT_STMT, ast1 }

    elseif matchString("set") then
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end
        if not matchString(":") then
            return false, nil
        end
        good, ast2 = parse_expr()
        if not good then
            return false, nil
        end
        return true, { SET_STMT, ast1, ast2 }

    elseif matchString("sub") then
        savelex = lexstr
        if matchCat(lexit.SUBID) then
            good, ast1 = parse_stmt_list()
            if not good then
                return false, nil
            end
            if not matchString("end") then
                return false, nil
            end
        return true, { SUB_STMT, savelex, ast1 }
        end  
        return false, nil
        
    elseif matchString("call") then
      savelex = lexstr
      if matchCat(lexit.SUBID) then
          return true, { CALL_STMT, savelex }
      end
      return false, nil
    
    -- I could not get multiple elseif statments to work
    -- "count", "elseIfAstEx", and "elseIfAstSt" were valuables I used to 
    -- try to remedy the problem
    -- Had no success. 
  elseif matchString("if") then
        local good, ast, ast1, ast2, ast3, ast4
        local count = 1
        local elseIfAstEx = {}
        local elseIfAstSt = {}
        good, ast = parse_expr()
        
        if not good then
            return false, nil
        end
        
        good, ast1 = parse_stmt_list()
        if not good then
            return false, nil
        end
        -- Loop if for elseif statements. I could not figure out how to implement mutliple esleifs
            while true do
                if not matchString("elseif") then
                      break
                end
                good, ast2 = parse_expr()
                if not good then
                    return false, nil
                end
                good, ast3 = parse_stmt_list()
                if not good then
                    return false, nil
                end
            end
        
        if matchString("else") then
            good, ast4 = parse_stmt_list()
            if not good then
                return false, nil
            end
            
            if not matchString("end") then
                return false, nil
            end
            
            if ast2 ~= nil and ast3 ~= nil then
                  --return true, { IF_STMT, ast, ast1, elseIfAstEx, elseIfAstSt, ast4 }
                return true, { IF_STMT, ast, ast1, ast2, ast3, ast4 }
            end
            return true, { IF_STMT, ast, ast1, ast4 }
        end
        
        if not matchString("end") then
            return false, nil
        end
      
        return true, { IF_STMT,  ast, ast1 }
         
    elseif matchString("while") then
          good, ast1 = parse_expr()
          
          if not good then
              return false, nil
          end
          
          good, ast2 = parse_stmt_list()
          
          if not good then
              return false, nil
          end
          
          if not matchString("end") then
              return false, nil
          end
          
          return true, { WHILE_STMT, ast1, ast2 }
    end
    return false, nil
end

--function to parse the expression
function parse_expr()
    local good, ast, saveop, newast
    
    good, ast = parse_comp_expr()
    if not good then
        return false, nil
    end

    while true do
        saveop = lexstr
        if not matchString("&&") and not matchString("||") then
          break
        end
        
        good, newast = parse_comp_expr()
        if not good then
            return false, nil
        end
        
        ast = { { BIN_OP, saveop }, ast, newast }  
    end
    return true, ast
end

--function to parse the comparison-expression 
function parse_comp_expr()
      local good, ast, saveop, ast1
      saveop = lexstr
      if matchString("!") then
          good, ast = parse_comp_expr()
          
          if not good then
                return false, nil
          end
          ast = { { UN_OP, saveop }, ast }
          return true, ast
      end
      
      good, ast = parse_arith_expr()
      if not good then
        return false, nil
      end

      while true do
          saveop = lexstr
          if not matchString("==") and not matchString("!=") and not matchString("<") and not matchString("<=") and not matchString(">")
          and not matchString(">=") then
              break
          end
          
          good, ast1 = parse_arith_expr()
          if not good then
              return false, nil
          end
          
          ast = { { BIN_OP, saveop }, ast, ast1 }
          
      end
      
      return true, ast
end

-- function to parse the arithmetic expression. borrowed from rdparser4
function parse_arith_expr()
    local good, ast, saveop, newast
    
    good, ast = parse_term()
    if not good then
        return false, nil
    end
    
    while true do
        saveop = lexstr
        if not matchString("+") and not matchString("-") then
            break
        end

        good, newast = parse_term()
        if not good then
            return false, nil
        end

        ast = { { BIN_OP, saveop }, ast, newast }
    end

    return true, ast

end

-- function to parse the term
function parse_term()
  local good, ast, saveop, newast

    good, ast = parse_factor()
    if not good then
        return false, nil
    end

    while true do
        saveop = lexstr
        if not matchString("*") and not matchString("/") and not matchString("%") then
            break
        end

        good, newast = parse_factor()
        if not good then
            return false, nil
        end

        ast = { { BIN_OP, saveop }, ast, newast }
    end
    return true, ast
end

-- function to parse the l-value
function parse_lvalue()
    local good, ast, savelex
    savelex = lexstr
    if matchCat(lexit.VARID) then
        if matchString("[") then
            good, ast = parse_expr()
            if not good then
                return false, nil
            end
            if not matchString("]") then
                return false, nil
            end
            ast = { ARRAY_REF, { VARID_VAL, savelex }, ast }
            return true, ast
        end
    ast = { VARID_VAL, savelex }
    return true, { VARID_VAL, savelex }
    end
  return false, nil
end

-- function to parse the factor
function parse_factor()
  local saveop, ast, good, savelex
  saveop = lexstr
  
    -- for a unary operator
    if  matchString("+") or matchString("-") then
        good, ast = parse_factor()
        
        if not good then
            return false, nil
        end
        
        ast = { { UN_OP, saveop}, ast } 
        return true, ast
    --else
        --return false, nil
    end
    
    -- for parenthesis
    if matchString("(") then
        good, ast = parse_expr()
        if not good then
            return false, nil
        end
        if matchString(")") then
            return true, ast
        end
        return false, nil
    end
    
    -- for true | false
    savebool = lexstr
    if matchString("true") or matchString("false") then
        ast = { BOOLLIT_VAL, savebool }
        return true, { BOOLLIT_VAL, savebool }
    end
    
    -- for NUMLIT
    savelex = lexstr
    if matchCat(lexit.NUMLIT) then
        
        ast = { NUMLIT_VAL, savelex }
        return true, { NUMLIT_VAL, savelex }
    end
    
    -- for ivalue
    good, ast = parse_lvalue()
    if not good then
        return false, nil
    end
  
  return true, ast
    
end



return parseit
