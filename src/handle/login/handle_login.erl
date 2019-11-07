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
-include("hrl_proto.hrl").
-include("login_pb.hrl").

%% API
-export([handle_msg/3,
    handle_evt/3]).

handle_msg(?c2s_heartbeat, #c2s_heartbeat{}, State) ->
    Now = util_time:long_unixtime(),
    Msg = #s2c_heartbeat{timestamp = Now},
    %% 为了保证延迟尽量短, 心跳包直接send flush
    net_api:send_flush(self(), Msg),
    %% todo 心跳包统计
    {noreply, State};

handle_msg(_ID, _Msg, State) ->
    ?WARNING("unhandle msg ~p, ~p", [_ID, _Msg]),
    {noreply, State}.


handle_evt(_ID, _, State) ->
    ?WARNING("unhandle evt ~p", [_ID]),
    {noreply, State}.
