%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%      网络包输出
%%% @end
%%% Created : 30. 10月 2019 10:35
%%%-------------------------------------------------------------------
-module(net_debug).
-author("Administrator").

%% API
-export([]).
%%
%%-export([
%%    init/0,
%%    rec_msg/2,
%%    start_debug/0,
%%    stop_debug/0
%%]).
%%
%%
%%rec_msg(Type, Iolist) ->
%%    case is_debug() of
%%        ?true ->
%%            catch do_rec_msg(Type, erlang:iolist_to_binary(Iolist), []);
%%        _ ->
%%            pass
%%    end.
%%
%%do_rec_msg(Type, <<Len:16, MsgBin:Len/binary, Res/binary>>, Acc) ->
%%    <<MsgID:16, Bin/binary>> = MsgBin,
%%    Acc1 =
%%        case is_ignore_msg(MsgID) of
%%            ?false ->
%%                Mod = ?IF(Type=:=send, data_msg_s2c, data_msg_c2s),
%%                Name = Mod:get(MsgID),
%%                Msg = msg_pb:decode(Name, Bin),
%%                Rec = {erlang:time(), erlang:system_time(milli_seconds), Type, MsgID, Msg},
%%                [Rec|Acc];
%%            ?true ->
%%                Acc
%%        end,
%%    do_rec_msg(Type, Res, Acc1);
%%do_rec_msg(_, <<>>, []) ->
%%    ok;
%%do_rec_msg(_, <<>>, Recs) ->
%%    write_msgs(Recs),
%%    ok;
%%do_rec_msg(_, _E, _) ->
%%    ?TRAC({rec_msg_fail, byte_size(_E)}),
%%    ok.
%%
%%write_msgs(Recs) ->
%%    case erlang:get(net_debug_fd) of
%%        ?undefined ->
%%            pass;
%%        Fd ->
%%            file:write(Fd, reverse_msgs(Recs, []))
%%    end.
%%
%%reverse_msgs([H|T], Acc) ->
%%    Rec = [xg_util:term_to_bitstring(H), "\n"],
%%    Acc1 = [Rec|Acc],
%%    reverse_msgs(T, Acc1);
%%reverse_msgs([], Acc) ->
%%    Acc.
%%
%%
%%is_ignore_msg(0)     -> ?true;
%%is_ignore_msg(?s2c_mwar_debug_bullet)     -> ?true;
%%is_ignore_msg(?s2c_mwar_debug_pos)        -> ?true;
%%is_ignore_msg(?s2c_mwar_debug_line)       -> ?true;
%%is_ignore_msg(?s2c_mwar_debug_word)       -> ?true;
%%is_ignore_msg(?s2c_acc_ping)              -> ?true;
%%is_ignore_msg(?s2c_acc_heart)             -> ?true;
%%is_ignore_msg(?s2c_acc_heart_mwar)        -> ?true;
%%is_ignore_msg(_)                          -> ?false.
%%
%%
%%start_debug() ->
%%    case is_debug() of
%%        ?false ->
%%            UUID = erlang:get(player_uuid),
%%            SenderType = xg_node:node_type(),
%%            Filename = lists:concat(["pt_", SenderType, "_", UUID, ".txt"]),
%%            FullFn = filename:join(xg_config:get(logs_net_debug_path), Filename),
%%            filelib:ensure_dir(FullFn),
%%            case file:read_file_info(FullFn) of
%%                {ok, #file_info{ctime={CDate, _CTime}}} ->
%%                    ?TRAC(CDate),
%%                    case CDate =/= erlang:date() of
%%                        ?true ->
%%                            FullFnBak = FullFn ++ ".bak",
%%                            file:rename(FullFn, FullFnBak);
%%                        _ ->
%%                            pass
%%                    end;
%%                _Err ->
%%                    ?TRAC(_Err),
%%                    ?TRAC(_Err#file_info.ctime),
%%                    pass
%%            end,
%%            {ok, Fd} = file:open(FullFn, [append, raw]),
%%            file:write(Fd, "\n\n\n\n"),
%%            file:write(Fd, io_lib:format("========= Connect Time: ~p ========~n", [lib_net:get_proc_init_time()])),
%%            erlang:put(net_debug_fd, Fd);
%%        _ ->
%%            ok
%%    end.
%%
%%stop_debug() ->
%%    erlang:erase(net_debug_fd).
%%
%%
%%init() ->
%%    case should_init() of
%%        ?true ->
%%            ?TRAC(should_net_debug),
%%            start_debug();
%%        _ ->
%%            ?TRAC(should_not_net_debug),
%%            pass
%%    end.
%%
%%
%%should_init() ->
%%    UUID = erlang:get(player_uuid),
%%    Type = xg_node:node_type(),
%%    case xg_config:get(net_proto_debug) of
%%        0 ->
%%            ?false;
%%        1 ->
%%            net_debug_mgr:should_log(UUID, Type);
%%        Filter when Filter > 0 andalso UUID rem Filter =:= 1 ->
%%            net_debug_mgr:should_log(UUID, Type);
%%        _ ->
%%            ?false
%%    end.
%%
%%
%%is_debug() ->
%%    erlang:get(net_debug_fd) =/= ?undefined.
