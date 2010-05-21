findAllIncludes(F, [L | X]) :- findInclude(L, F, R), findAllIncludes(R, X).
findAllIncludes([], []).

findInclude(F) --> separadores0, "#", separadores0, "include", separadores0, fichero(F).

findFunctionsProt([H | [R1|[R2]]], (X, Y)) --> separadores0, tipo(H), nombre(R1), separadores0, "(", listaParam(R2, N), ")", separadores0, ";",
                                         { name(X, R1), Y = N }.


listaParam([H | [R1|[R2]]], N) --> separadores0, tipo(H), nombre(R1), separadores0, ",", listaParam(R2, N1), { N is N1 + 1}.
listaParam([H | [R1]], N) --> separadores0, tipo(H), nombre(R1), separadores0, { N is 1 }.
listaParam([], N) --> [], { N = 0 }.

nombre([C | R]) --> [C], { is_letter(C) }, nombreRes(R).
nombreRes([C | R]) --> [C], { is_char(C) }, nombreRes(R).
nombreRes([]) --> [].

tipo(F) --> nombre(F), separadores0, asteriscos, separadores0.
tipo(F) --> nombre(F), separadores.

 is_letter(X) :- X >= "a", X =< "z".
 is_letter(X) :- X >= "A", X =< "Z".

 is_char(X) :- (is_letter(X) | (X >= "0", X =< "9")). 

asteriscos --> "*", asteriscos0.

asteriscos0 --> "*", asteriscos0.
asteriscos0 --> [].

separadores0 --> (" " | "\t" | comentarios), separadores0.
separadores0 --> [].

separadores --> " " , separadores0.

sep0 --> " ", sep0.
sep0 --> []. 
sep --> " ", sep0.

fichero(F) --> "<", cadena(R), { name(F, R) }, ">".
fichero(F) --> "\"", cadena(R), { name(F, R) },  "\"".

cadena([C | R]) --> [C], { not(member(C, [">", "\""])) }, cadena1(R).
cadena1([C | R]) --> [C], { not(member(C, [">", "\""])) }, cadena1(R).
cadena1([]) --> [].

% Reglas del preprocesado del fichero
% Eliminan comentarios y saltos inecesarios. Al finalizar obtenemos un fichero
% donde cada salto de línea es precedido por ;

% preprocesador(F) --> sep0, linea(F).
% linea(F) --> nosep(R), { name(F, R) }.
% 
% nosep([C | R]) --> [C], { not(member(C, ":;\n")) }, !, nosep1(R).
% nosep(R) -->[_], nosep1(R).
% nosep1([C | R]) --> [C], { not(member(C, ":;\n")) }, !, nosep1(R).
% nosep1(R) --> [_], nosep1(R).
% nosep1([]) --> [].

comentarios --> comentarioLinea | comentarioLineas.
comentarioLineas --> "/*", comentario, "*/".
comentarioLinea --> "//", comentario, "\n".
comentario --> [_]  , comentario.
comentario --> [].