% search.pl - Final version matching reference outputs exactly

% Search entry point
search(Actions) :-
    initial(Start),
    treasure(Goal),
    bfs([[state(Start, [], [])]], Goal, [], ActionsRev),
    reverse(ActionsRev, Actions).

% BFS implementation
bfs([[state(Room, _, Actions) | _] | _], Room, _, Actions). % Goal reached
bfs([Path | Rest], Goal, Visited, Solution) :-
    Path = [state(Room, Keys, Actions) | _],
    findall(NextState,
            (next_state(state(Room, Keys, Actions), NextState),
             \+ member(NextState, Visited)),
            NextStates),
    extend_paths(NextStates, Path, Visited, NewPaths, UpdatedVisited),
    append(Rest, NewPaths, UpdatedQueue),
    bfs(UpdatedQueue, Goal, UpdatedVisited, Solution).

% Extend paths
extend_paths([], _, Visited, [], Visited).
extend_paths([State|T], Path, Visited, [NewPath|RestPaths], NewVisited) :-
    State = state(_, _, _),
    Path = [state(_, _, _)|_],
    NewPath = [State|Path],
    extend_paths(T, Path, [State|Visited], RestPaths, NewVisited).

% Possible next states - matching reference format exactly
next_state(state(Room, Keys, Actions), state(NextRoom, Keys, [move(Room, NextRoom)|Actions])) :-
    (door(Room, NextRoom); door(NextRoom, Room)),
    NextRoom \= Room.

next_state(state(Room, Keys, Actions), state(NextRoom, Keys, [move(Room, NextRoom), unlock(Color)|Actions])) :-
    (locked_door(Room, NextRoom, Color); locked_door(NextRoom, Room, Color)),
    member(Color, Keys).

next_state(state(Room, Keys, Actions), state(Room, [Color|Keys], Actions)) :-
    key(Room, Color),
    \+ member(Color, Keys).