%%%-------------------------------------------------------------------
%% @doc
%%      监控树模板, 由主监控树开启
%% @end
%%%-------------------------------------------------------------------

-module(temp_sup).

-behaviour(supervisor).

-include("hrl_logs.hrl").

-export([start_link/1]).
-export([start_temp_child/1]).
-export([init/1]).


start_link(Mod) ->
    SupName = list_to_atom(lists:concat([Mod, "_t_sup"])),
    supervisor:start_link({local, SupName}, ?MODULE, [Mod]).


start_temp_child(Mod) ->
    Child = #{id => Mod,
        start => {?MODULE, start_link, [Mod]},
        restart => temporary,
        shutdown => 10000,
        type => supervisor,
        modules => [?MODULE]},
    try supervisor:start_child(leishen_sup, Child) of
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
