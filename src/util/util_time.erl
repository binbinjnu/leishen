%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 10月 2019 9:39
%%%-------------------------------------------------------------------
-module(util_time).
-author("Administrator").

%% API
-export([
    unix_time/0,
    long_unix_time/0,
    localtime/0
]).

%% 单位：秒
unix_time() ->
    erlang:system_time(seconds).

%% 单位：毫秒
long_unix_time() ->
    erlang:system_time(milli_seconds).

%% 本地时间
localtime() ->
    timestamp_to_localtime(unix_time()).

%% 时间戳转本地时间
timestamp_to_localtime(T) ->
    MS = T div 1000000,
    S = T rem 1000000,
    calendar:now_to_local_time({MS, S, 0}).