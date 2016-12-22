%printer(+CluesRow, +CluesColumn, +SolutionMatrix)

printer([], CluesColumn, []):-
	nl, write('   '),
	printColumns(CluesColumn).
printer([CRH|CRT], CluesColumn, [SMH|SMT]):-
	write(CRH), write('  '), printLine(SMH), nl,
	printer(CRT, CluesColumn, SMT).

printColumns([]).
printColumns([CCH|CCT]):-
	write(CCH),
	printColumns(CCT).
	
printLine([]).
printLine([H|T]):-
	printCell(H),
	printLine(T).
	
printCell(0):-
	write('O').
printCell(1):-
	write('X').

test:-
	printer([1,0],[1,0],[[1,0],[0,0]]).