:-use_module(library(lists)).
:-use_module(library(clpfd)).
:-use_module(library(random)).

:-include(printer).
:-use_module(list).

%---------- 1. Initiate the matrix ----------

%initRows(ColsCount, OutMatrix)
initRows(_, []).
initRows(ColsCount, [Row|T]):-
	length(Row, ColsCount),
	domain(Row, 0, 1),
	initRows(ColsCount, T).

%initMatrix(+RowsCount, +ColsCount, -OutMatrix)
initMatrix(RowsCount, ColsCount, OutMatrix):-
	length(OutMatrix, RowsCount),
	initRows(ColsCount, OutMatrix).
	
%---------- 1. Initiate the matrix ----------

%---------- 2. Clue Checking ----------

%checkClues(+Clues, +Matrix)
checkClues([], []).
checkClues([ClueH|ClueT], [MatrixH|MatrixT]):-
	checkClue(ClueH, MatrixH),
	checkClues(ClueT, MatrixT).
	
checkClue(x, _):- !.
checkClue(Clue, Matrix):-
	Clue \= x, !,
	sum(Matrix, #=, Clue).
	
%---------- 2. Clue Checking ----------

%---------- 3. Cloud Checking ----------

	%---------- 3.1. Iteration ----------
	
	%checkClouds(+OutMatrix, +OutMatrixTransposed, +RowsCount, +ColsCount)
	checkClouds(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount):-
		checkClouds(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, 1-1).	% entry point
		
	checkClouds(_, _, RowsCount, _, _-Y):-
		Y > RowsCount.	% exiting condition, we are past our last row
		
	checkClouds(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, X-Y):-
		X > ColsCount, % condition to move to the next row
		NewY is Y + 1, % row increment
		checkClouds(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, 1-NewY). % step
		
	checkClouds(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, X-Y):-
		checkCloudsPoint(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, X-Y),
		NewX is X + 1, % column increment
		checkClouds(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, NewX-Y). % step
	
	%checkCloudsPoint(+OutMatrix, +OutMatrixTransposed, +RowsCount, +ColsCount, +X-Y)	
	checkCloudsPoint(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, X-Y):-
		isCorner(OutMatrix, RowsCount, ColsCount, X-Y, IsCorner),						% evaluates if it's a corner
		isCloud(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, X-Y, IsCloud),	% evaluate if it leads to a cloud
		IsCorner #=> IsCloud.															% if it's a corner then it must lead to a cloud, otherwise it doesn't matter
		
	%---------- 3.1. Iteration ----------
	
	%---------- 3.2. Is Corner ----------
	
	%isCorner(+OutMatrix, +RowsCount, +ColsCount, +X-Y, -IsCorner)
	isCorner(OutMatrix, RowsCount, ColsCount, X-Y, IsCorner):-
		Back_X is X - 1,	% previous X value
		Back_Y is Y - 1,	% previous Y value	
		
		isShaded(OutMatrix, RowsCount, ColsCount, X-Y, Shaded),				% current point shading
		isShaded(OutMatrix, RowsCount, ColsCount, Back_X-Y, ShadedLeft),	% left point shading
		isShaded(OutMatrix, RowsCount, ColsCount, X-Back_Y, ShadedUp),		% up point shading
		
		((Shaded #= 1) #/\ (ShadedLeft #= 0) #/\ (ShadedUp #= 0)) #<=> IsCorner.	% if a point is shaded and the points up and left aren't, he is the upper left corner of a cloud
	
	%---------- 3.2. Is Corner ----------
	
	%---------- 3.3. Is Shaded ----------
	
	%isShaded(+OutMatrix, +RowsCount, +ColsCount, +X-Y, -Shaded)
	isShaded(_, RowsCount, ColsCount, X-Y, Shaded):-
		(Y > ColsCount; Y < 1; X > RowsCount; X < 1),	% if it's outside the matrix
		!,
		Shaded is 0.	% then it's an empty space
		
	isShaded(OutMatrix, _, _, X-Y, Shaded):-
		get2DListElement(OutMatrix, Y, X, Shaded).	% gets the color from the matrix
	
	%---------- 3.3. Is Shaded ----------
	
	%---------- 3.4. Row Length ----------
	
	%shadedRowLen(+OutMatrix, +ColsCount, +RowsCount, +X-Y, -Len)
	shadedRowLen(_,ColsCount, _, _-Y,0):-
		Y > ColsCount.
		
	shadedRowLen(OutMatrix, ColsCount, RowsCount, X-Y, Len):-
		isShaded(OutMatrix, RowsCount, ColsCount, X-Y, Shaded),
		
		(Shaded #= 0) #=> (Len #= 0),
		(Shaded #= 1) #=> (Len #= RemainingLen + 1),
		
		Next_Y is Y + 1,
		shadedRowLen(OutMatrix, ColsCount, RowsCount, X-Next_Y, RemainingLen).
	
	%unshadedRowLen(+OutMatrix, +ColsCount, +RowsCount, +X-Y, -Len)
	unshadedRowLen(_,ColsCount, _, _-Y,1):-
		Y > ColsCount.
		
	unshadedRowLen(OutMatrix,ColsCount, RowsCount, X-Y,Len):-
		isShaded(OutMatrix, RowsCount, ColsCount, X-Y, Shaded),
		
		(Shaded #= 1) #=> (Len #= 0),
		(Shaded #= 0) #=> (Len #= RemainingLen + 1),
		
		Next_Y is Y + 1,
		unshadedRowLen(OutMatrix,ColsCount, RowsCount, X-Next_Y,RemainingLen).
	
	%---------- 3.4. Row Len ----------
	
	%---------- 3.5. Cloud interior ----------
	
	%checkInterior(+OutMatrix, +RowsCount, +ColsCount, +X-Y, +Width, -RectLen)
	checkInterior(_,RowsCount,_,X-_,_,0):-
		X > RowsCount.
	checkInterior(OutMatrix,RowsCount,ColsCount,X-Y, Width, RectLen):-
		shadedRowLen(OutMatrix, ColsCount, RowsCount, X-Y, Len), !,
		
		(Width #\= Len) #=> (RectLen #= 0),
		(Width #= Len) #=> (RectLen #= RemainingRectLen + 1),	
	
		Next_X is X + 1,
		checkInterior(OutMatrix, RowsCount, ColsCount, Next_X-Y, Width, RemainingRectLen).
		
	%---------- 3.5. Cloud interior ----------
	
	%---------- 3.6. Is Cloud ----------
	
	%isCloud(+OutMatrix, +OutMatrixTransposed, +RowsCount,+ColsCount, +X-Y, -IsCloud)
	isCloud(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount, X-Y, IsCloud):-
		shadedRowLen(OutMatrix, ColsCount, RowsCount, X-Y, Width), !,
		shadedRowLen(OutMatrixTransposed, RowsCount, ColsCount, Y-X, Height), !,
	
		Back_X is X - 1,
		Back_Y is Y - 1,
		
		unshadedRowLen(OutMatrix,ColsCount,RowsCount,Back_X-Back_Y,BorderWidth), !,
		unshadedRowLen(OutMatrixTransposed,RowsCount,ColsCount,Back_Y-Back_X,BorderHeight), !,
		
		checkInterior(OutMatrix,RowsCount,ColsCount,X-Y,Width,RectHeight),
		checkInterior(OutMatrixTransposed,ColsCount,RowsCount,Y-X,Height,RectWidth),
		
		((Width #>= 2) #/\ (Height #>= 2) #/\
		(BorderWidth #>= Width + 2) #/\ (BorderHeight #>= Height + 2)
		#/\ (Height #= RectHeight) #/\ (Width #= RectWidth))
		#<=> IsCloud.
		
	
	%---------- 3.6. Is Cloud ----------
	
%---------- 3. Cloud Checking ----------

%---------- 4. Solver Loop ----------

%solver(+CluesRow, +CluesColumn, -OutMatrix)
solver(CluesRow, CluesColumn, _OutMatrix):-
	% Get Dimensions
	length(CluesRow, RowsCount),	% get the number of rows
	length(CluesColumn, ColsCount),	% get the number of columns
	
	% Initialize the solution matrix
	initMatrix(RowsCount, ColsCount, OutMatrix),	% initializes the matrix with the given Rows and Columns Count
	
	% Check Clues
	checkClues(CluesRow, OutMatrix),				% checks if the numbers on the clues match the numbers on the matrix for rows
	transpose(OutMatrix, OutMatrixTransposed),		% transposes so that the function checkClues can be reused for columns
	checkClues(CluesColumn, OutMatrixTransposed),	% checks if the numbers on the clues match the numbers on the matrix for columns
	
	% Check Clouds
	checkClouds(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount), !,	% checks if cloud rules are respected
	
	statistics(walltime, _),
	
	% Labeling
	append(OutMatrix, Vars),	% pre labeling step, 2 dimension array to 1 dimension array
	labeling([], Vars),		% labeling
	
	statistics(walltime, [_|[ExecutionTime]]),
    write('Execution took '), write(ExecutionTime), write(' ms.'), nl,
	
	fd_statistics,
	printer(CluesRow, CluesColumn, OutMatrix).
	
%---------- 4. Solver Loop ----------

%---------- 5. Generator Loop ----------

%getCluesRows(-CluesRow, +OutMatrix)
getCluesRows([], []).
getCluesRows([CRH|CRT], [OMH|OMT]):-
	sumlist(OMH, CRH),
	getCluesRows(CRT, OMT).

%startGenerator(+RowsCount, +CluesColumn, -OutMatrix)
startGenerator(RowsCount, CluesColumn, _OutMatrix):-
	statistics(walltime, _),
	generator(RowsCount, CluesColumn, OutMatrix),
	statistics(walltime, [_|[ExecutionTime]]),
    write('Execution took '), write(ExecutionTime), write(' ms.'), nl,
	fd_statistics,
	getCluesRows(CluesRow, OutMatrix),
	printer(CluesRow, CluesColumn, OutMatrix).
	
%generator(+RowsCount, +CluesColumn, -OutMatrix)
generator(RowsCount, CluesColumn, OutMatrix):-
	% Get Dimensions
	length(CluesRow, RowsCount),	% get the number of rows
	length(CluesColumn, ColsCount),	% get the number of columns
	
	% Initialize the solution matrix
	initMatrix(RowsCount, ColsCount, OutMatrix),	% initializes the matrix with the given Rows and Columns Count
	
	% Check Clues
	checkClues(CluesRow, OutMatrix),				% checks if the numbers on the clues match the numbers on the matrix for rows
	transpose(OutMatrix, OutMatrixTransposed),		% transposes so that the function checkClues can be reused for columns
	checkClues(CluesColumn, OutMatrixTransposed),	% checks if the numbers on the clues match the numbers on the matrix for columns
	
	% Check Clouds
	checkClouds(OutMatrix, OutMatrixTransposed, RowsCount, ColsCount),	% checks if cloud rules are respected
	
	% Labeling
	append(OutMatrix, Vars),	% pre labeling step, 2 dimension array to 1 dimension array
	labeling([variable(sel)], Vars).		% labeling
	
generator(RowsCount, CluesColumn, OutMatrix):-
	generator(RowsCount, CluesColumn, OutMatrix).
	
sel(Vars, Selected, Rest) :- random_select(Selected, Vars, Rest), var(Selected).
%---------- 5. Generator Loop ----------

%---------- 6. Tests ----------

	%---------- 6.1. Solver ----------
	
	solverTest1:-
		solver([3,3,0,2,2,0], [2,2,2,2,2], _).
		
	solverTest2:-
		solver([3,3,0,2,2,0], [2,2,0,2,2], _). % no solution
		
	solverTest3:-
		solver([2,2,0,2,2],[2,2,0,2,2], _).
	
	%---------- 6.1. Solver ----------
	
	%---------- 6.2. Generator ----------
	
	generatorTest1:-
		startGenerator(6, [2,2,2,2,2], _).
		
	generatorTest2:-
		startGenerator(7, [2,2,2,0,5,5], _).

	%---------- 6.2. Generator ----------

%---------- 6. Tests ----------