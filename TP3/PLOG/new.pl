:- use_module(library(random)).
:-use_module(library(sockets)).
:-use_module(library(lists)).
:-use_module(library(codesio)).



%play
play :-
	clearScreen,
	mainMenu.

mainMenu :-
    printMainMenu,
    getMenuOption,
    write(2), nl,
    socket(Socket),
    write(3), nl,
    socket_server_accept(Socket, _Client, Stream, [type(text)]),
    write(1), nl,
    read(Input),
    menuOption(Input).

%menuOption(+Option)
menuOption(1) :-
    startGame(1, 2),
    mainMenu.
menuOption(2) :-
    startGame(1, -2),
    mainMenu.
menuOption(3) :-
    startGame(-1, -2),
    mainMenu.
menuOption(0) :-
    write('\nGoodbye then.. (v_v)\n\n').
menuOption(_Other) :-
    write('\n[ERROR]: That menu option is invalid!\n\n'),
    getMenuOption,
    read(Input),
    menuOption(Input).

%getMenuOption
getMenuOption :-
    write('Choose an option: ').

%printMainMenu
printMainMenu :-
    nl,nl,
    write(' _________________________________________________________________________________________ '),nl,
    write('|                                                                                         |'),nl,
    write('|  ______     __    __     __  __     __         ______     __     ______     __   __     |'),nl,
    write('| /\\  ___\\   /\\ "-./  \\   /\\ \\/\\ \\   /\\ \\       /\\  ___\\   /\\ \\   /\\  __ \\   /\\ "-.\\ \\    |'),nl,
    write('| \\ \\  __\\   \\ \\ \\-./\\ \\  \\ \\ \\_\\ \\  \\ \\ \\____  \\ \\___  \\  \\ \\ \\  \\ \\ \\/\\ \\  \\ \\ \\-.  \\   |'),nl,
    write('|  \\ \\_____\\  \\ \\_\\ \\ \\_\\  \\ \\_____\\  \\ \\_____\\  \\/\\_____\\  \\ \\_\\  \\ \\_____\\  \\ \\_\\\\"\\_\\  |'),nl,
    write('|   \\/_____/   \\/_/  \\/_/   \\/_____/   \\/_____/   \\/_____/   \\/_/   \\/_____/   \\/_/ \\/_/  |'),nl,
    write('|                                                                                         |'),nl,
    write('|                       +-----------------------------------------+                       |'),nl,
    write('|                       |           Carolina Rosemback            |                       |'),nl,
    write('|                       |             Jose Rodrigues              |                       |'),nl,
    write('|                       +-----------------------------------------+                       |'),nl,
    write('|                                                                                         |'),nl,
    write('|                                                                                         |'),nl,
    write('|                                 1. Player vs Player                                     |'),nl,
    write('|                                                                                         |'),nl,
    write('|                                 2. Player vs Computer                                   |'),nl,
    write('|                                                                                         |'),nl,
	write('|                                 3. Computer vs Computer                                 |'),nl,
    write('|                                                                                         |'),nl,
    write('|                                 0. Exit                                                 |'),nl,
    write('|                                                                                         |'),nl,
    write('|_________________________________________________________________________________________|'),nl,nl.



    startGame(Player1, Player2) :-
	initial(InitialBoard),
	gameState(Player1, InitialBoard, GameState),
	display_game(GameState, Player1),
	doRound(GameState, Player1, Player2),!.

%changeTurn(+GameState, +Player1, +Player2, -NewGameState)
changeTurn([H|T], Player1, Player2, NewGameState) :-
	nextTurn(H, Player1, Player2, NewPlayer),
	gameState(NewPlayer, T, NewGameState).
	
%nextTurn(+CurrentPlayer, +Player1, +Player2, -NextPlayer)
nextTurn(CurrentPlayer, Player1, Player2, NextPlayer) :-
	Aux is abs(CurrentPlayer),
	Aux == 1,
	NextPlayer is Player2;
	Aux is abs(CurrentPlayer),
	NextPlayer is Player1.

%doRound(+GameState, +Player1, +Player2)
doRound([NextPlayer|Board], Player1, Player2) :-
	game_over([NextPlayer|Board], Winner),!,
	Winner == 'none' ->
	processRound([NextPlayer|Board], Player1, Player2);
	checkIfGameIsOver([NextPlayer|Board]),
	endGame,
	true.

