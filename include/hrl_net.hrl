%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 10月 2019 10:22
%%%-------------------------------------------------------------------
-author("Administrator").

-define(PACKAGE_HEAD_LEN, 16).
-define(TCP_OPTIONS, [
    {nodelay, true},
    {delay_send, false},
    {send_timeout, 15000},
    {send_timeout_close, true},
    {keepalive, false},
    {exit_on_close, true}]).

-define(MAX_PACK_ACC, 10).          %% 最大包数量, 超出直接send
-define(PACK_FLUSH_SIZE, 1024).     %% 溢出bytes size, 溢出后直接send
-define(NET_STAT_INTERVAL, 10).     %% 网络统计间隔 seconds
-define(NET_PACKET_PER_SEC, 20).    %% 每秒中网络包数量
-define(NET_MAX_WATER_LV, 300).     %% 水位警戒等级
-define(NET_HEART_TIMEOUT, 120).    %% 心跳超时 seconds

%% net_handle 的state record
-record(nstate, {
    state     = undefined   :: term(),
    pid       = undefined   :: pid() | undefined,
    acc       = undefined,
    debug_pid = 0,
    server_id = 0    %% 入口ID, entrance_id
}).