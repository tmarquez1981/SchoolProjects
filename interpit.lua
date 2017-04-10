-- Thomas Marquez
-- 
-- interpit.lua  INCOMPLETE
-- VERSION 2
-- Glenn G. Chappell
-- 27 Mar 2017
-- Modified in class 27 Mar 2017
--
-- For CS F331 / CSCE A331 Spring 2017
-- Interpret AST from parseit.parse
-- For Assignment 6, Exercise B


-- *********************************************************************
-- * To run a Kanchil program, use kanchil.lua (which uses this file). *
-- *********************************************************************


local interpit = {}  -- Our module


-- ***** Variables *****


-- Symbolic Constants for AST

local STMT_LIST   = 1
local CR_STMT     = 2
local PRINT_STMT  = 3
local INPUT_STMT  = 4
local SET_STMT    = 5
local SUB_STMT    = 6
local CALL_STMT   = 7
local IF_STMT     = 8
local WHILE_STMT  = 9
local BIN_OP      = 10
local UN_OP       = 11
local NUMLIT_VAL  = 12
local STRLIT_VAL  = 13
local BOOLLIT_VAL = 14
local VARID_VAL   = 15
local ARRAY_REF   = 16


-- ***** Utility Functions *****


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return 0+s end)

    -- Return integer value, or 0 on error.
    if success then
        return numToInt(value)
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
    return ""..n
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    if b then
        return 1
    else
        return 0
    end
end



-- ***** Primary Function for Client Code *****