%processRound(+GameState, +Player1, +Player2)
processRound([NextPlayer|Board], Player1, Player2) :-
	isHuman(NextPlayer) ->
	getHumanPieceSelect([NextPlayer|Board], PieceRow, PieceColumn),
	getHumanPieceMove([NextPlayer|Board], PieceRow, PieceColumn, NewPieceRow, NewPieceColumn),
	createMove(PieceRow, PieceColumn, NewPieceRow, NewPieceColumn, Move),
	move([NextPlayer|Board], Move, [Player|NewGameBoard]),
	changeTurn([Player|NewGameBoard], Player1, Player2, NewGameState),
	display_game(NewGameState, NextPlayer),
	doRound(NewGameState, Player1, Player2);
	isBot(NextPlayer) ->
	choose_move([NextPlayer|Board], NextPlayer, _, Move),
	move([NextPlayer|Board], Move, [Player|NewGameBoard]),
	changeTurn([Player|NewGameBoard], Player1, Player2, NewGameState),
	Computer is abs(Player),
	format('~nComputer ~w\'s move:~n', [Computer]),%'
	display_game(NewGameState, NextPlayer),
	doRound(NewGameState, Player1, Player2).

%endGame
endGame :-
	write('\n\nInput any character to end the game: '),
	read(_),
	clearScreen.

%valid_moves(+GameState, +Player, -ListOfMoves)
valid_moves([_|Board], Player, ListOfMoves) :-
	positionsList(ListOfPositions),
	getPieceType(Player, PieceType),
	valid_movesAux(Board, Player, Board, 9, ListOfPositions, PieceType, [], ListOfMoves).
	
%valid_movesAux(+Board, +Player, +Board, +RowColumnCounter, +ListOfPositions, +PieceType, +PlaceHolderList, -ListOfMoves)
valid_movesAux([], _, _, _, [], _, PlaceHolderList, ListOfMoves) :-
	ListOfMoves = PlaceHolderList.
valid_movesAux([[CurrentPiece|_]|RestOfRows], Player, IntactBoard, 0, [[PositionRow|[PositionColumn|_]]|TailListOfPositions], PieceType, PlaceHolderList, ListOfMoves) :-
	CurrentPiece == PieceType,
	validMovesOnPosition([Player|IntactBoard], PositionRow, PositionColumn, 1, PieceType, [], ListOfValidMoves),
	length(ListOfValidMoves, Length),
	Length \= 0,
	append([[PositionRow, PositionColumn]], PlaceHolderList, Aux),
	valid_movesAux(RestOfRows, Player, IntactBoard, 9, TailListOfPositions, PieceType, Aux, ListOfMoves);
	valid_movesAux(RestOfRows, Player, IntactBoard, 9, TailListOfPositions, PieceType, PlaceHolderList, ListOfMoves).
valid_movesAux([[CurrentPiece|RestOfColumns]|RestOfRows], Player, IntactBoard, BoardCounter, [[PositionRow|[PositionColumn|_]]|TailListOfPositions], PieceType, PlaceHolderList, ListOfMoves) :-
	CurrentPiece == PieceType,
	Counter is BoardCounter - 1,
	validMovesOnPosition([Player|IntactBoard], PositionRow, PositionColumn, 1, PieceType, [], ListOfValidMoves),
	length(ListOfValidMoves, Length),
	Length \= 0,
	append([[PositionRow, PositionColumn]], PlaceHolderList, Aux),
	valid_movesAux([RestOfColumns|RestOfRows], Player, IntactBoard, Counter, TailListOfPositions, PieceType, Aux, ListOfMoves);
	Counter is BoardCounter - 1,
	valid_movesAux([RestOfColumns|RestOfRows], Player, IntactBoard, Counter, TailListOfPositions, PieceType, PlaceHolderList, ListOfMoves).

%validMovesOnPosition(+GameState, +Row, +Column, +PositionToCheck, +PieceType, +PlaceHolderList, -ListOfValidMoves)
%PositionToCheck: 1 - TopLeft \ 2 - Top \ 3 - TopRight \ 4 - Right \ 5 - BottomRight \ 6 - Bottom \ 7 - BottomLeft \ 8 - Left \ 9 - Finish function
validMovesOnPosition(_, _, _, 9, _, PlaceHolderList, ListOfValidMoves) :-
	ListOfValidMoves = PlaceHolderList.
validMovesOnPosition([Player|Board], Row, Column, 1, PieceType, PlaceHolderList, ListOfValidMoves) :-
	RowToCheck is Row - 1,
	ColumnToCheck is Column - 1,
	RowToCheck >= 0,
	RowToCheck =< 9,
	ColumnToCheck >= 0,
	ColumnToCheck =< 9,
	getReversePieceType(PieceType, ReversePieceType),
	getPiece(Board, RowToCheck, ColumnToCheck, Piece),!,
	Piece == ReversePieceType,
	createMove(Row, Column, RowToCheck, ColumnToCheck, MoveToCheck),
	move([Player|Board], MoveToCheck, [_|NewBoard]),
	pieceValue([Player|Board], Row, Column, PieceType, 1, OldValue1),!,
	pieceValue([Player|NewBoard], RowToCheck, ColumnToCheck, PieceType, 1, NewValue1),!,
	NewValue1 > OldValue1 ->
	pieceValue([Player|Board], RowToCheck, ColumnToCheck, ReversePieceType, 1, OldValue2),!,
	pieceValue([Player|NewBoard], Row, Column, ReversePieceType, 1, NewValue2),!,
	NewValue2 > OldValue2 ->
	append([[RowToCheck,ColumnToCheck]], PlaceHolderList, Aux),
	validMovesOnPosition([Player|Board], Row, Column, 2, PieceType, Aux, ListOfValidMoves);
	validMovesOnPosition([Player|Board], Row, Column, 2, PieceType, PlaceHolderList, ListOfValidMoves).
