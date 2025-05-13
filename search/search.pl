% search.pl

% Search entry point
search(Actions) :-
    initial(Start),
    treasure(Goal),
    bfs([[state(Start, [], [])]], Goal, ActionsRev),
    reverse(ActionsRev, Actions).

% BFS implementation: Queue of paths with state(CurrentRoom, KeysHeld, Actions)
bfs([[state(Room, Keys, Actions) | _] | _], Room, Actions). % Goal reached
bfs([Path | Rest], Goal, Solution) :-
    Path = [state(Room, Keys, Actions) | _],
    findall(NextState,
            next_state(state(Room, Keys, Actions), NextState),
            NextStates),
    extend_paths(NextStates, Path, NewPaths),
    append(Rest, NewPaths, UpdatedQueue),
    bfs(UpdatedQueue, Goal, Solution).

% Extend path: avoid revisiting same room with same key set
extend_paths([], _, []).
extend_paths([state(R, K, A)|T], [state(_, _, _)|PathTail], [[state(R, K, A), state(_, _, _)|PathTail]|Rest]) :-
    \+ member(state(R, K, _), [state(_, _, _)|PathTail]), % avoid cycles
    extend_paths(T, [state(_, _, _)|PathTail], Rest).
extend_paths([_|T], P, Rest) :- extend_paths(T, P, Rest).

% Possible next states: move through open doors, unlock doors if key held, pick up keys
next_state(state(Room, Keys, Actions), state(NextRoom, Keys, [move(Room, NextRoom)|Actions])) :-
    door(Room, NextRoom);
    door(NextRoom, Room),
    \+ member(move(Room, NextRoom), Actions),
    \+ member(move(NextRoom, Room), Actions).

next_state(state(Room, Keys, Actions), state(NextRoom, Keys, [unlock(Room, NextRoom, Color), move(Room, NextRoom)|Actions])) :-
    locked_door(Room, NextRoom, Color);
    locked_door(NextRoom, Room, Color),
    member(Color, Keys),
    \+ member(move(Room, NextRoom), Actions),
    \+ member(move(NextRoom, Room), Actions).

next_state(state(Room, Keys, Actions), state(Room, [Color|Keys], Actions)) :-
    key(Room, Color),
    \+ member(Color, Keys).