-- interp
-- Interpreter, given AST returned by parseit.parse.
-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding values of Zebu integer variables
--             Value of simple variable xyz is in state.s["xyz"]
--             Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             outcall(str) outputs str with no added newline
--             To print a newline, do outcall("\n")
-- Return Value:
--   state updated with changed variable values
function interpit.interp(ast, state, incall, outcall)
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.

    local interp_stmt_list
    local interp_stmt

    function interp_stmt_list(ast)  -- Already declared local
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end

    function interp_stmt(ast)
        local name, body, str

        if ast[1] == CR_STMT then
            outcall("\n")
            
        elseif ast[1] == PRINT_STMT then
            if ast[2][1] == STRLIT_VAL then
                str = ast[2][2]
                outcall(str:sub(2,str:len()-1))
            --if PRINT_STMT prints an expression
            else
                body = ast[2]
                str = evaluate(body)
                outcall(str)
            end
            
        --if ast is INPUT_STMT
        -- create a new ast and execute
        elseif ast[1] == INPUT_STMT then
            str = incall()
            str = strToNum(str)
            body = {SET_STMT, ast[2], {NUMLIT_VAL, str}}
            execute(body)
            
        --sets the variable
        elseif ast[1] == SET_STMT then
            --body = ast[2]
            execute(ast)
            
        elseif ast[1] == SUB_STMT then
            name = ast[2]
            body = ast[3]
            state.s[name] = body
            
        elseif ast[1] == CALL_STMT then
            name = ast[2]
            body = state.s[name]
            if body == nil then
                body = { STMT_LIST }  -- Default AST
            end
            interp_stmt_list(body)
            
        elseif ast[1] == IF_STMT then
            evaluate(ast)
            
        elseif ast[1] == WHILE_STMT then
            evaluate(ast)
        else
        end
    end
    
    -- function evaluate evaluates th  ast and returns a number resulting from the evaluation
    function evaluate(ast)
      local name, body, str, bin_op
      -- if ast is an if statement
      if ast[1] == 8 then
        body = ast[2]
        if strToNum(evaluate(body)) ~= 0 then
          body = ast[3]
          interp_stmt_list(body)
        elseif ast[4] ~= nil then
          body = ast[4]
          interp_stmt_list(body)
        end
        
      --if ast is a while statement
      --stays in while loop while the expression is true
      elseif ast[1] == 9 then
        while_body = ast[2]
        while strToNum(evaluate(while_body)) ~= 0 do
          body = ast[3]
          interp_stmt_list(body)
        end
      
      --if expression is a NUM_LIT(12), then just return number
    elseif ast[1] == 12 then
          str = ast[2]
          return str
      
      -- if ast is a BOOLIt_VAL
      elseif ast[1] == 14 then
        str = ast[2]
        if str == "true" then
          return numToStr(1)
        else 
          return numToStr(0)
        end
        
      --else, expression is a VAR_ID(15), convert number to string and return...i think? Have to work on set variables first
      elseif ast[1] == 15 then
        name = ast[2]
        if state.v[name] == nil then
          return numToStr(0)
        end
        value = numToStr(state.v[name])
        return value
        
      --else if ast is an ARRAY_REf
      --return value at the index
      elseif ast[1] == 16 then
        name = ast[2][2]
        index = ast[3][2]
        index = strToNum(index)
        if state.a[name] == nil then
          return numToStr(0)
        end
        value = numToStr(state.a[name][index])
        return value
      
      --if expression is a BIN_OP
      elseif ast[1][1] == 10 then
        bin_op = ast[1][2]
        -- if bin_op is a +, then add the ast's
        if bin_op == "+" then
          eval_num = numToInt((strToNum(evaluate(ast[2])) + strToNum(evaluate(ast[3]))))
          return numToStr(eval_num)
          
        -- if bin_op is a -, then subtract the ast's
        elseif bin_op == "-" then
          eval_num = numToInt((strToNum(evaluate(ast[2])) - strToNum(evaluate(ast[3]))))
          return numToStr(eval_num)
          
        -- if bin_op is a *, then multiply the ast's
        elseif bin_op == "*" then
          eval_num = numToInt((strToNum(evaluate(ast[2])) * strToNum(evaluate(ast[3]))))
          return numToStr(eval_num)
          
        -- if bin_op is a /, then divide the ast's
        elseif bin_op == "/" then
          if strToNum(evaluate(ast[3])) == 0 then
              return numToStr(0)
          else
            eval_num = numToInt((strToNum(evaluate(ast[2])) / strToNum(evaluate(ast[3]))))
            return numToStr(eval_num)
          end
          
        elseif bin_op == "%" then
          if strToNum(evaluate(ast[3])) == 0 then
            return numToStr(0)
          else
            return numToStr(strToNum(evaluate(ast[2])) % strToNum(evaluate(ast[3])))
          end
          
        --various binary operators are handled
        --with the following 
        elseif bin_op == "<" then
          eval_num = (evaluate(ast[2]) < evaluate(ast[3]))
          return numToStr(boolToInt(eval_num))
          
        elseif bin_op == "<=" then
          eval_num = (evaluate(ast[2]) <= evaluate(ast[3]))
          return numToStr(boolToInt(eval_num))
          
        elseif bin_op == ">" then
          eval_num = (evaluate(ast[2]) > evaluate(ast[3]))
          return numToStr(boolToInt(eval_num))
          
        elseif bin_op == ">=" then
          eval_num = (evaluate(ast[2]) >= evaluate(ast[3]))
          return numToStr(boolToInt(eval_num))
          
        elseif bin_op == "!=" then
          eval_num = (evaluate(ast[2]) ~= evaluate(ast[3]))
          return numToStr(boolToInt(eval_num))
          
        elseif bin_op == "==" then
          eval_num = (evaluate(ast[2]) == evaluate(ast[3]))
          return numToStr(boolToInt(eval_num))
          
        elseif bin_op == "&&" then
          if (evaluate(ast[2]) == evaluate(ast[3])) then
            if strToNum(evaluate(ast[2])) == 0 and strToNum(evaluate(ast[3])) == 0 then
              return numToStr(0)
            end
            return numToStr(1)
          else
            return numToStr(0)
          end
          
        elseif bin_op == "||" then
          if strToNum(evaluate(ast[2])) ~= 0 or strToNum(evaluate(ast[3])) ~= 0 then
            return numToStr(1)
          else
            return numToStr(0)
          end
            
          
        end
        
      -- if ast is a UN_OP
      elseif ast[1][1] == 11 then
          if ast[1][2] == "-" then
            eval_num = evaluate(ast[2])
            eval_num = strToNum(eval_num)
            eval_num = eval_num * -1
            return numToStr(eval_num)
            
          elseif ast[1][2] == "+" then
            eval_num = evaluate(ast[2])
            --eval_num = strToNum(eval_num)
            return eval_num
            
          elseif ast[1][2] == "!" then
            eval_num = evaluate(ast[2])
            eval_num = strToNum(eval_num)
            if eval_num == 0 then
              return numToStr(1)
            else
              return numToStr(0)
            end
            
          end
          
        
      end
      
    
  end
    -- function execute executes the ast and sets at state
    function execute(ast)
      local name, body, str, value, index
      
      --if ast[1] is a SET_STMT--may have to change this
      if ast[1] == 5 then
        --if ast[2][1] is a VARID_VAL--may have to change this too
        --set state
        if ast[2][1] == 15 then
          name = ast[2][2]
          body = ast[3]
          
          if body == nil then
            state.v[name] = 0
            
          else
            value = evaluate(body)
            value = strToNum(value)
            state.v[name] = value
          end
          
        -- executes an ARRAY_REF
        -- i couldn't quite figure out how to fully implement this
        -- it breaks after more than one index is entered
        elseif ast[2][1] == 16 then
          name = ast[2][2][2]
          index = ast[2][3][2]
          index = strToNum(index)
          body = ast[3]
          if index == nil then
            state.a[name] = {0}
            
          else
            if body == nil then
              state.a[name] = {index}
              state.a[name][index] = 0
            else
              value = evaluate(body)
              value = strToNum(value)
              array = {}
              array[index] = value
              --state.a[name] = {index}
              --state.a[name][index] = value
              state.a[name] = array
              
            end
          end
        end
        
      end
      
    end
    
    

    -- Body of function interp
    interp_stmt_list(ast)
    return state
end


-- ***** Module Export *****


return interpit

