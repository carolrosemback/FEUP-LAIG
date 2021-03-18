%startGame(+Player1, +Player2)


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