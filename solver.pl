:-use_module(library(lists)).
:-use_module(library(clpfd)).

%---------- 1. Initiate the matrix ----------

%initLines(ColLen, OutMatrix)
initLines(_, []).
initLines(ColLen, [Row|T]):-
	length(Row, ColLen),
	domain(Row, 0, 1),
	initLines(ColLen, T).

%initMatrix(+RowLen, +ColLen, -OutMatrix)
initMatrix(RowLen, ColLen, OutMatrix):-
	length(OutMatrix, RowLen),
	initLines(ColLen, OutMatrix).
	
%---------- 1. Initiate the matrix ----------

%---------- 2. Clue Checking ----------

%checkClues(+Clues, +Matrix)
checkClues([], []).
checkClues([ClueH|ClueT], [MatrixH|MatrixT]):-
	sum(MatrixH, #=, ClueH),
	checkClues(ClueT, MatrixT).
	
%---------- 2. Clue Checking ----------

%---------- 3. Cloud Checking ----------

	%---------- 3.1. Iteration ----------
	
	%checkClouds(+OutMatrix, +RowLen, +ColLen)
	checkClouds(OutMatrix, RowLen, ColLen):-
		checkClouds(OutMatrix, RowLen, ColLen, 1-1).	% entry point
		
	checkClouds(_, RowLen, _, X-_):-
		X > RowLen.	% exiting condition, we reached our last row
		
	checkClouds(OutMatrix, RowLen, ColLen, X-Y):-
		Y > ColLen, % condition to move to the next row
		NewX is X + 1, % row increment
		checkClouds(OutMatrix, RowLen, ColLen, NewX-1). % step
		
	checkClouds(OutMatrix, RowLen, ColLen, X-Y):-
		write(X-Y), nl,
		NewY is Y + 1, % column increment
		checkClouds(OutMatrix, RowLen, ColLen, X-NewY). % step
		
	%---------- 3.1. Iteration ----------
	

%---------- 3. Cloud Checking ----------

%solver(+CluesRow, +CluesColumn, -OutMatrix)
solver(CluesRow, CluesColumn, OutMatrix):-
	% Get Dimensions
	length(CluesRow, RowLen),		% get the number of lines
	length(CluesColumn, ColLen),	% get the number of columns
	
	% Initialize the solution matrix
	initMatrix(RowLen, ColLen, OutMatrix),
	
	% Check Clues
	checkClues(CluesRow, OutMatrix),				% checks if the numbers on the clues match the numbers on the matrix for rows
	transpose(OutMatrix, OutMatrixTransposed),		% transposes so that the function checkClues can be reused for columns
	checkClues(CluesColumn, OutMatrixTransposed),	% checks if the numbers on the clues match the numbers on the matrix for columns
	
	% Check Clouds
	checkClouds(OutMatrix, RowLen, ColLen),			% checks if cloud rules are respected
	
	append(OutMatrix, Vars),
	labeling([], Vars).