validMovesOnPosition([Player|Board], Row, Column, 2, PieceType, PlaceHolderList, ListOfValidMoves) :-
	RowToCheck is Row - 1,
	ColumnToCheck is Column,
	RowToCheck >= 0,
	RowToCheck =< 9,
	ColumnToCheck >= 0,
	ColumnToCheck =< 9,
	getReversePieceType(PieceType, ReversePieceType),
	getPiece(Board, RowToCheck, ColumnToCheck, Piece),!,
	Piece == ReversePieceType,
	createMove(Row, Column, RowToCheck, ColumnToCheck, MoveToCheck),
	move([Player|Board], MoveToCheck, [_|NewBoard]),
	pieceValue([Player|Board], Row, Column, PieceType, 1, OldValue1),!,
	pieceValue([Player|NewBoard], RowToCheck, ColumnToCheck, PieceType, 1, NewValue1),!,
	NewValue1 > OldValue1 ->
	pieceValue([Player|Board], RowToCheck, ColumnToCheck, ReversePieceType, 1, OldValue2),!,
	pieceValue([Player|NewBoard], Row, Column, ReversePieceType, 1, NewValue2),!,
	NewValue2 > OldValue2 ->
	append([[RowToCheck,ColumnToCheck]], PlaceHolderList, Aux),
	validMovesOnPosition([Player|Board], Row, Column, 3, PieceType, Aux, ListOfValidMoves);
	validMovesOnPosition([Player|Board], Row, Column, 3, PieceType, PlaceHolderList, ListOfValidMoves).
validMovesOnPosition([Player|Board], Row, Column, 3, PieceType, PlaceHolderList, ListOfValidMoves) :-
	RowToCheck is Row - 1,
	ColumnToCheck is Column + 1,
	RowToCheck >= 0,
	RowToCheck =< 9,
	ColumnToCheck >= 0,
	ColumnToCheck =< 9,
	getReversePieceType(PieceType, ReversePieceType),
	getPiece(Board, RowToCheck, ColumnToCheck, Piece),!,
	Piece == ReversePieceType,
	createMove(Row, Column, RowToCheck, ColumnToCheck, MoveToCheck),
	move([Player|Board], MoveToCheck, [_|NewBoard]),
	pieceValue([Player|Board], Row, Column, PieceType, 1, OldValue1),!,
	pieceValue([Player|NewBoard], RowToCheck, ColumnToCheck, PieceType, 1, NewValue1),!,
	NewValue1 > OldValue1 ->
	pieceValue([Player|Board], RowToCheck, ColumnToCheck, ReversePieceType, 1, OldValue2),!,
	pieceValue([Player|NewBoard], Row, Column, ReversePieceType, 1, NewValue2),!,
	NewValue2 > OldValue2 ->
	append([[RowToCheck,ColumnToCheck]], PlaceHolderList, Aux),
	validMovesOnPosition([Player|Board], Row, Column, 4, PieceType, Aux, ListOfValidMoves);
	validMovesOnPosition([Player|Board], Row, Column, 4, PieceType, PlaceHolderList, ListOfValidMoves).
validMovesOnPosition([Player|Board], Row, Column, 4, PieceType, PlaceHolderList, ListOfValidMoves) :-
	RowToCheck is Row,
	ColumnToCheck is Column + 1,
	RowToCheck >= 0,
	RowToCheck =< 9,
	ColumnToCheck >= 0,
	ColumnToCheck =< 9,
	getReversePieceType(PieceType, ReversePieceType),
	getPiece(Board, RowToCheck, ColumnToCheck, Piece),!,
	Piece == ReversePieceType,
	createMove(Row, Column, RowToCheck, ColumnToCheck, MoveToCheck),
	move([Player|Board], MoveToCheck, [_|NewBoard]),
	pieceValue([Player|Board], Row, Column, PieceType, 1, OldValue1),!,
	pieceValue([Player|NewBoard], RowToCheck, ColumnToCheck, PieceType, 1, NewValue1),!,
	NewValue1 > OldValue1 ->
	pieceValue([Player|Board], RowToCheck, ColumnToCheck, ReversePieceType, 1, OldValue2),!,
	pieceValue([Player|NewBoard], Row, Column, ReversePieceType, 1, NewValue2),!,
	NewValue2 > OldValue2 ->
	append([[RowToCheck,ColumnToCheck]], PlaceHolderList, Aux),
	validMovesOnPosition([Player|Board], Row, Column, 5, PieceType, Aux, ListOfValidMoves);
	validMovesOnPosition([Player|Board], Row, Column, 5, PieceType, PlaceHolderList, ListOfValidMoves).
