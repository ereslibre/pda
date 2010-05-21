findAllIncludes(F, [L | X]) :- findInclude(L, F, R), findAllIncludes(R, X).
findAllIncludes([], []).

findInclude(F) --> separadores, "#", sep0, "include", sep, fichero(F).

separadores --> " " | "\n" | "\t", separadores.
separadores --> [].

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

%preprocesador(F) --> comentarios, linea(F).
linea(F) --> nosep(R), { name(F, R) }.

nosep([C | R]) --> [C], { not(member(C, ":;")) }, !, nosep1(R).
nosep(R) -->[_], nosep1(R).
nosep1([C | R]) --> [C], { not(member(C, ":;")) }, !, nosep1(R).
nosep1(R) --> [_], nosep1(R).
nosep1([]) --> [].

comentarios --> comentarioLinea | comentarioLineas | [].
comentarioLineas --> "/*", comentario, "*/".
comentarioLinea --> "//", comentario, "\n".
comentario --> _, comentario.
comentario --> [].

