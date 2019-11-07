%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 11月 2019 16:12
%%%-------------------------------------------------------------------
-module(handle_login).
-author("Administrator").

-include("hrl_logs.hrl").
-include("proto_pb.hrl").

%% API
-export([handle_msg/2,
    handle_evt/3]).

handle_msg(#'C0000001'{} = Req, State) ->
    State1 =
    {noreply, State};

handle_msg(_Msg, State) ->
    ?WARNING("unhandle msg ~p", [_Msg]),
    {noreply, State}.


handle_evt(_ID, _Msg, State) ->
    ?WARNING("unhandle evt ID:~p, Msg:~w", [_ID, _Msg]),
    {noreply, State}.
