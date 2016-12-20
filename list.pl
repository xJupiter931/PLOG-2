:- module(list, [setListElement/4, getListElement/3, getListSize/2, countElement/3, set2DListElement/5, get2DListElement/4]).

:- use_module(library(lists)).

% Listas

% Setter (+, +, +, -)
setListElement([_|T], 0, Element, [Element|T]).
setListElement([H|T], Index, Element, [H|BoardOutTail]):-
  Index > 0,
  Next is Index-1,
  setListElement(T, Next, Element, BoardOutTail).

% Getter (+, +, -)
getListElement(List, Index, Element):-
  nth0(Index, List, Element).

% Utility
% getListSize(+, -) Devolve o tamanho da lista
getListSize(List, OutputSize):-
 length(List, OutputSize).

% countElement(+, +, -) Recebe uma lista e um elemento e devolve a frequência de ocorrência desse elemento na lista
countElement([], _, 0).
countElement([Element|T], Element, Frequency):-
  countElement(T, Element, SubFrequency),
  Frequency is SubFrequency + 1.
countElement([_|T], Element, Frequency):-
  countElement(T, Element, Frequency).

% Listas bidimensionais

% Setter (+, +, +, +, -)
set2DListElement([InHead|InTail], XPos, 0, Element, [OutHead|InTail]):-
  setListElement(InHead, XPos, Element, OutHead).
set2DListElement([InHead|InTail], XPos, YPos, Element, [InHead|OutTail]):-
  YPos > 0,
  Next is YPos - 1,
  set2DListElement(InTail, XPos, Next, Element, OutTail).

% Getter (+, +, +, -)
get2DListElement(List, XPos, YPos, Element):-
  nth0(YPos, List, SubList),
  getListElement(SubList, XPos, Element).
