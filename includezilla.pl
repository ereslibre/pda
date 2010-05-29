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
	getFileContents(In, Contents),
	write(Contents).
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

getFileContents(In, XS) :-
	getFileContentsAux(In, XS, " ", 0).

% parsing = 0, código
% parsing = 1, comentario multilínea
% parsing = 2, comentario línea
% parsing = 3, comentario => hemos encontrado "/"
getFileContentsAux2([X | Xs], XS, Prev, 0) :-
	member(X, "/") -> getFileContentsAux2(Xs, XS, X, 3), ! ;
	getFileContentsAux2(Xs, XS1, X, 0), !, XS = [X | XS1].

getFileContentsAux2([X | Xs], XS, Prev, 1) :-
	member(Prev,  "*"), member(X, "/") -> getFileContentsAux2(Xs, XS, X, 0), ! ;
	getFileContentsAux2(Xs, XS, X, 1), !.

getFileContentsAux2([X | Xs], XS, Prev, 2) :-
	member(X, "\n") -> getFileContentsAux2(Xs, XS, X, 0), ! ;
	getFileContentsAux2(Xs, XS, X, 2), !.

getFileContentsAux2([X | Xs], XS, Prev, 3) :-
	member(X, "*") -> getFileContentsAux2(Xs, XS, X, 1), ! ;
	member(X, "/") -> getFileContentsAux2(Xs, XS, X, 2), ! ;
	getFileContentsAux2(Xs, XS1, X, 0), !, XS = [Prev | [X | [XS1]]].

getFileContentsAux2([], [], _, _).

:- nl,
   write('>> IncludeZilla version 1.0. Usage:'), nl, write('>>'), nl,
   write('>>>  includeZilla(ProjectRootFolder).    Checks whether certain include declarations'), nl,
   write('>>>                                      can be safely removed.'), nl, write('>>>'), nl,
   write('>>>  statistics(ProjectRootFolder).      Generate statistics about which files are the'), nl,
   write('>>>                                      most included ones.'), nl,
   nl.