validMovesOnPosition([Player|Board], Row, Column, 5, PieceType, PlaceHolderList, ListOfValidMoves) :-
	RowToCheck is Row + 1,
	ColumnToCheck is Column + 1,
	RowToCheck >= 0,
	RowToCheck =< 9,
	ColumnToCheck >= 0,
	ColumnToCheck =< 9,
	getReversePieceType(PieceType, ReversePieceType),
	getPiece(Board, RowToCheck, ColumnToCheck, Piece),!,
	Piece == ReversePieceType,
	createMove(Row, Column, RowToCheck, ColumnToCheck, MoveToCheck),
	move([Player|Board], MoveToCheck, [_|NewBoard]),
	pieceValue([Player|Board], Row, Column, PieceType, 1, OldValue1),!,
	pieceValue([Player|NewBoard], RowToCheck, ColumnToCheck, PieceType, 1, NewValue1),!,
	NewValue1 > OldValue1 ->
	pieceValue([Player|Board], RowToCheck, ColumnToCheck, ReversePieceType, 1, OldValue2),!,
	pieceValue([Player|NewBoard], Row, Column, ReversePieceType, 1, NewValue2),!,
	NewValue2 > OldValue2 ->
	append([[RowToCheck,ColumnToCheck]], PlaceHolderList, Aux),
	validMovesOnPosition([Player|Board], Row, Column, 6, PieceType, Aux, ListOfValidMoves);
	validMovesOnPosition([Player|Board], Row, Column, 6, PieceType, PlaceHolderList, ListOfValidMoves).
validMovesOnPosition([Player|Board], Row, Column, 6, PieceType, PlaceHolderList, ListOfValidMoves) :-
	RowToCheck is Row + 1,
	ColumnToCheck is Column,
	RowToCheck >= 0,
	RowToCheck =< 9,
	ColumnToCheck >= 0,
	ColumnToCheck =< 9,
	getReversePieceType(PieceType, ReversePieceType),
	getPiece(Board, RowToCheck, ColumnToCheck, Piece),!,
	Piece == ReversePieceType,
	createMove(Row, Column, RowToCheck, ColumnToCheck, MoveToCheck),
	move([Player|Board], MoveToCheck, [_|NewBoard]),
	pieceValue([Player|Board], Row, Column, PieceType, 1, OldValue1),!,
	pieceValue([Player|NewBoard], RowToCheck, ColumnToCheck, PieceType, 1, NewValue1),!,
	NewValue1 > OldValue1 ->
	pieceValue([Player|Board], RowToCheck, ColumnToCheck, ReversePieceType, 1, OldValue2),!,
	pieceValue([Player|NewBoard], Row, Column, ReversePieceType, 1, NewValue2),!,
	NewValue2 > OldValue2 ->
	append([[RowToCheck,ColumnToCheck]], PlaceHolderList, Aux),
	validMovesOnPosition([Player|Board], Row, Column, 7, PieceType, Aux, ListOfValidMoves);
	validMovesOnPosition([Player|Board], Row, Column, 7, PieceType, PlaceHolderList, ListOfValidMoves).
validMovesOnPosition([Player|Board], Row, Column, 7, PieceType, PlaceHolderList, ListOfValidMoves) :-
	RowToCheck is Row + 1,
	ColumnToCheck is Column - 1,
	RowToCheck >= 0,
	RowToCheck =< 9,
	ColumnToCheck >= 0,
	ColumnToCheck =< 9,
	getReversePieceType(PieceType, ReversePieceType),
	getPiece(Board, RowToCheck, ColumnToCheck, Piece),!,
	Piece == ReversePieceType,
	createMove(Row, Column, RowToCheck, ColumnToCheck, MoveToCheck),
	move([Player|Board], MoveToCheck, [_|NewBoard]),
	pieceValue([Player|Board], Row, Column, PieceType, 1, OldValue1),!,
	pieceValue([Player|NewBoard], RowToCheck, ColumnToCheck, PieceType, 1, NewValue1),!,
	NewValue1 > OldValue1 ->
	pieceValue([Player|Board], RowToCheck, ColumnToCheck, ReversePieceType, 1, OldValue2),!,
	pieceValue([Player|NewBoard], Row, Column, ReversePieceType, 1, NewValue2),!,
	NewValue2 > OldValue2 ->
	append([[RowToCheck,ColumnToCheck]], PlaceHolderList, Aux),
	validMovesOnPosition([Player|Board], Row, Column, 8, PieceType, Aux, ListOfValidMoves);
	validMovesOnPosition([Player|Board], Row, Column, 8, PieceType, PlaceHolderList, ListOfValidMoves).
