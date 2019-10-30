%%%-------------------------------------------------------------------
%% @doc leishen top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(leishen_sup).

-behaviour(supervisor).

-include("hrl_logs.hrl").

-export([start_link/0]).
-export([start_link/1]).
-export([
    start_child/1,
    start_child/2,
    start_temp_child/1
]).

-export([init/1]).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_link(Mod) ->
    SupName = list_to_atom(lists:concat([Mod, "_t_sup"])),
    supervisor:start_link({local, SupName}, ?MODULE, [Mod]).

start_child(Mod) ->
    start_child(Mod, [], worker).

start_child(Mod, Args) ->
    start_child(Mod, Args, worker).

start_child(Mod, Args, Type) ->
    Child = #{id => {Mod, Args},
        start => {Mod, start_link, Args},
        restart => permanent,
        shutdown => 30000,
        type => Type,
        modules => [Mod]},
    try supervisor:start_child(?MODULE, Child) of
        {ok, Pid} -> {ok, Pid};
        Err ->
            ?ERROR("Cannot start ~p: ~p", [Mod, Err]),
            Err
    catch
        Err:Reason ->
            ?ERROR("~p, ~p: Cannot start ~p, ~p", [Err, Reason, Mod, Args]),
            timer:sleep(10000),
            {error, Reason}
    end.

start_temp_child(Mod) ->
    Child = #{id => Mod,
        start => {?MODULE, start_link, [Mod]},
        restart => temporary,
        shutdown => 10000,
        type => supervisor,
        modules => [?MODULE]},
    try supervisor:start_child(?MODULE, Child) of
        {ok, Pid} -> {ok, Pid};
        Err ->
            ?ERROR("Cannot start ~p: ~p", [Mod, Err]),
            Err
    catch
        Err:Reason ->
            ?ERROR("~p, ~p: Cannot start ~p", [Err, Reason, Mod]),
            timer:sleep(10000),
            {error, Reason}
    end.


%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 10,
                 period => 10},
    {ok, {SupFlags, []}};
init([Mod]) ->
    SupFlags = #{strategy => one_for_one,
        intensity => 10,
        period => 10},
    ChildSpec = #{id => Mod,
                start => {Mod, start_link, []},
                restart => permanent,
                shutdown => 30000,
                type => worker,
                modules => [Mod]},
    {ok, {SupFlags, [ChildSpec]}}.

%% internal functions
