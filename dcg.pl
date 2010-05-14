findInclude(F) --> "#", sep0, "include", sep, fichero(F).

sep0 --> " ", sep0.
sep0 --> [].

sep --> " ", sep0.

fichero(F) --> "<", cadena(R), { name(F, R) }, ">".
fichero(F) --> "\"", cadena(R), { name(F, R) },  "\"".

cadena([C | R]) --> [C], { not(member(C, [">", "\""])) }, cadena1(R).
cadena1([C | R]) --> [C], { not(member(C, [">", "\""])) }, cadena1(R).
cadena1([]) --> [].