validMovesOnPosition([Player|Board], Row, Column, 8, PieceType, PlaceHolderList, ListOfValidMoves) :-
	RowToCheck is Row,
	ColumnToCheck is Column - 1,
	RowToCheck >= 0,
	RowToCheck =< 9,
	ColumnToCheck >= 0,
	ColumnToCheck =< 9,
	getReversePieceType(PieceType, ReversePieceType),
	getPiece(Board, RowToCheck, ColumnToCheck, Piece),!,
	Piece == ReversePieceType,
	createMove(Row, Column, RowToCheck, ColumnToCheck, MoveToCheck),
	move([Player|Board], MoveToCheck, [_|NewBoard]),
	pieceValue([Player|Board], Row, Column, PieceType, 1, OldValue1),!,
	pieceValue([Player|NewBoard], RowToCheck, ColumnToCheck, PieceType, 1, NewValue1),!,
	NewValue1 > OldValue1 ->
	pieceValue([Player|Board], RowToCheck, ColumnToCheck, ReversePieceType, 1, OldValue2),!,
	pieceValue([Player|NewBoard], Row, Column, ReversePieceType, 1, NewValue2),!,
	NewValue2 > OldValue2 ->
	append([[RowToCheck,ColumnToCheck]], PlaceHolderList, Aux),
	validMovesOnPosition([Player|Board], Row, Column, 9, PieceType, Aux, ListOfValidMoves);
	validMovesOnPosition([Player|Board], Row, Column, 9, PieceType, PlaceHolderList, ListOfValidMoves).

%move(+GameState, +Move, -NewGameState)​
move([NextPlayer|Board], [[OldRow, OldColumn], [NewRow, NewColumn]], NewGameState) :-
	changePiece(Board, OldRow, OldColumn, NewBoard1),
	changePiece(NewBoard1, NewRow, NewColumn, NewBoard2),
	NewGameState = [NextPlayer|NewBoard2].

%changePiece(+Board, +Row, +Column, -NewBoard)
changePiece([], _, _, []).
changePiece([CurrentRow|RestOfRows], 0, Column, NewBoard) :-
	NextRow is -1,
	changePiece(RestOfRows, NextRow, Column, AuxBoard),
	changePieceOnRow(CurrentRow, Column, NewRow),
	append([NewRow], AuxBoard, NewBoard).
changePiece([CurrentRow|RestOfRows], Row, Column, NewBoard) :-
	NextRow is Row - 1,
	changePiece(RestOfRows, NextRow, Column, AuxBoard),
	append([CurrentRow], AuxBoard, NewBoard).


%changePieceOnRow(+CurrentRow, +Column, -NewRow)
changePieceOnRow([], _, []).
changePieceOnRow([CurrentPiece|RestOfColums], 0, NewRow) :-
	NextColumn is -1,
	changePieceOnRow(RestOfColums, NextColumn, AuxRow),
	getReversePieceType(CurrentPiece, NewPiece),
	append([NewPiece], AuxRow, NewRow).
changePieceOnRow([CurrentPiece|RestOfColums], Column, NewRow) :-
	NextColumn is Column - 1,
	changePieceOnRow(RestOfColums, NextColumn, AuxRow),
	append([CurrentPiece], AuxRow, NewRow).
 
 %checkWinner(+GameState, -Winner)
checkWinner(GameState, Winner) :-
	value(GameState, 1, Val1),
	value(GameState, 2, Val2),
	getWinner(Val1, Val2, Winner).
	
getWinner(Val1, Val2, Winner) :-
	Val1 < Val2,
	Winner = 'Player1';
	Val1 > Val2,
	Winner = 'Player2';
	Val2 == Val1,
	Winner = 'Tie'.

%checkIfGameIsOver(+GameState)
checkIfGameIsOver([Player|Board]) :-
	valid_moves([Player|Board], Player, ListOfMoves),!,
	length(ListOfMoves, MovesAvaliable),
	MovesAvaliable == 0.

%game_over(+GameState, -Winner)
game_over([Player|Board], Winner) :-
	checkIfGameIsOver([Player|Board]),
	write('-=!=-=!=-=!=-=!=- Game Over -=!=-=!=-=!=-=!=-\n'),
    checkWinner([Player|Board], Winner),
	write('\n              \\\\\\   Winner   ///\n'),
	format('\n                    ~w~n', Winner),
	write('\n              ///   Winner   \\\\\\\n');
	Winner = 'none'.

%value(+GameState, +Player, -Value)​
value([_|Board], Player, Value) :-
	positionsList(ListOfPositions),
	getPieceType(Player, PieceType),
	getLargestGroup(Board, ListOfPositions, [], PieceType, 0, MaxValue),
	Value = MaxValue.

