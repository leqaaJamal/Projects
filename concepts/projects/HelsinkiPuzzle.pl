grid_build(N,M):-
    length(M,N),matrix(N,M).
matrix(_,[]).
matrix(N,[H|T]):-
    length(H,N),matrix(N,T).
numGen(L,U,[]):-
    L>U.
numGen(L,U,[H|T]):-
    L=<U,
    H=L,
    L1 is L+1,
    numGen(L1,U,T).
grid_gen(N,M):-
    grid_gen2(N,N,M),check_num_grid(M).
grid_gen2(0,_,[]).
grid_gen2(N,N2,[H|T]):-

    N>0,N1 is N-1,numGen(1,N2,R),matrix_gen(H,N2,R),grid_gen2(N1,N2,T).
matrix_gen([],0,_).
matrix_gen([H|T],N,R):-
    N>0 ,N2 is N-1,member(H,R),matrix_gen(T,N2,R).

num_gen(L,U,[H|T]):-numGen(L,U,[H|T]).
max(M,N,Max):- M>N,Max=M.
max(M,N,Max):- M=<N , Max=N.
getMaxList([H],M,Max):- max(H,M,Max).
getMaxList([H|T],M,Max):-
          T\=[],
           max(H,M,Max1),
           getMaxList(T,Max1,Max).
getMaxLG([],[]).
getMaxLG([H|T],[H1|T1]):-
    getMaxList(H,0,H1),getMaxLG(T,T1).
getMaxGrid([H|T],Max):-
    getMaxLG([H|T],L),getMaxList(L,0,Max).
check_num_grid(G):-
    getMaxGrid(G,Max),num_gen(1,Max,R),helper1(G,R).
helper1(_,[]).
helper1(G,[H|T]):-
    helper2(G,H),helper1(G,T).
helper2([[N|_]|_],N).
helper2([[]|T],N):-helper2(T,N).
helper2([[N1|T1]|T],N):-N1\=N,helper2([T1|T],N).

trans(G,T):- transHelper2(G,[],T).
transHelper2([[]|_],R,R).
transHelper2([H|T],A,R):-
    transHelper([H|T],[],[],R1,R2),append(A,[R1],A2),transHelper2(R2,A2,R).
transHelper([],A1,A2,A1,A2).
transHelper([[H|T]|T1],Aheads,Atails,R1,R2):-
    append(Aheads,[H],Aheads1),append(Atails,[T],Atails1),transHelper(T1,Aheads1,Atails1,R1,R2).

acceptable_distribution(G):-
    trans(G,T),acceptable_distributionH(G,T).
acceptable_distributionH([],[]).
acceptable_distributionH([H|T],[H1|T1]):-
    H\=H1,acceptable_distributionH(T,T1).
distinct_rows([]).
distinct_rows([H|T]) :-
    rowsH(H,T),
    distinct_rows(T).

rowsH(_,[]).
rowsH(H,[H1|T1]):-
    H\=H1,
    rowsH(H,T1).


distinct_columns(M):- 
    trans(M,T) , distinct_rows(T).

row_col_match(M):- 
    trans(M,T) , rowcolH(M,T), acceptable_distribution(M).
rowcolH([],_).
rowcolH([H|T1],T):-  member(H,T),rowcolH(T1,T).

acceptable_permutation([H|T],R):-
    permutation([H|T],R),check_acceptable([H|T],R).
check_acceptable([],[]).
check_acceptable([H|T],[H1|T1]):-
    H \= H1, check_acceptable(T,T1).

helsinki(N,G):- 
    grid_build(N,G) , 
    grid_gen(N,G) , 
    check_num_grid(G) , 
    acceptable_distribution(G) ,
    distinct_rows(G) ,
    distinct_columns(G) ,
    row_col_match(G).