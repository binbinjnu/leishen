%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 10月 2019 9:24
%%%-------------------------------------------------------------------
-module(net_api).
-author("Administrator").

-include("hrl_logs.hrl").

%% API
-export([
    start_listener/4,
    stop_listener/1
]).


%%-spec start_listener(atom(), non_neg_integer(), non_neg_integer(), atom()) ->
%%    {ok, pid()} | {error, badarg}.
start_listener(Ref, NumAcceptors, Port, Handler) ->
    case ranch:start_listener(Ref, NumAcceptors, ranch_tcp, [{port, Port}], net_protocol, [Handler]) of
        {ok, Pid} ->
            ranch:set_max_connections(Ref, infinity),
            ?NOTICE("~p listen on tcp ~p", [Ref, Port]),
            {ok, Pid};
        Err ->
            Err
    end.

%%-spec stop_listener(Ref) -> ok | {error, not_found} when
%%    Ref :: atom().
stop_listener(Ref) ->
    ranch:stop_listener(Ref).