%pieceValue(+GameState, +PieceRow, +PieceColumn, +PieceType, +IsMasterFunction, -Value)
pieceValue([_|Board], PieceRow, PieceColumn, PieceType, 1, Value) :-
	getPiece(Board, PieceRow, PieceColumn, Piece),!,
	Piece == PieceType ->
	AuxTop is PieceRow-1,
	AuxBottom is PieceRow+1,
	AuxLeft is PieceColumn-1,
	AuxRight is PieceColumn+1,
	pieceValue([_|Board], PieceRow, PieceColumn, PieceType, -1, BoardEdgesValue),
	pieceValue([_|Board], AuxTop, PieceColumn, PieceType, 0, Aux1),
	pieceValue([_|Board], PieceRow, AuxRight, PieceType, 0, Aux2),
	pieceValue([_|Board], AuxBottom, PieceColumn, PieceType, 0, Aux3),
	pieceValue([_|Board], PieceRow, AuxLeft, PieceType, 0, Aux4),
	Value is BoardEdgesValue + Aux1 + Aux2 + Aux3 + Aux4;
	Value = 0.
pieceValue([_|Board], PieceRow, PieceColumn, PieceType, 0, Value) :-
	PieceRow >= 0,
	PieceRow =< 9,
	PieceColumn >= 0,
	PieceColumn =< 9,
	getPiece(Board, PieceRow, PieceColumn, Piece),!,
	Piece == PieceType ->
	Value = 1;
	Value = 0.
pieceValue([_|_], PieceRow, PieceColumn, _, -1, Value) :-
	AuxTop is PieceRow-1,
	AuxRight is PieceColumn+1,
	member(AuxTop, [-1, 10]),
	member(AuxRight, [-1, 10]),
	Value = 1;
	AuxTop is PieceRow-1,
	AuxLeft is PieceColumn-1,
	member(AuxTop, [-1, 10]),
	member(AuxLeft, [-1, 10]),
	Value = 1;
	AuxBottom is PieceRow+1,
	AuxRight is PieceColumn+1,
	member(AuxBottom, [-1, 10]),
	member(AuxRight, [-1, 10]),
	Value = 1;
	AuxBottom is PieceRow+1,
	AuxLeft is PieceColumn-1,
	member(AuxBottom, [-1, 10]),
	member(AuxLeft, [-1, 10]),
	Value = 1;
	AuxTop is PieceRow-1,
	member(AuxTop, [-1, 10]),
	Value = 0.5;
	AuxBottom is PieceRow+1,
	member(AuxBottom, [-1, 10]),
	Value = 0.5;
	AuxLeft is PieceColumn-1,
	member(AuxLeft, [-1, 10]),
	Value = 0.5;
	AuxRight is PieceColumn+1,
	member(AuxRight, [-1, 10]),
	Value = 0.5;
	Value = 0.
	

%choose_move(+GameState, +Player, +Level, -Move)
choose_move([_|Board], Player, _, Move) :-
	valid_moves([_|Board], Player, ListOfMoves),
	random_member([OldRow, OldColumn], ListOfMoves),
	getPieceType(Player, PieceType),
	validMovesOnPosition([Player|Board], OldRow, OldColumn, 1, PieceType, [], ListOfValidMoves),
	random_member([NewRow, NewColumn], ListOfValidMoves),
	createMove(OldRow, OldColumn, NewRow, NewColumn, Move).

%getLargestGroup(+Board, +ListOfPositions, +ListOfCheckedPositions, +PieceType, +ValuePlaceholder, -MaxValue)
getLargestGroup(_, [], _, _, ValuePlaceholder, MaxValue) :-
	MaxValue is ValuePlaceholder.
getLargestGroup(Board, [[PositionRow|[PositionColumn|_]]|TailListOfPositions], ListOfCheckedPositions, PieceType, ValuePlaceholder, MaxValue) :-
	ground(ValuePlaceholder),
	\+ member([PositionRow|PositionColumn], ListOfCheckedPositions),
	getPiece(Board, PositionRow, PositionColumn, Piece),
	Piece == PieceType,
	getGroup(Board, PositionRow, PositionColumn, PieceType, ListOfCheckedPositions, NewListOfCheckedPositions, GroupValue),!,
	GroupValue > ValuePlaceholder ->
	getLargestGroup(Board, TailListOfPositions, NewListOfCheckedPositions, PieceType, GroupValue, MaxValue);
	getLargestGroup(Board, TailListOfPositions, ListOfCheckedPositions, PieceType, ValuePlaceholder, MaxValue).

