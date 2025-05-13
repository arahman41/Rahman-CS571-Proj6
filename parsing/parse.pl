% Entry point
parse(Tokens) :- lines(Tokens, []).

% Lines → Line ; Lines
%       | Line
lines(Input, Rest) :-
    line(Input, Temp),
    ( Temp = [';' | Remaining], lines(Remaining, Rest)
    ; Rest = Temp ).

% Line → Num , Line
%       | Num
line(Input, Rest) :-
    num(Input, Temp),
    ( Temp = [',' | Remaining], line(Remaining, Rest)
    ; Rest = Temp ).

% Num → Digit Num
%     | Digit
num([D | Rest], Remaining) :-
    digit(D),
    ( num(Rest, Remaining)
    ; Remaining = Rest ).

% Digit → '0' ... '9'
digit('0').
digit('1').
digit('2').
digit('3').
digit('4').
digit('5').
digit('6').
digit('7').
digit('8').
digit('9').
