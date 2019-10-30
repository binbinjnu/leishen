%%%-------------------------------------------------------------------
%% @doc leishen public API
%% @end
%%%-------------------------------------------------------------------

-module(leishen_app).

-behaviour(application).

-include("hrl_logs.hrl").
-include("hrl_common.hrl").

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ok = pre_start(),
    leishen_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
pre_start() ->
    xref_check(),
    ?NOTICE("after xref check!", []),
    ok.


-ifdef(DEBUG).
xref_check() ->
    ok.

-else.
xref_check() ->
    case xref:d("../ebin") of
        [_, {undefined, []}|_] ->
            ?INFO("Xref check ok", []),
            ok;
        [_, Undef|_] ->
            ?WARNING("Xref check fail: ~p", [Undef]),
            io:format("Xref check fail: ~p~n~n", [Undef]),
            erlang:error(xref_check_fail)
    end.


-endif.