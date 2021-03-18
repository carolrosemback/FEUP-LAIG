%mainMenu

:-use_module(library(sockets)).
:-use_module(library(codesio)).

mainMenu :-
    printMainMenu,
    getMenuOption,
    socket(Socket),
    wait_command(Socket,Stream,Command),
    updateStream(Stream),
    menuOption(Command).


%menuOption(+Option)
menuOption(1) :-
    stream(Stream),
    send_reply(Stream, ok),
    startGame(1, 2),
    mainMenu.
menuOption(2) :-
    stream(Stream),
    send_reply(Stream, ok),
    startGame(1, -2),
    mainMenu.
menuOption(3) :-
    stream(Stream),
    send_reply(Stream, ok),
    startGame(-1, -2),
    mainMenu.
menuOption(0) :-
    stream(Stream),
    send_reply(Stream, ok),
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