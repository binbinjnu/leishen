%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 10月 2019 10:33
%%%-------------------------------------------------------------------
-module(net_handle).
-author("Administrator").

-include("hrl_common.hrl").
-include("hrl_logs.hrl").
-include("hrl_net.hrl").

%% API

-export([
    init/1,
    handle/2,
    pack/1,
    handle_evt/2,
    prepare_sends/2,
    prepare_udp/2,
    terminate/2
]).

-export([
    get_peername/0,
%%    get_tcp_socket/1,
    get_proc_init_time/0
]).

-define(RECV_KEY, <<"7918cae8">>).
-define(SEND_KEY, <<"7918cae8">>).
-define(ZIP_MIN_LEN, 100).
-define(MAX_HEAP_SIZE, 5 * 1024 * 1024). % 最大堆内存大小(word)



%%-define(REC_MSG(Type, Bin),
%%    net_debug:rec_msg(Type, Bin),
%%    net_count:count_msg(Type, Bin)).

% -define(REC_MSG(T, B), pass).

init(Socket) ->
    erlang:process_flag(max_heap_size, ?MAX_HEAP_SIZE),
    erlang:put(sender_pid, self()),
%%    lib_send:set_sender(self()),
    erlang:put(process_type, sender),
    set_peername(Socket),
    erlang:put(proc_init_time, util_time:localtime()),
    #nstate{pid = ?undefined}.

get_proc_init_time() ->
    erlang:get(proc_init_time).

set_peername(?undefined) ->
    {{0, 0, 0, 0}, 0};
set_peername(Socket) ->
    PeerName =
        case inet:peername(Socket) of
            {ok, PN} ->
                PN;
            _Err ->
                ?WARNING("Get peername error: ~p", [_Err]),
                {{0, 0, 0, 0}, 0}
        end,
    ?INFO("PeerName:~w", [PeerName]),
    erlang:put(net_peername, PeerName).


