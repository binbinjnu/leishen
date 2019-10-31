%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%     定时器, 定时发消息给注册的进程
%%% @end
%%% Created : 31. 10月 2019 18:48
%%%-------------------------------------------------------------------
-module(timer_gsvr).
-author("Administrator").
-behavior(gen_server).

-include("hrl_common.hrl").
-include("hrl_logs.hrl").

%% API
-export([reg/2, unreg/2]).
-export([set_timer/3, cancel_timer/2]).
-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

reg(Pid, Time) ->
    gen_server:cast(?MODULE, {add_timer, Pid, Time}).

unreg(Pid, Time) ->
    gen_server:cast(?MODULE, {del_timer, Pid, Time}).

set_timer(Time, Pos, State) ->
    case erlang:element(Pos, State) of
        ?undefined ->
            Ref = erlang:start_timer(Time, self(), doloop),
            erlang:setelement(Pos, State, Ref);
        _Ref ->
            State
    end.

cancel_timer(Pos, State) ->
    case erlang:element(Pos, State) of
        Ref when is_reference(Ref) ->
            erlang:cancel_timer(Ref),
            receive
                {timeout, Ref, _} -> ok
            after
                0 -> ok
            end,
            erlang:setelement(Pos, State, ?undefined);
        _ ->
            erlang:setelement(Pos, State, ?undefined)
    end.


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    erlang:process_flag(priority, high),
    {ok, #state{}}.


handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


handle_cast({add_timer, Pid, Time}, State) ->
    case get({timer, Time}) of
        undefined ->
            put({timer, Time}, [Pid]),
            Now = longunixtime(),
            erlang:send_after(Time, self(), {loop, Time, Now + Time});
        L ->
            case lists:member(Pid, L) of
                true -> skip;
                false -> put({timer, Time}, [Pid | L])
            end
    end,
    {noreply, State};

handle_cast({del_timer, Pid, Time}, State) ->
    case get({timer, Time}) of
        undefined ->
            ok;
        L ->
            case lists:member(Pid, L) of
                true ->
                    erlang:put({timer, Time}, lists:delete(Pid, L));
                false ->
                    skip
            end
    end,
    {noreply, State};

handle_cast(Msg, State) ->
    ?WARNING("handle cast is not match : ~p", [Msg]),
    {noreply, State}.


handle_info({loop, Time, TickTime}, State) ->
    NextTime = TickTime + Time,
    Now = longunixtime(),
    case NextTime > Now of
        ?true ->
            erlang:send_after(NextTime - Now, self(), {loop, Time, NextTime});
        ?false ->
            erlang:send(self(), {loop, Time, NextTime})
    end,
    Pids = get({timer, Time}),
    NewPids = [begin Pid ! doloop, Pid end || Pid <- Pids, erlang:is_process_alive(Pid)],
    put({timer, Time}, NewPids),
    {noreply, State};

handle_info(Info, State) ->
    ?WARNING("~p not handle.", [Info]),
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_, State, _) ->
    {ok, State}.

