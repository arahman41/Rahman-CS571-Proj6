% search.pl - Corrected implementation

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
            NextStates),
    extend_paths(NextStates, Path, Visited, NewPaths, UpdatedVisited),
    append(Rest, NewPaths, UpdatedQueue),
    bfs(UpdatedQueue, Goal, UpdatedVisited, Solution).

% Extend paths with cycle detection
extend_paths([], _, Visited, [], Visited).
extend_paths([state(R, K, A)|T], Path, Visited, [NewPath|RestPaths], NewVisited) :-
    Path = [state(_, _, _)|_],
    NewPath = [state(R, K, A)|Path],
    \+ member(state(R, K), Visited), % Only check room and keys for cycles
    extend_paths(T, Path, [state(R, K)|Visited], RestPaths, NewVisited).
extend_paths([_|T], Path, Visited, RestPaths, NewVisited) :-
    extend_paths(T, Path, Visited, RestPaths, NewVisited).

% Possible next states
next_state(state(Room, Keys, Actions)) :-
    % Move through regular door
    (door(Room, NextRoom); door(NextRoom, Room)),
    NextRoom \= Room,
    state(NextRoom, Keys, [move(Room, NextRoom)|Actions]).

next_state(state(Room, Keys, Actions)) :-
    % Unlock and move through locked door
    (locked_door(Room, NextRoom, Color); locked_door(NextRoom, Room, Color)),
    member(Color, Keys),
    state(NextRoom, Keys, [unlock(Room, NextRoom, Color), move(Room, NextRoom)|Actions]).

next_state(state(Room, Keys, Actions)) :-
    % Pick up key
    key(Room, Color),
    \+ member(Color, Keys),
    state(Room, [Color|Keys], Actions).