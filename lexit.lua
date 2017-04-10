--Thomas Marquez
--Assignment 3
--
--lexit module which builds on the lexer module provided by Professor Chappell

local lexit = {}

lexit.KEY = 1
lexit.VARID = 2
lexit.SUBID = 3
lexit.NUMLIT = 4
lexit.STRLIT = 5
lexit.OP = 6
lexit.PUNCT = 7
lexit.MAL = 8

-- Lexeme Category Names
-- Indices are above categories

lexit.catnames = {
    "Keyword",
    "VariableIdentifier",
    "SubroutineIdentifier",
    "NumericLiteral",
    "StringLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}

--the flag for the preferOp function that allows the caller to set a flag during lexing
local preferOpFlag = false

-- Kind-of-Character Functions

-- isLetter
-- Returns true if string c is a letter character, false otherwise.
local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end


-- isDigit
-- Returns true if string c is a digit character, false otherwise.
local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end


-- isWhitespace
-- Returns true if string c is a whitespace character, false otherwise.
local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" then
        return true
    else
        return false
    end
end

--isComment
--Returns true is string c is a comment, false otherwise
local function isComment(c)
    if c == "#" then
      return true
    else
      return false
    end
end



-- isIllegal
-- Returns true if string c is an illegal character, false otherwise.
local function isIllegal(c)
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif c >= " " and c <= "~" then
        return false
    elseif c == "_" then
        return false
    elseif isComment(c) then
        return false
    else
        return true
    end
end

function lexit.preferOp()
    preferOpFlag = true
end



-- The Lexer Itself

-- lex
-- Our lexer
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexer.lex(prog) do
function lexit.lex(prog)
    -- ***** Variables (like class data members) *****

    local pos       -- Index of next character in prog
                    -- INVARIANT: when getLexeme is called, pos is
                    --  EITHER the index of the first character of the
                    --  next lexeme OR len+1
    local state     -- Current state for our state machine
    local ch        -- Current character
    local lexstr    -- The lexeme, so far
    local category  -- Category of lexeme, set when state set to DONE
    local handlers  -- Dispatch table; value created later

    -- ***** States *****

    local DONE = 0
    local START = 1
    local LETTER = 2
    local DIGIT = 3
    local DIGDOT = 4
    local PLUS = 5
    local MINUS = 6
    local STAR = 7
    local DOT = 8
    local PERCENT = 9
    local VARIABLE = 10
    local AMPERSAND = 11
    local SUBROUTINE = 12
    local PARENT = 13
    local PIPE = 14
    local OPERATION = 15
    local EQUAL = 16
    local OPER_EQUAL = 17
    local ILLEGAL = 18
    local DBL_PARENT = 19

    -- ***** Character-Related Functions *****

    -- currChar
    -- Return the current character, at index pos in prog. Return value
    -- is a single-character string, or the empty string if pos is past
    -- the end.
    local function currChar()
        return prog:sub(pos, pos)
    end

    -- nextChar
    -- Return the next character, at index pos+1 in prog. Return value
    -- is a single-character string, or the empty string if pos+1 is
    -- past the end.
    local function nextChar()
        return prog:sub(pos+1, pos+1)
    end
    
    -- drop1
    -- Move pos to the next character.
    local function drop1()
        pos = pos+1
    end

    -- add1
    -- Add the current character to the lexeme, moving pos to the next
    -- character.
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end
  
    

    -- skipWhitespace
    -- Skip whitespace and comments, moving pos to the beginning of
    -- the next lexeme, or to prog:len()+1.
    -- Added to the function a means to skip comments
    local function skipWhitespace()
        while true do
            while isWhitespace(currChar()) do
                drop1()
            end

            if currChar() ~= "#" then  -- Comment?
                break
            end
            drop1()

            while true do
                if currChar() == "" then
                    return
                elseif currChar() == "\n" then
                  break
                end
                drop1()
            end
        end
    end

    -- ***** State-Handler Functions *****

    -- A function with a name like handle_XYZ is the handler function
    -- for state XYZ

    local function handle_DONE()
        io.write("ERROR: 'DONE' state should not be handled\n")
        assert(0)
    end

    --NOTE: some redundancy in the check for preferOpFlag
    --I was not sure why it was not testing correctly
    --I added an extra check in the handler to see
    --if that would miraculously solve the problem. 
    --No miracles tonight!
    --Update: The miracle happend in the form of a lowercase letter.
    --Redundancy fixed
    local function handle_START()
        if isIllegal(ch) then
            add1()
            state = DONE
            category = lexit.MAL
        elseif isLetter(ch) then
            add1()
            state = LETTER
        elseif isDigit(ch) then
            add1()
            state = DIGIT
        elseif ch == "+" then
            if not preferOpFlag then
              add1()
              state = PLUS
            else
              add1()
              state = DONE
              category = lexit.OP
            end
        elseif ch == "-" then
            if not preferOpFlag then
              add1()
              state = MINUS
            else
              add1()
              state = DONE
              category = lexit.OP
            end
        elseif ch == "*" then
            add1()
            state = STAR
        elseif ch == "." then
            add1()
            state = DOT
        elseif ch == "%" then
            if not preferOpFlag then
              add1()
              state = PERCENT
            else
              add1()
              state = DONE
              category = lexit.OP
            end
        elseif ch == "&" then
            add1()
            state = AMPERSAND
        elseif ch == "'" then 
            add1()
            state = PARENT
        elseif ch == "\"" then
            add1()
            state = DBL_PARENT
        elseif ch == "|" then
            add1()
            state = PIPE
        elseif ch == "/" or ch == "[" or ch == "]" or ch == ":" then
            add1()
            state = OPERATION
        elseif ch == "!" or ch == "<" or ch == ">" then
            add1()
            state = OPER_EQUAL
        elseif ch == "=" then
            add1()
            state = EQUAL
        elseif ch == "\\" then
            add1()
            state = ILLEGAL
        else
            add1()
            state = DONE
            category = lexit.PUNCT
        end
    end
    

    local function handle_LETTER()
        if isLetter(ch) then                   --or isDigit(ch) or ch == "_" 
            add1()
        else
            state = DONE
            if lexstr == "call" or lexstr == "cr"
              or lexstr == "else" or lexstr == "elseif" or lexstr == "end"
              or lexstr == "false" or lexstr == "if" or lexstr == "input" 
              or lexstr == "print" or lexstr == "set" or lexstr == "sub"
              or lexstr == "true" or lexstr == "while" then
                category = lexit.KEY
            else
              category = lexit.MAL
            end
        end
    end

    local function handle_DIGIT()
        if isDigit(ch) then
          add1()
        elseif ch == "e" or ch == "E" then
          if isDigit(nextChar()) then
            add1()
          elseif nextChar() == "+" then
            add1()
            add1()
          else
            state = DONE
            category = lexit.NUMLIT
          end
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end

    local function handle_DIGDOT()
        if isDigit(ch) then
            add1()
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end

    local function handle_PLUS()
        if isDigit(ch) then
            add1()
            state = DIGIT
        else
            state = DONE
            category = lexit.OP
        end
    end

    local function handle_MINUS()
        if isDigit(ch) then
            add1()
            state = DIGIT
        else
            state = DONE
            category = lexit.OP
        end
    end

    local function handle_STAR()  -- Handle * or / or =
          state = DONE
          category = lexit.OP
      
    end

    local function handle_DOT()
        state = DONE
        category = lexit.PUNCT
    end
    
    local function handle_PERCENT()
        if isLetter(ch) or ch == "_" then
            add1()
            state = VARIABLE
        else
          state = DONE
          category = lexit.OP
        end
    end
    
    local function handle_VARIABLE()
        if isLetter(ch) or isDigit(ch) or ch == "_" then
            add1()
            state = VARIABLE
        else
          state = DONE
          category = lexit.VARID
        end
    end
    
    local function handle_AMPERSAND()
        if isLetter(ch) or ch == "_" then
          add1()
          state = SUBROUTINE
        elseif ch == "&" then
          add1()
          state = DONE
          category = lexit.OP
        else
          state = DONE
          category = lexit.PUNCT
        end
    end
    
    
    local function handle_SUBROUTINE()
        if isLetter(ch) or isDigit(ch) or ch == "_" then
            add1()
            state = SUBROUTINE
        else
          state = DONE
          category = lexit.SUBID
        end
    end
    
    local function handle_PARENT()
        if ch == "'" then
          add1()
          state = DONE
          category = lexit.STRLIT
        elseif ch == "" then
          state = DONE
          category = lexit.MAL
        else
          add1()
            
        end
    end
        
    local function handle_DBL_PARENT()
        if ch == "\"" then
          add1()
          state = DONE
          category = lexit.STRLIT
        elseif ch == "" then
          state = DONE
          category = lexit.MAL
        else
          add1()
            
        end
        
    end
    local function handle_PIPE()
        if ch == "|" then
          add1()
          state = DONE
          category = lexit.OP
        else
          state = DONE
          category = lexit.PUNCT
        end
      end
      
    local function handle_OPERATION()
        state = DONE
        category = lexit.OP
    end
    
    local function handle_EQUAL()
        if ch == "=" then
          state = OPER_EQUAL
        else
          state = DONE
          category = lexit.PUNCT
        end
    end
    
    local function handle_OPER_EQUAL()
      if ch == "=" then
          add1()
      end
      state = DONE
      category = lexit.OP
    end
  
    local function handle_ILLEGAL()
      if ch == "\\" then
        add1()
        state = DONE
        category = lexit.PUNCT
      elseif ch ~= "" or ch ~= "\n" then
          add1()
      else
        state = DONE
        category = lexit.MAL
      end
    end
    

    -- ***** Table of State-Handler Functions *****

    handlers = {
        [DONE]=handle_DONE,
        [START]=handle_START,
        [LETTER]=handle_LETTER,
        [DIGIT]=handle_DIGIT,
        [DIGDOT]=handle_DIGDOT,
        [PLUS]=handle_PLUS,
        [MINUS]=handle_MINUS,
        [STAR]=handle_STAR,
        [DOT]=handle_DOT,
        [PERCENT]=handle_PERCENT,
        [VARIABLE]=handle_VARIABLE,
        [AMPERSAND]=handle_AMPERSAND,
        [SUBROUTINE]=handle_SUBROUTINE,
        [PARENT]=handle_PARENT,
        [PIPE]= handle_PIPE,
        [OPERATION]=handle_OPERATION,
        [EQUAL]=handle_EQUAL,
        [OPER_EQUAL]=handle_OPER_EQUAL,
        [ILLEGAL]=handle_ILLEGAL,
        [DBL_PARENT]=handle_DBL_PARENT,
    }

    -- ***** Iterator Function *****

    -- getLexeme
    -- Called each time through the for-in loop.
    -- Returns a pair: lexeme-string (string) and category (int), or
    -- nil, nil if no more lexemes.
    local function getLexeme(dummy1, dummy2)
        if pos > prog:len() then
            preferOpFlag = false
            return nil, nil
        end
        lexstr = ""
        state = START
        while state ~= DONE do
            ch = currChar()
            handlers[state]()
        end
        skipWhitespace()
        preferOpFlag = false
        return lexstr, category
    end

    -- ***** Body of Function lex *****

    -- Initialize & return the iterator function
    pos = 1
    skipWhitespace()
    return getLexeme, nil, nil
end

return lexit
