%% Brainfuck interpreter in Erlang.
%% ================================
%%
%%
-module(bf).
-export([
    compile/1,
    example/0,
    example2/0
]).

% Read in the stream of code
compile([]) -> io:format("[]");
compile([H|T]) ->
    {P,M} = interpret(H, 1, [0]),
    compile(T, P, M, []).

compile([], _, M, _) -> io:format("~p", [M]);
% Head, Rest, Pointer, Mempory, Tape
compile([H|R], P, M, T) ->
    %io:format("H: ~p;R: ~p; P: ~p; M: ~p; T: ~p", [H,R,P,M,T]),
    {Tape, ToParse} = case H of
                    $[ -> 
                        % Do this till the closing matching bracket
                        T2 = [R] ++ T,
                        {T2, R};
                    $] ->
                        % Check if we can step out
                        case get_value(P,M) of
                            % If P value reached 0 -> step out
                            0 -> 
                                [_|Stack] = T,
                                {Stack, R};
                            _ -> 
                                [Pop|_] = T,
                                {T,Pop}
                        end;
                    _ ->
                        {T, R}
               end,
    io:format("Tape: ~p; ToParse: ~p", [Tape,ToParse]),
    {P2,M2} = interpret(H, P, M),
    compile(ToParse, P2, M2, Tape).

% Trying to interpret the character
% Memory is represented as a list.
interpret($>, Pointer, Memory) ->
    NewPointer = Pointer + 1,
    NewMemory = check_pointer(NewPointer, Memory),
    {NewPointer, NewMemory};
interpret($<, Pointer, Memory) ->
    NewPointer = Pointer - 1,
    NewMemory = check_pointer(NewPointer, Memory),
    {NewPointer, NewMemory};
interpret($+, Pointer, Memory) ->
    NewMemory = increment(Pointer, Memory),
    {Pointer, NewMemory};
interpret($-, Pointer, Memory) ->
    NewMemory = decrement(Pointer, Memory),
    {Pointer, NewMemory};
interpret($., Pointer, Memory) ->
    io:format("~c", [get_value(Pointer, Memory)]),
    {Pointer, Memory};
interpret($,, Pointer, Memory) ->
    NewValue = io:get_chars("bf> ", 1),
    NewMemory = set_value(Pointer, Memory, NewValue),
    {Pointer, NewMemory};
% Ignore all other characters
interpret(_, Pointer, Memory) ->
    io:format("~n"),
    {Pointer, Memory}.

%
% Update the value in the binary Memory
%
decrement(Pointer,Memory) ->
    {Head, Value, Rest} = extract_memory(Pointer, Memory),
    Head ++ [Value - 1] ++ Rest.

increment(Pointer, Memory) ->
    {Head, Value, Rest} = extract_memory(Pointer, Memory),
    Head ++ [Value + 1] ++ Rest.

%
% Check the existence of the pointer
% If not there - create one.
%
check_pointer(Pointer, Memory) ->
    if 
        length(Memory) < Pointer -> Memory ++ [0];
        true -> Memory
    end.

%
% Return the value at the pointer
%
get_value(Pointer, Memory) ->
    {_, Value, _} = extract_memory(Pointer, Memory),
    Value.

%
% Return the value at the pointer
%
set_value(Pointer, Memory, NewValue) ->
    {Head, _, Rest} = extract_memory(Pointer, Memory),
    Head ++ [NewValue] ++ Rest.

%
% Split the memory
extract_memory(Pointer, Memory) ->
    HeadCount = Pointer - 1,
    case Memory of 
        [First] -> {[], First, []};
        _ ->
            {Head, [Value|Rest]} = lists:split(HeadCount, Memory),
            {Head, Value, Rest}
    end.

%% Start the program
example() ->
    compile(
        "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>."
    ).

% Example with nested loops
example2() ->
    compile(
        "++[>++[>++>++<<-.]<-.]"
    ).
