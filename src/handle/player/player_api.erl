%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 11月 2019 15:55
%%%-------------------------------------------------------------------
-module(player_api).
-author("Administrator").

-include("hrl_common.hrl").

%% API
-export([
    pid/1,
    pid_name/1,

    spid/1,
    spid_name/1
]).

%% 玩家pid
pid(UID) ->
    PidName = pid_name(UID),
    case whereis(PidName) of
        Pid when is_pid(Pid) ->
            Pid;
        ?undefined ->
            ?undefined
    end.

%% 玩家pid名字
pid_name(UID) ->
    list_to_atom("pl_" ++ integer_to_list(UID)).


%% 玩家消息进程
spid(UID) ->
    PidName = spid_name(UID),
    case whereis(PidName) of
        Pid when is_pid(Pid) ->
            Pid;
        ?undefined ->
            ?undefined
    end.

%% 玩家消息进程名字
spid_name(UID) ->
    list_to_atom("sd_" ++ integer_to_list(UID)).