%getGroup(+Board, +PositionRow, +PositionColumn, +PieceType, +ListOfCheckedPositions, -NewListOfCheckedPositions, -GroupValue)
getGroup(Board,PositionRow, PositionColumn, PieceType, ListOfCheckedPositions, NewListOfCheckedPositions, GroupValue) :-
	PositionRow >= 0,
	PositionRow =< 9,
	PositionColumn >= 0,
	PositionColumn =< 9,
	\+ member([PositionRow|PositionColumn], ListOfCheckedPositions),
	append([[PositionRow|PositionColumn]], ListOfCheckedPositions, AuxList1),
	getPiece(Board, PositionRow, PositionColumn, Piece),!,
	Piece == PieceType ->
	AuxTop is PositionRow-1,
	AuxBottom is PositionRow+1,
	AuxLeft is PositionColumn-1,
	AuxRight is PositionColumn+1,
	getGroup(Board, AuxTop, PositionColumn, PieceType, AuxList1, AuxList2, GroupValueTop),
	getGroup(Board, AuxBottom, PositionColumn, PieceType, AuxList2, AuxList3, GroupValueBottom),
	getGroup(Board, PositionRow, AuxLeft, PieceType, AuxList3, AuxList4, GroupValueLeft),
	getGroup(Board, PositionRow, AuxRight, PieceType, AuxList4, NewListOfCheckedPositions, GroupValueRight),
	GroupValue is 1 + GroupValueTop + GroupValueBottom + GroupValueLeft + GroupValueRight;
	\+ ground(NewListOfCheckedPositions),
	PositionRow >= 0,
	PositionRow =< 9,
	PositionColumn >= 0,
	PositionColumn =< 9,
	\+ member([PositionRow|PositionColumn], ListOfCheckedPositions),
	append([[PositionRow|PositionColumn]], ListOfCheckedPositions, AuxList1),
	NewListOfCheckedPositions = AuxList1,
	GroupValue = 0;
	\+ ground(NewListOfCheckedPositions),
	NewListOfCheckedPositions = ListOfCheckedPositions,
	GroupValue = 0;
	GroupValue = 0.

%gameState(+Player, +Board, -GameState)
gameState(Player, Board, GameState) :-
	append([Player], Board, GameState).

%createMove(+OldRow, +OldColumn, +NewRow, +NewColumn, -Move)
createMove(OldRow, OldColumn, NewRow, NewColumn, Move) :-
	Move = [[OldRow, OldColumn], [NewRow, NewColumn]].



%getHumanPieceSelect(+GameState, -PieceRow, -PieceColumn)
getHumanPieceSelect([Player|Board], PieceRow, PieceColumn) :-
	format('Player ~w, choose a piece you want to move:~n', [Player]),
	readRow(Row),
	%readColumn(Column),
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


    
%isHuman(+Player)
isHuman(1).
isHuman(2).

%isBot(+Player)
isBot(-1).
isBot(-2).

%getPiece(+Board, +Row, +Column, -Piece)
getPiece([BoardLine | _], 0, Column, Piece):-
	getPieceFromLine(BoardLine, Column, Piece).
getPiece([_|BoardLines], Row, Column, Piece) :-
	Aux is Row - 1,
	getPiece(BoardLines, Aux, Column, Piece).
%getPiece(+BoardLine, +Column, -Piece)
getPieceFromLine([BoardPosition|_], 0, BoardPosition).
getPieceFromLine([_|BoardPositions], Column, Piece) :-
	Aux is Column - 1,
	getPieceFromLine(BoardPositions, Aux, Piece).

%getPieceType(+Player, -PieceType)
getPieceType(Player, PieceType) :-
	Aux is abs(Player),
	Aux == 1,
	PieceType = 'black';
	Aux is abs(Player),
	Aux == 2,
	PieceType = 'white'.

%getReversePieceType(+PieceType, -ReversePieceType)
getReversePieceType(PieceType, ReversePieceType) :-
	PieceType == 'white',
	ReversePieceType = 'black';
	PieceType == 'black',
	ReversePieceType = 'white'.

