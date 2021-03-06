%%
%% This file is part of IncludeZilla.
%%
%% Copyright 2010 (C) Rafael Fernández López <ereslibre@ereslibre.es>
%% Copyright 2010 (C) Jorge Olmos Mallol <thejofit@gmail.com>
%%
%% IncludeZilla is free software: you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%% 
%% IncludeZilla is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with IncludeZilla.  If not, see <http://www.gnu.org/licenses/>.
%%

:- include(config).
:- include(dcg).

%% PUBLIC RULES.

includeZilla(ProjectRoot) :-
	fetchAllSources(ProjectRoot, Temp),
	includeZillaFile(Temp).

includeZillaFile([]).

includeZillaFile([X | Xs]) :-
	open(X, read, In),
	processAllContents(In).
	%% close(In),
	%% findAllIncludes(L, Contents, R),
	%% includeZillaFile(Xs), ! ;
	%% includeZillaFile(Xs).

%% PRIVATE RULES. NOT MEANT TO BE USED FROM THE OUTSIDE.

fetchAllSources(Folder, Sources) :-
	fetchAllSourcesAux([Folder], [], Sources).

fetchAllSourcesAux([], X, X) :- X \= [].

fetchAllSourcesAux([File | Fs], X, Y) :-
	exists_directory(File),
	concat(File, '/*', F),
	expand_file_name(F, R),
	append(R, Fs, Remaining),
	removeFromList(File, X, X1),
	append(X1, R, R2),
	fetchAllSourcesAux(Remaining, R2, Y), ! ;
	isSourceFile(File),
	fetchAllSourcesAux(Fs, X, Y), ! ;
	removeFromList(File, X, X1),
	fetchAllSourcesAux(Fs, X1, Y).

isSourceFile(Filename) :-
	wildcard_match('*.{h,c}', Filename).

removeFromList(_, [], []).

removeFromList(E, [E | Re], Re2) :-
	removeFromList(E, Re, Re2), !.

removeFromList(E, [F | Rf], [F | Rf2]) :-
	removeFromList(E, Rf, Rf2).

processAllContents(In) :-
	getFileContents(In, XS), XS \= [] ->
	(findIncludes(_, Res, XS, _), Res \= [], !, write(Res), processAllContents(In) ;
	(findFunctionsProts(_, Res, XS, _), Res \= [], !, write(Res), processAllContents(In))).

getFileContents(In, XS) :-
	getFileContentsAux(In, XS, '', 0).

% parsing = 0, código
% parsing = 1, comentario multilínea
% parsing = 2, comentario línea
% parsing = 3, comentario => hemos encontrado "/"
% parsing = 4, hemos encontrado "#", sigue hasta fin de línea

getFileContentsAux(In, XS, _, 0) :-
	get_char(In, Y),
		(Y = end_of_file -> XS = [], ! ;
		 Y = '/' -> getFileContentsAux(In, XS, Y, 3), ! ;
		 Y = '#' -> getFileContentsAux(In, XS1, Y, 4), char_code(Y, X), XS = [X | XS1], ! ;
		 Y = ';' -> char_code(Y, X), XS = [X], ! ;
		 Y = '\n' -> getFileContentsAux(In, XS, Y, 0), ! ;
		 getFileContentsAux(In, XS1, Y, 0), char_code(Y, X), XS = [X | XS1], !).

getFileContentsAux(In, XS, Prev, 1) :-
	get_char(In, Y),
		(Y = end_of_file -> XS = [], ! ;
		 Prev = '*', Y = '/' -> getFileContentsAux(In, XS, Y, 0), ! ;
		 getFileContentsAux(In, XS, Y, 1), !).

getFileContentsAux(In, XS, _, 2) :-
	get_char(In, Y),
		(Y = end_of_file -> XS = [], ! ;
		 Y = '\n' -> getFileContentsAux(In, XS, Y, 0), ! ;
		 getFileContentsAux(In, XS, Y, 2), !).

getFileContentsAux(In, XS, Prev, 3) :-
	get_char(In, Y),
		(Y = end_of_file -> XS = [], ! ;
		 Y = '*' -> getFileContentsAux(In, XS, Y, 1), ! ;
		 Y = '/' -> getFileContentsAux(In, XS, Y, 2), ! ;
		 getFileContentsAux(In, XS1, Y, 0), char_code(Y, X), XS = [Prev | [X | XS1]], !).

getFileContentsAux(In, XS, _, 4) :-
	get_char(In, Y),
		(Y = end_of_file -> XS = [], ! ;
		 Y = '\n' -> XS = [], ! ;
		 getFileContentsAux(In, XS1, Y, 4), char_code(Y, X), XS = [X | XS1], !).

getFileContentsAux(_, [], _, _).

:- nl,
   write('>> IncludeZilla version 1.0. Usage:'), nl, write('>>'), nl,
   write('>>>  includeZilla(ProjectRootFolder).    Checks whether certain include declarations'), nl,
   write('>>>                                      can be safely removed.'), nl, write('>>>'), nl,
   write('>>>  statistics(ProjectRootFolder).      Generate statistics about which files are the'), nl,
   write('>>>                                      most included ones.'), nl,
   nl.