handle(Bin, #nstate{debug_pid = Pid} = NState) ->
%%    ?REC_MSG(recv, Bin),
    case is_pid(Pid) of
        ?true -> Pid ! {recv, Bin};
        _ -> ok
    end,
    Packets = net_pack:unpacks(Bin),
    NState1 = handle_1(Packets, NState),
    NState1.

handle_1([], NState) ->
    NState;
handle_1([{MsgID, Content} | T], NState) ->
    NState2 = handle_2(MsgID, Content, NState),
    handle_1(T, NState2).

handle_2(MsgID, Content, #nstate{pid = ?undefined} = NState) ->     %% 本地的
    handle_local(MsgID, Content, NState);
handle_2(MsgID, Content, #nstate{} = NState) when MsgID div 100 =:= 0 ->  %% 本地的
    handle_local(MsgID, Content, NState);
handle_2(MsgID, Content, #nstate{pid = Pid} = NState) ->            %% 对应Pid的
    gen_server:cast(Pid, {route_msg, MsgID, Content}),
    NState.


handle_local(_MsgID, _Content, NState) ->
    NState.
%%handle_local(MsgID, Content, NState) ->
%%    try lib_route:route_msg(MsgID, Content, NState) of
%%        {noreply, #nstate{} = NState1} ->
%%            NState1;
%%        {stop, #nstate{} = NState1} ->
%%            self() ! stop,
%%            NState1;
%%        _E ->
%%            ?WARNING("Invalid state. MsgID: ~p, state ~p", [MsgID, _E]),
%%            NState
%%    catch
%%        Err:Reason ->
%%            ?ERROR("~p:~p", [Err, Reason]),
%%            NState
%%    end.


pack(Msg) ->
    net_pack:pack(Msg).

get_peername() ->
    erlang:get(lib_net_peername).

%%get_tcp_socket(SPid) ->
%%    Ref = erlang:make_ref(),
%%    fg_net:event(SPid, {get_tcp_socket, self(), Ref}),
%%    receive
%%        {Ref, Socket} ->
%%            Socket
%%    after
%%        1000 ->
%%            ?undefined
%%    end.

handle_evt(Req, NState) ->
    try do_handle_evt(Req, NState) of
        #nstate{} = NState1 ->
            NState1;
        _E ->
            ?WARNING("Invalid return ~p", [_E]),
            NState
    catch Err:Reason ->
        ?ERROR("~p:~p", [Err, Reason]),
        NState
    end.


do_handle_evt(login_again, NState) ->
    erlang:send_after(1000, self(), stop),
%%    ?SEND_ERR(?ERR_ACCOUNT_LOGIN_AGAIN),
    NState#nstate{pid = ?undefined};

%%do_handle_evt(queue_max, NState) ->
%%    xg_login:queue_max(NState);
%%
%%do_handle_evt(queue_ok, NState) ->
%%    xg_login:allow_select_role(NState);
%%
%%do_handle_evt({debug_pid, Pid}, NState) ->
%%    NState#nstate{debug_pid = Pid};
%%
%%do_handle_evt(net_debug_start, NState) ->
%%    net_debug:start_debug(),
%%    NState;
%%
%%do_handle_evt(net_debug_stop, NState) ->
%%    net_debug:stop_debug(),
%%    NState;
%%
%%do_handle_evt({get_tcp_socket, From, Ref}, NState) ->
%%    Socket = fg_net:tcp_socket(),
%%    From ! {Ref, Socket},
%%    NState;
%%
%%do_handle_evt({test_rtt, From, Info}, NState) ->
%%    event:trigger_event(From, ?EVT_PLAYER_MAIN_PING_ACK, Info),
%%    NState;

do_handle_evt({test_cli_msg, Msg}, NState) ->
    handle_1(Msg, NState);

do_handle_evt(_E, NState) ->
    ?WARNING("unhandle event ~p", [_E]),
    NState.

prepare_sends(Sends, NState) ->
    try do_prepare_sends(Sends, NState)
    catch
        _:_ ->
            ?ERROR("Cannot prepare send ~p", [Sends]),
            {[], NState}
    end.

do_prepare_sends([], #nstate{} = NState) ->
    {[], NState};

do_prepare_sends(Sends, #nstate{debug_pid = Pid} = NState) ->
%%    ?REC_MSG(send, Sends),
    case is_pid(Pid) of
        ?true -> Pid ! {send, Sends};
        _ -> ok
    end,
    case erlang:iolist_size(Sends) of
        0 ->
            {[], NState};
        Len when Len > ?ZIP_MIN_LEN ->
            ?IF(Len >= 50000, ?WARNING("Huge net pack ~p", [Len]), ok),
            % ?IF(Len >= 32768, erlang:put(huge_pack, do_rec_send(Sends)), ok),
            {ok, Bin1} = lz4:compress(Sends),
            Len2 = byte_size(Bin1),
            {[<<Len2:16, 1:8>>, Bin1], NState};
        Len ->
            {[<<Len:16, 0:8>>, Sends], NState}
    end.


prepare_udp(Sends, NState) ->
    case erlang:iolist_size(Sends) of
        0 ->
            {[], NState};
        Len when Len > ?ZIP_MIN_LEN ->
            {ok, Bin2} = lz4:compress(Sends),
            Len2 = byte_size(Bin2) + 4,
            BinRet = [<<Len2:16, 1:8, Len:4/little-unsigned-integer-unit:8>>, Bin2],
            {BinRet, NState};
        Len ->
            {[<<Len:16, 0:8>>, Sends], NState}
    end.


%% 通过monitor实现, 不主动发消息
% terminate(Reason, #nstate{pid=Pid}) when is_pid(Pid) ->
%     event:trigger_event(Pid, ?EVT_PLAYER_OFFLINE, Reason);
terminate(_Reason, _NState) ->
    ok.
