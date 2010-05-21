findAllIncludes(F, [L | X]) :- findInclude(L, F, R), findAllIncludes(R, X).
findAllIncludes([], []).

findInclude(F) --> separadores0, "#", separadores0, "include", separadores0, fichero(F).

findFunctionsProt([F | [R]], (X, Y)) --> separadores0, tipo(F), separadores, nombre(R), separadores0, "(", listaParam, ")", separadores0, ";",
                                         { name(X, R), Y = 0 }.

listaParam --> [].

nombre([C | R]) --> [C], { is_letter(C) }, nombreRes(R).
nombreRes([C | R]) --> [C], { is_char(C) }, nombreRes(R).
nombreRes([]) --> [].

tipo(F) --> nombre(F), separadores0, asteriscos0.

 is_letter(X) :- X >= "a", X =< "z".
 is_letter(X) :- X >= "A", X =< "Z".

 is_char(X) :- (is_letter(X) | (X >= "0", X =< "9")). 

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