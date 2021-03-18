%getHumanPieceSelect(+GameState, -PieceRow, -PieceColumn)
getHumanPieceSelect([Player|Board], PieceRow, PieceColumn) :-
	format('Player ~w, choose a piece you want to move:~n', [Player]),
	readRow(Row),
	readColumn(Column),
	% command -> response 
	validateRow(Row, ValidatedRow),
	validateColumn(Column, ValidatedColumn),
	% row & column == true - 0 -> send response (valid or not) -> tell next player
	validatePieceSelect([Player|Board], ValidatedRow, ValidatedColumn, PieceRow, PieceColumn).

%readRow(-Row)
readRow(Row) :-
    write('    Row: '),
    read(Row), nl.

%readColumn(-Column)
readColumn(Column) :-
    write('    Column: '),
    read(Column), nl.

%validateRow(+Input, -ConfirmInput)
validateRow(Input, ConfirmInput) :-
	number(Input),
    Input >= 0,
	Input =< 9,
	ConfirmInput is Input;
    write('    [ERROR]: The given row is invalid! Has to be between 0 and 9.\n\n'),
    readRow(NewInput),
    validateRow(NewInput, ConfirmInput).

%validateColumn(+Input, -ConfirmInput)
validateColumn(Input, ConfirmInput) :-
	number(Input),
    Input >= 0,
	Input =< 9,
	ConfirmInput is Input;
    write('    [ERROR]: The given column is invalid! Has to be between 0 and 9.\n\n'),
    readColumn(NewInput),
    validateColumn(NewInput, ConfirmInput).

%validatePieceSelect(+GameState, +ValidatedRow, +ValidatedColumn, -PieceRow, -PieceColumn).
validatePieceSelect([Player|Board], ValidatedRow, ValidatedColumn, PieceRow, PieceColumn) :-
	valid_moves([_|Board], Player, ListOfMoves),!,
	member([ValidatedRow, ValidatedColumn], ListOfMoves) ->
	PieceRow = ValidatedRow,
	PieceColumn = ValidatedColumn;
	Player == 1,
	write('    [ERROR]: The selected piece choice is invalid! Your selected piece has to be a black piece with at least one possible legal move!\n    A legal move requires the value of each piece in the pair of pieces being switched to increase.\n\n'),
	getHumanPieceSelect([Player|Board], PieceRow, PieceColumn);
	write('    [ERROR]: The selected piece choice is invalid! Your selected piece has to be a white piece with at least one possible legal move!\n    A legal move requires the value of each piece in the pair of pieces being switched to increase.\n\n'),
	getHumanPieceSelect([Player|Board], PieceRow, PieceColumn).

%getHumanPieceMove(+GameState, +PieceRow, +PieceColumn, -NewPieceRow, -NewPieceColumn)
getHumanPieceMove([Player|Board], PieceRow, PieceColumn, NewPieceRow, NewPieceColumn) :-
	format('Player ~w, choose the position you want to move the piece to:~n', [Player]),
	getPieceType(Player, PieceType),
	validMovesOnPosition([Player|Board], PieceRow, PieceColumn, 1, PieceType, [], ListOfValidMoves),
	printOptions(ListOfValidMoves, 1),
	length(ListOfValidMoves, OptNum),
	readOption(OptNum, Option),
	getPositionFromOption(ListOfValidMoves, Option, NewPieceRow, NewPieceColumn).

%printOptions(+ListOfValidMoves, +Counter)
printOptions([[Row|[Column]]|[]], Counter) :-
	format('    ~w. [~w, ~w]\n\n', [Counter, Row, Column]).
printOptions([[Row|[Column]]|RestOfMoves], Counter) :-
	format('    ~w. [~w, ~w]\n', [Counter, Row, Column]),
	NewCounter is Counter + 1,
	printOptions(RestOfMoves, NewCounter).
	
%readOption(+OptNum, -Option)
readOption(OptNum, Option) :-
	write('Option: '),
    read(Aux), nl,
	number(Aux),
    Aux >= 1,
	Aux =< OptNum,
	Option is Aux;
    format('    [ERROR]: The given option is invalid! Has to be between 1 and ~w.\n\n', [OptNum]),
    readOption(OptNum, Option).
	
%getPositionFromOption(+ListOfValidMoves, +Option, -NewRow, -NewColumn)
getPositionFromOption([[Row|[Column]]|_], 1, NewRow, NewColumn) :-
	NewRow is Row,
	NewColumn is Column.
getPositionFromOption([[_|[_]]|RestOfMoves], Option, NewRow, NewColumn) :-
	NextOption is Option - 1,
	getPositionFromOption(RestOfMoves, NextOption, NewRow, NewColumn).