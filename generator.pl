:-use_module(library(lists)).
:-use_module(library(clpfd)).

:-use_module(solver).
	
%generator(+RowsCount, +ColsCount, +CloudsCount, -CluesRow, -CluesColumn)
generator(RowsCount, ColsCount, CloudsCount, CluesRow, CluesColumn).
	