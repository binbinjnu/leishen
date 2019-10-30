%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 10月 2019 9:39
%%%-------------------------------------------------------------------
-module(util).
-author("Administrator").

%% API
-export([
    rand/2,
    term_to_string/1,
    get_call_from/0
]).

rand(Same, Same) ->
    Same;
rand(Min, Max) ->
    M = Min - 1,
    rand:uniform(Max - M) + M.

get_call_from() ->
    lists:sublist(get_call_stack(), 3, 1).

get_call_stack() ->
    try
        throw(get_call_stack)
    catch
        get_call_stack ->
            Trace1 =
                case erlang:get_stacktrace() of
                    [_|Trace] -> Trace;
                    Trace -> Trace
                end,
            empty_stacktrace(),
            [stack_format(S) || S <- Trace1]
    end.

empty_stacktrace() ->
    try
        erlang:raise(throw, clear, [])
    catch
        _ ->
            ok
    end.

stack_format({M, F, A, Info}) when is_list(A) ->
    A1 = lists:sublist(term_to_string(A), 40),
    case lists:keyfind(line, 1, Info) of
        {_, Line} ->
            {M, F, Line, A1};
        _ ->
            {M, F, A1}
    end;
stack_format({M, F, _A, Info}) ->
    case lists:keyfind(line, 1, Info) of
        {_, Line} ->
            {M, F, Line};
        _ ->
            {M, F}
    end.

term_to_string(Term) ->
    lists:flatten(io_lib:format("~9999999p", [Term])).