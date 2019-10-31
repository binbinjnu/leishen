%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%     网络路由
%%% @end
%%% Created : 30. 10月 2019 20:24
%%%-------------------------------------------------------------------
-module(net_route).
-author("Administrator").

%% API
-export([
    route_msg/3,
%%    route_evt/3,
    msg_mod/1
]).

route_msg(MsgID, Data, State) ->
    Handler = msg_mod(MsgID),
    Handler:handle_msg(MsgID, Data, State).

%%route_evt(MsgID, Data, State) ->
%%    Handler = msg_mod(MsgID),
%%    Handler:handle_evt(MsgID, Data, State).

msg_mod(MsgID) ->
    case MsgID div 1000 of
        10 -> handle_login;
        11 -> handle_player;
        _ ->  handle_err
    end.