

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