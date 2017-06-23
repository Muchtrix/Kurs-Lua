function AI(mySymbol, board)
    local enemy = mySymbol == 'X' and 'O' or 'X'

    -- Uzupełnij do wygranej
    local line, pos = checkLine(mySymbol, board)
    if (line and pos) then
        if    (line <= 3) then return line, pos
        elseif(line <= 6) then return pos, line - 3
        elseif(line == 7) then return pos, pos
        elseif(line == 8) then return 4 - pos, pos
        end
    end

    -- Zablokuj przeciwnika
    local line, pos = checkLine(enemy, board)
    if (line and pos) then
        if    (line <= 3) then return line, pos
        elseif(line <= 6) then return pos, line - 3
        elseif(line == 7) then return pos, pos
        elseif(line == 8) then return 4 - pos, pos
        end
    end

    -- Zajmij środek
    if board[2][2] == ' ' then return 2, 2 end

    -- Zajmij bok
    if board[1][2] == ' ' then return 1, 2 end
    if board[3][2] == ' ' then return 3, 2 end
    if board[2][1] == ' ' then return 2, 1 end
    if board[2][3] == ' ' then return 2, 3 end

    -- Zajmij róg
    if board[1][1] == ' ' then return 1, 1 end
    if board[3][3] == ' ' then return 3, 3 end
    if board[1][3] == ' ' then return 1, 3 end
    if board[3][1] == ' ' then return 3, 1 end
end

function checkLine(symbol, board)
    local oxx = ' '..symbol..symbol
    local xox = symbol..' '..symbol
    local xxo = symbol..symbol..' '
    local lines = {
        board[1][1] .. board[1][2] .. board[1][3],
        board[2][1] .. board[2][2] .. board[2][3],
        board[3][1] .. board[3][2] .. board[3][3],
        board[1][1] .. board[2][1] .. board[3][1],
        board[1][2] .. board[2][2] .. board[3][2],
        board[1][3] .. board[2][3] .. board[3][3],
        board[1][1] .. board[2][2] .. board[3][3],
        board[3][1] .. board[2][2] .. board[1][3],
    }
    for i = 1, 8 do
        if lines[i] == oxx then return i, 1 end
        if lines[i] == xox then return i, 2 end
        if lines[i] == xxo then return i, 3 end
    end
    return nil, nil
end