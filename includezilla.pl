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

%% PUBLIC RULES.

includeZilla(ProjectRoot) :-
	open(ProjectRoot, read, In),
	getFileContents(In, Contents),
	process(Contents),
	close(In).

%% PRIVATE RULES. NOT MEANT TO BE USED FROM THE OUTSIDE.

process(end-of-file) :-
	!.

process(Contents) :-
	findIncludes(0, Contents, 0, Res), Res \= 0.

findIncludes(_, [], Curr, Curr) :- !.

findIncludes(Matches, [C | Rc], Curr, Res) :-
	Matches = 0, C = '#', !, findIncludes(1, Rc, Curr, Res) ;
	Matches = 1, C = ' ', !, findIncludes(1, Rc, Curr, Res) ;
	Matches = 1, C = 'i', !, findIncludes(2, Rc, Curr, Res) ;
	Matches = 2, C = 'n', !, findIncludes(3, Rc, Curr, Res) ;
	Matches = 3, C = 'c', !, findIncludes(4, Rc, Curr, Res) ;
	Matches = 4, C = 'l', !, findIncludes(5, Rc, Curr, Res) ;
	Matches = 5, C = 'u', !, findIncludes(6, Rc, Curr, Res) ;
	Matches = 6, C = 'd', !, findIncludes(7, Rc, Curr, Res) ;
	Matches = 7, C = 'e', !, Next is Curr + 1, findIncludes(8, Rc, Next, Res) ;
	Matches = 8, parseInclude([C | Rc], false, [], Include), write('Header found: '), write(Include), nl, fail ;
	findIncludes(0, Rc, Curr, Res).

parseInclude([C | _], Accumulate, Accum, Accum) :-
	C = '"', Accumulate, !.

parseInclude([C | _], Accumulate, Accum, Accum) :-
	C = '>', Accumulate, !.

parseInclude([C | Rc], Accumulate, Accum, Include) :-
	C = ' ', \+ Accumulate, !, parseInclude(Rc, false, Accum, Include) ;
	C = '"', \+ Accumulate, !, parseInclude(Rc, true, Accum, Include) ;
	C = '<', \+ Accumulate, !, parseInclude(Rc, true, Accum, Include) ;
	append(Accum, [C], R),
	parseInclude(Rc, true, R, Include).

% getFileContents taken from:
% http://gollem.swi.psy.uva.nl/SWI-Prolog/mailinglist/archive/old/0517.html
%
% Author: José Romildo Malaquias
getFileContents(In, XS) :-
    get_char(In, X),
    (X = end_of_file ->
         XS = [] ;
		 getFileContents(In, XS1), XS = [X | XS1]
    ).
