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
% Separate out the cases for opening and closing brackets.
compile([$[|R], P, M, T) ->
    {P2,M2} = interpret($[, P, M),
    compile(R, P2, M2, [R] ++ T);
compile([$]|R], P, M, T) ->
    [Pop|Stack] = T,
    {Tape, ToParse} = case get_value(P,M) of
                            % If P value reached 0 -> step out
                            0 -> {Stack, R};
                            _ -> {T,Pop}
                        end,
    {P2,M2} = interpret($], P, M),
    compile(ToParse, P2, M2, Tape);
compile([H|R], P, M, T) ->
    {P2,M2} = interpret(H, P, M),
    compile(R, P2, M2, T).

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