%positionsList(-PositionsList)
positionsList([
	[0, 0], [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7], [0, 8], [0, 9],
	[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7], [1, 8], [1, 9],
	[2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8], [2, 9],
	[3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7], [3, 8], [3, 9],
	[4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], [4, 8], [4, 9],
	[5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7], [5, 8], [5, 9],
	[6, 0], [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [6, 6], [6, 7], [6, 8], [6, 9],
	[7, 0], [7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [7, 8], [7, 9],
	[8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7], [8, 8], [8, 9],
	[9, 0], [9, 1], [9, 2], [9, 3], [9, 4], [9, 5], [9, 6], [9, 7], [9, 8], [9, 9]
]).

%clearScreen
clearScreen :- write('\e[2J').


%initial(-Board)
initial([
	[black, white, black, white, black, white, black, white, black, white],
	[white, black, white, black, white, black, white, black, white, black],
	[black, white, black, white, black, white, black, white, black, white],
	[white, black, white, black, white, black, white, black, white, black],
	[black, white, black, white, black, white, black, white, black, white],
	[white, black, white, black, white, black, white, black, white, black],
	[black, white, black, white, black, white, black, white, black, white],
	[white, black, white, black, white, black, white, black, white, black],
	[black, white, black, white, black, white, black, white, black, white],
	[white, black, white, black, white, black, white, black, white, black]
]).

%pieceRep(+Piece, -Representation)
pieceRep(black, P) :- P='| B '.
pieceRep(white, P) :- P='|   '.

%display_game(+GameState, +CurrentPlayer)
display_game([_|Board], _) :-
	printBoard(Board).

%printBoard(+Board)
printBoard(Board) :-
	printPreBoard,
	printActualBoard(Board, 0),
	nl, nl.
	
%printPreBoard
printPreBoard :-
	nl,nl,
	write('-=x=-=x=-=x=-=x=- Emulsion -=x=-=x=-=x=-=x=-'),
	nl,nl,nl,
	write('    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |'),
	nl.

%printActualBoard(+Board, +LineNumber)
printActualBoard([], 10) :-
	write(' ------------------------------------------- ').
printActualBoard([FirstLine|Rest], N) :-
	write(' ------------------------------------------- '),
	nl,
	write('  '),
	write(N),
	write(' '),
	N1 is N + 1,
	printLine(FirstLine),
	nl,
	printActualBoard(Rest, N1).

%printLine(+BoardLine)	
printLine([]) :-
	write('|').
printLine([FirstSpot|Rest]) :-
	pieceRep(FirstSpot, L),
	write(L),
	printLine(Rest).




% Server Entry Point
server :-
	port(Port),
	write('Opened Server'),nl,nl,
	socket_server_open(Port, Socket),
	updateSocket(Socket),
	%server_loop(Socket),
	play,
	socket_server_close(Socket),
	write('Closed Server'),nl.

% Server Loop 
% Uncomment writes for more information on incomming connections
server_loop(Socket) :-
	repeat,
	socket_server_accept(Socket, _Client, Stream, [type(text)]),
		% write('Accepted connection'), nl,
	    % Parse Request
		catch((
			read_request(Stream, Request),
			read_header(Stream)
		),_Exception,(
			% write('Error parsing request.'),nl,
			close_stream(Stream),
			fail
		)),
		
		% Generate Response
		handle_request(Request, MyReply, Status),
		format('Request: ~q~n',[Request]),
		format('Reply: ~q~n', [MyReply]),
		
		% Output Response
		format(Stream, 'HTTP/1.0 ~p~n', [Status]),
		format(Stream, 'Access-Control-Allow-Origin: *~n', []),
		format(Stream, 'Content-Type: text/plain~n~n', []),
		format(Stream, '~p', [MyReply]),
	
		% write('Finnished Connection'),nl,nl,
		close_stream(Stream),
	(Request = quit), !.
	
close_stream(Stream) :- flush_output(Stream), close(Stream).

% Handles parsed HTTP requests
% Returns 200 OK on successful aplication of parse_input on request
% Returns 400 Bad Request on syntax error (received from parser) or on failure of parse_input
handle_request(Request, MyReply, '200 OK') :- catch(parse_input(Request, MyReply),error(_,_),fail), !.
handle_request(syntax_error, 'Syntax Error', '400 Bad Request') :- !.
handle_request(_, 'Bad Request', '400 Bad Request').

% Reads first Line of HTTP Header and parses request
% Returns term parsed from Request-URI
% Returns syntax_error in case of failure in parsing
read_request(Stream, Request) :-
	read_line(Stream, LineCodes),
	print_header_line(LineCodes),
	
	% Parse Request
	atom_codes('GET /',Get),
	append(Get,RL,LineCodes),
	read_request_aux(RL,RL2),	
	
	catch(read_from_codes(RL2, Request), error(syntax_error(_),_), fail), !.
read_request(_,syntax_error).
	
read_request_aux([32|_],[46]) :- !.
read_request_aux([C|Cs],[C|RCs]) :- read_request_aux(Cs, RCs).


% Reads and Ignores the rest of the lines of the HTTP Header
read_header(Stream) :-
	repeat,
	read_line(Stream, Line),
	print_header_line(Line),
	(Line = []; Line = end_of_file),!.

check_end_of_header([]) :- !, fail.
check_end_of_header(end_of_file) :- !,fail.
check_end_of_header(_).

% Function to Output Request Lines (uncomment the line bellow to see more information on received HTTP Requests)
% print_header_line(LineCodes) :- catch((atom_codes(Line,LineCodes),write(Line),nl),_,fail), !.
print_header_line(_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                                       Commands                                                  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Require your Prolog Files here


parse_input(handshake, handshake).
parse_input(test(C,N), Res) :- test(C,Res,N).
parse_input(quit, goodbye).

test(_,[],N) :- N =< 0.
test(A,[A|Bs],N) :- N1 is N-1, test(A,Bs,N1).
	
parse_input(pvp, pvp).




port(8081).
:- dynamic socket/1.
socket(0).

updateSocket(Socket) :- 
	retract(socket(_)),
	assert(socket(Socket)).





