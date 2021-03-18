:-use_module(library(sockets)).
:-use_module(library(lists)).
:-use_module(library(codesio)).

port(8081).
:- dynamic socket/1.
socket(0).



updateSocket(Socket) :- 
	retract(socket(_)),
	assert(socket(Socket)).

:- dynamic stream/1.
stream(0).


updateStream(Stream) :- 
	retract(stream(_)),
	assert(stream(Stream)).


wait_command(Socket,Stream,Command):-
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
   format('Request: ~q~n',[Request]),
   parse_input(Request,Command).

send_reply(Stream,Reply):-
   format(Stream, 'HTTP/1.0 ~p~n', ['200 OK']),
   format(Stream, 'Access-Control-Allow-Origin: *~n', []),
   format(Stream, 'Content-Type: text/plain~n~n', []),
   format(Stream, '~p', [Reply]),
   format('Reply: ~q~n', [Reply]),
   close_stream(Stream).

	
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

parse_input(handshake, handshake).
parse_input(test(C,N), Res) :- test(C,Res,N).
parse_input(quit, goodbye).
	
parse_input(pvp, 1).
parse_input(pvb, 2).
parse_input(bvb, 3).
parse_input(exit, 0).



