%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2007-2014 GoPivotal, Inc.  All rights reserved.
%%

-module(background_gc_gsvr).

-behaviour(gen_server).

-export([start_link/0, run/0]).
-export([gc/0]). %% For run_interval only

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
    terminate/2, code_change/3]).

-define(MAX_RATIO, 0.01).
-define(IDEAL_INTERVAL, 60017).

-record(state, {last_interval}).

%%----------------------------------------------------------------------------

-ifdef(use_specs).

-spec(start_link() -> {'ok', pid()} | {'error', any()}).
-spec(run() -> 'ok').
-spec(gc() -> 'ok').

-endif.

%%----------------------------------------------------------------------------

start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

run() -> gen_server:cast(?MODULE, run).

%%----------------------------------------------------------------------------

init([]) ->
    {ok, interval_gc(#state{last_interval = ?IDEAL_INTERVAL})}.

handle_call(Msg, _From, State) ->
    {stop, {unexpected_call, Msg}, {unexpected_call, Msg}, State}.

handle_cast(run, State) -> gc(), {noreply, State};

handle_cast(Msg, State) -> {stop, {unexpected_cast, Msg}, State}.

handle_info(run, State) -> {noreply, interval_gc(State)};

handle_info(Msg, State) -> {stop, {unexpected_info, Msg}, State}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, State) -> State.

%%----------------------------------------------------------------------------

interval_gc(State = #state{last_interval = LastInterval}) ->
    {ok, Interval} = interval_operation(
        {?MODULE, gc, []},
        ?MAX_RATIO, ?IDEAL_INTERVAL, LastInterval),
    erlang:send_after(Interval, self(), run),
    State#state{last_interval = Interval}.

gc() ->
    [begin case process_info(P, status) of
               {status, waiting} -> garbage_collect(P);
               _ -> pass
           end end|| P <- processes()],
    garbage_collect(), %% since we will never be waiting...
    %% 如果需要统计, 需要加上gc时间
%%    fg_loc_data:set(fg_background_gc_time, erlang:system_time(milli_seconds)),
    ok.


%% Ideally, you'd want Fun to run every IdealInterval. but you don't
%% want it to take more than MaxRatio of IdealInterval. So if it takes
%% more then you want to run it less often. So we time how long it
%% takes to run, and then suggest how long you should wait before
%% running it again. Times are in millis.
interval_operation({M, F, A}, MaxRatio, IdealInterval, LastInterval) ->
    {Micros, Res} = timer:tc(M, F, A),
    {Res, case {Micros > 1000 * (MaxRatio * IdealInterval),
        Micros > 1000 * (MaxRatio * LastInterval)} of
              {true,  true}  -> round(LastInterval * 1.5);
              {true,  false} -> LastInterval;
              {false, false} -> lists:max([IdealInterval,
                  round(LastInterval / 1.5)])
          end}.
