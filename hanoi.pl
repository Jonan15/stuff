/* MAIN PREDICATE */

% hanoi(N) simulates the Hanoi puzzle with N disks

hanoi(N) :- setup(N,S),
	    solve(N,from(1,2,3),L),
	    simulate(S,L,N).

/* COMPUTING THE SOLUTION */

% solve(N,from(A,B,C),L) returns in L the sequence of individual moves
% to bring N disks from needle A to needle B, using needle C as an
% auxiliary

solve(0,_,[]).
solve(N,from(A,B,C),L) :- N>0, K is N-1,
			  solve(K,from(A,C,B),L1),
			  solve(K,from(C,B,A),L2),
			  append(L1,[move(A,B)|L2],L).

% append(L1,L2,L3) holds if L3 is obtained by appending L1 and L2
append([],L,L).
append([X|L1],L2,[X|L3]) :- append(L1,L2,L3).

/* SIMULATION */

% We model the state as a triple state(S1,S2,S3) contaning three
% stacks of disks

% setup(N,S) holds if S is the initial state (N disks in stack S1)

setup(N,state(T,empty,empty)) :- populate(N,empty,T).

% populate(N,S,T) adds disks N..1 to S, returning the result in T

populate(0,T,T).
populate(N,T,R) :- N>0, K is N-1, populate(K,push(N,T),R).

% simulate(SIn,move(A,B),SOut) moves one disk from needle A to needle B

simulate(SIn,move(A,B),SOut) :- pop(A,SIn,D,SMid),
				push(B,SMid,D,SOut).

% simulate(S,L,N) executes the sequence of moves in L from state S;
% there is no overlap with the previous definition, as lists and moves
% are syntactically distinct.
% The call to show is simply to print the state to the output stream.

simulate(S,[],N) :- show(S,N).
simulate(S,[M|L],N) :- show(S,N),
		       simulate(S,M,SNew),
		       simulate(SNew,L,N).

% elementary operations

pop(1,state(push(D,TA),TB,TC),D,state(TA,TB,TC)).
pop(2,state(TA,push(D,TB),TC),D,state(TA,TB,TC)).
pop(3,state(TA,TB,push(D,TC)),D,state(TA,TB,TC)).

push(1,state(TA,TB,TC),D,state(push(D,TA),TB,TC)).
push(2,state(TA,TB,TC),D,state(TA,push(D,TB),TC)).
push(3,state(TA,TB,TC),D,state(TA,TB,push(D,TC))).

% alternatively, we could have defined
% push(N,SIn,D,SOut) :- pop(N,SOut,D,Sin).

/* PRETTY-PRINTING FUNCTIONS */

% show(S,N) formats state S before printing

show(state(A,B,C),N) :- fill(A,N,AF), fill(B,N,BF), fill(C,N,CF),
			view(state(AF,BF,CF)).

% fill(SIn,N,SOut) holds if SOut is a zero-padded version of SIn with
% N elements

fill(S,N,S) :- size(S,N).
fill(S,N,push(0,R)) :- N>0, K is N-1, fill(S,K,R).

% size(S,N) holds if stack S has N elements
size(empty,0).
size(push(_X,S),N) :- size(S,K), N is K+1.

% the padded stacks are printed in parallel, with a line at the end
view(state(empty,empty,empty)) :- writeln('----------------------------------------------------').

view(state(push(A,SA),push(B,SB),push(C,SC))) :- view(A,AV), view(B,BV), view(C,CV),
						 write(AV), write('   '),
						 write(BV), write('   '),
						 write(CV), write('   '), nl,
						 view(state(SA,SB,SC)).

% pretty-printing rules for the individual disks
view(0,'       |       ').
view(1,'      |1|      ').
view(2,'     | 2 |     ').
view(3,'    |  3  |    ').
view(4,'   |   4   |   ').
view(5,'  |    5    |  ').
view(6,' |     6     | ').
view(7,'|      7      |').
