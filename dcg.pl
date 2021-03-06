findInclude(F) --> separadores0, "#", separadores0, "include", separadores0, fichero(F).

findIncludes([H|[R1|R2]], [R1 | C]) --> anychar(H), "#", separadores0, "include", separadores0, 
                                        fichero(R1), !, findIncludes(R2,C).
findIncludes([],[]) --> []. 


anychar([C | R])--> [C], { not_square(C) }, anychar(R).
anychar([])-->[].

not_square(X) :- X \= 105. % Valor del carácter "#"

%findAllFunctionsProt(F, [K | X]) :- findFunctionsProt(_, K, F, R), findAllFunctionsProt(R, X).
%findAllFunctionsProt([], []).

findFunctionsProts([H | [R1 | R2]], [T | C]) --> anyelem(H), findFunctionsProt(R1,T), !, findFunctionsProts(R2,C).
findFunctionsProts([H | R1], C) --> [H], findFunctionsProts(R1, C).
findFunctionsProts([],[]) --> [].

anyelem([C | R])--> [C], { not(is_letter(C)) }, anyelem(R).
anyelem([])-->[].

findFunctionsProt([H | [R1|[R2]]], (X, Y)) --> separadores0,
                                               tipo2(H),
                                               nombre(R1),
                                               separadores0, "(", listaParam(R2, N), !, ")",
                                               separadores0, (";" | "{"),
                                               { name(X, R1), Y = N }.

findFunctionsProt([H | [R1|[R2|[R3]]]], (X, Y)) --> separadores0,
                                                    tipo2(H),
                                                    nombre0(R1),
                                                    separadores,
                                                    nombre(R2),
                                                    separadores0, "(", listaParam(R3, N), !, ")",
                                                    separadores0, (";" | "{"),
                                                    { name(X, R2), Y = N }.

findFunctionsProt([H | [R1|[R2|[R3|[R4]]]]], (X, Y)) --> separadores0,
                                                    nombre(H),
                                                    separadores,
                                                    tipo2(R1),
                                                    nombre(R2),
                                                    separadores,
                                                    nombre(R3),
                                                    separadores0, "(", listaParam(R4, N), !, ")",
                                                    separadores0, (";" | "{"),
                                                    { name(X, R3), Y = N }.

findFunctionsProt([H | [R1|[R2|[R3]]]], (X, Y)) --> separadores0,
                                                    nombre(H),
                                                    separadores,
                                                    tipo2(R1),
                                                    nombre(R2),
                                                    separadores0, "(", listaParam(R3, N), !, ")",
                                                    separadores0, (";" | "{"),
                                                    { name(X, R2), Y = N }.

findFunctionsImpls([H|[R1|[R2|[R3|[R4|[R5]]]]]], [T | C]) --> anychar(H), "{",
	                                                                  anychar(R1), findFunctionsImpl(R2,T),
                                                                      anychar(R3), findFunctionsImplsAux(R4,C),
                                                                      "}", anychar(R5).
findFunctionsImplsAux([H | R1], [T | C]) --> findFunctionsImpl(H,T), findFunctionsImplsAux(R1,C).
findFunctionsImplsAux([H | R1], C) --> [H], findFunctionsImplsAux(R1,C).
findFunctionsImplsAux([],[]) --> [].


findFunctionsImpl([H | [R1]], [(X, Y) | Z]) --> separadores0,
                                                nombre(H),
                                                separadores0, "(", listaParamImpl(R1, N, Z), ")",
                                                { name(X, H), Y = N }.

listaParamImpl([H | [R1]], N, Z) --> separadores0, findFunctionsImpl(H, Z1), separadores0, ",", listaParamImpl(R1, N1, Z2), { append(Z1, Z2, Z), N is N1 + 1 }.
listaParamImpl([H | [R1]], N, Z) --> separadores0, nombreONum(H), separadores0, ",", listaParamImpl(R1, N1, Z), { N is N1 + 1 }.
listaParamImpl([H], 1, Z) --> separadores0, findFunctionsImpl(H, Z), separadores0.
listaParamImpl([H], 1, []) --> separadores0, nombreONum(H), separadores0.
listaParamImpl([], 0, []) --> separadores0.

listaParam([H | [R1|[R2]]], N) --> separadores0, tipo(H), nombre0(R1), separadores0, ",", listaParam(R2, N1), !, { N is N1 + 1 }.
listaParam([H | [R1|[R2|[R3]]]], N) --> separadores0, tipo(H), nombre(R1), separadores0, "=", separadores0, nombreONum(R2), separadores0, ",", listaParam(R3, N1), !, { N is N1 + 1}.
listaParam([H | [R1]], 1) --> separadores0, tipo(H), nombre0(R1), separadores0.
listaParam([H | [R1|[R2]]], 1) --> separadores0, tipo(H), nombre(R1), separadores0, "=", separadores0, nombreONum(R2), separadores0.
listaParam([], 0) --> separadores0.

nombreONum([C | R]) --> [C], { is_char(C) }, nombreRes(R).
nombre([C | R]) --> [C], { is_letter(C) }, nombreRes(R).
nombreRes([C | R]) --> [C], { is_char(C) }, nombreRes(R).
nombreRes([]) --> [].

nombre0([C | R]) --> [C], { is_letter(C) }, nombreRes(R).
nombre0([]) --> [].

tipo(F) --> nombre(F), separadores0, asteriscos, separadores0.
tipo(F) --> nombre(F), separadores0.

tipo2(F) --> nombre(F), separadores0, asteriscos, separadores0.
tipo2(F) --> nombre(F), separadores.

is_letter(X) :- X >= "a", X =< "z".
is_letter(X) :- X >= "A", X =< "Z".
is_letter(X) :- X = 95. % Valor del carácter "_"

is_char(X) :- (is_letter(X) | (X >= "0", X =< "9")).

asteriscos --> "*", separadores0, asteriscos0.

asteriscos0 --> "*", separadores0, asteriscos0.
asteriscos0 --> [].

separadores0 --> (" " | "\t" | "\n" | comentarios), separadores0.
separadores0 --> [].

separadores --> " " , separadores0.

sep0 --> " ", sep0.
sep0 --> []. 
sep --> " ", sep0.

fichero(F) --> "<", cadena(R), { name(F, R) }, ">".
fichero(F) --> "\"", cadena(R), { name(F, R) },  "\"".

cadena([C | R]) --> [C], { not(member(C, ">\"")) }, cadena1(R).
cadena1([C | R]) --> [C], { not(member(C, ">\"")) }, cadena1(R).
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