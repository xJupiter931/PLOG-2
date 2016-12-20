:-use_module(library(lists)).
:-use_module(library(clpfd)).
:-use_module(list).

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
	
	%checkClouds(+OutMatrix, +OutMatrixTransposed, +RowLen, +ColLen)
	checkClouds(OutMatrix, OutMatrixTransposed, RowLen, ColLen):-
		checkClouds(OutMatrix, OutMatrixTransposed, RowLen, ColLen, 1-1).	% entry point
		
	checkClouds(_, _, RowLen, _, X-_):-
		X > RowLen.	% exiting condition, we reached our last row
		
	checkClouds(OutMatrix, OutMatrixTransposed, RowLen, ColLen, X-Y):-
		Y > ColLen, % condition to move to the next row
		NewX is X + 1, % row increment
		checkClouds(OutMatrix, OutMatrixTransposed, RowLen, ColLen, NewX-1). % step
		
	checkClouds(OutMatrix, OutMatrixTransposed, RowLen, ColLen, X-Y):-
		checkCloudPoint(OutMatrix, OutMatrixTransposed, RowLen, ColLen, X-Y),
		NewY is Y + 1, % column increment
		checkClouds(OutMatrix, OutMatrixTransposed, RowLen, ColLen, X-NewY). % step
		
	%---------- 3.1. Iteration ----------
	
	%---------- 3.2. Is Shaded ----------
	
	%isShaded(+OutMatrix, +RowLen, +ColLen, +X-Y, -Shaded)
	
	isShaded(_, RowLen, ColLen, X-Y, Shaded):-
		(X > RowLen; X < 1; Y > ColLen; Y < 1),
		!,
		Shaded is 0.
		
	isShaded(OutMatrix, _, _, X-Y, Shaded):-
		get2DListElement(OutMatrix, X, Y, Shaded).
	
	%---------- 3.2. Is Shaded ----------
	
	%---------- 3.3. Is Corner ----------
	
	isCorner(OutMatrix, RowLen, ColLen, X-Y, IsCorner):-
		Back_X is X - 1,
		Back_Y is Y - 1,
		
		isShaded(OutMatrix, RowLen, ColLen, X-Y, Shaded),
		isShaded(OutMatrix, RowLen, ColLen, Back_X-Y, ShadedLeft),
		isShaded(OutMatrix, RowLen, ColLen, X-Back_Y, ShadedUp),
		
		((Shaded #= 1) #/\ (ShadedLeft #= 0) #/\ (ShadedUp #= 0)) #<=> IsCorner.
	
	%---------- 3.3. Is Corner ----------
	
	%---------- 3.4. Is Cloud ----------
	
	isCloud(IsCloud):-
		write('Checking if it is a cloud'), nl,
		IsCloud is 1.
	
	%---------- 3.4. Is Cloud ----------
	
	checkCloudPoint(OutMatrix, OutMatrixTransposed, RowLen, ColLen, X-Y):-
		isCorner(OutMatrix, RowLen, ColLen, X-Y, IsCorner),
		checkCloudPoint(OutMatrix, OutMatrixTransposed, RowLen, ColLen, X-Y, IsCorner).
		
	checkCloudPoint(_, _, _, _, _, 0):-
		write('Not a corner'), nl.
		
	checkCloudPoint(OutMatrix, OutMatrixTransposed, RowLen, ColLen, X-Y, 1):-
		write('A corner'), nl,
		isCloud(IsCloud),
		IsCloud #= 1.
		
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
	checkClouds(OutMatrix, OutMatrixTransposed, RowLen, ColLen),			% checks if cloud rules are respected
	
	append(OutMatrix, Vars),
	labeling([], Vars).