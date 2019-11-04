%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 11月 2019 15:51
%%%-------------------------------------------------------------------
-module(player_checker).

-export([reg/0]).
-export([start/0, start_link/0]).

-define(SLOTS_NUM, 60).

reg() ->
    Pid = self(),
    proc_checker_gsvr:reg(?MODULE, Pid).

start() ->
    leishen_sup:start_child(?MODULE).

start_link() ->
    Args = #{
        slot_num => ?SLOTS_NUM,
        interval => 900,
        kill_msg_q => 2000,
        check_msg_q => 9999 % 不做call检查
    },
    proc_checker_gsvr:start_link(?MODULE, Args).

