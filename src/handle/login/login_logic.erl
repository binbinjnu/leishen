%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%     登录逻辑流程
%%% @end
%%% Created : 04. 11月 2019 16:15
%%%-------------------------------------------------------------------
-module(login_logic).
-author("Administrator").

-include("hrl_logs.hrl").
-include("proto_pb.hrl").


%% API
-export([login/2]).

login(_Req, State) ->
%%    #'C0000001'{
%%        'AccountName' = AccountName,
%%        'Password' = Password,
%%        'MachineID' = MachineID,
%%        'PlatFormID' = PlatFormID,
%%        'IPAddr' = IPAddr,
%%        'TerminalType' = TerminalType,
%%        'ClientVersion' = ClientVersion,
%%        'GameID' = GameID,
%%        'Model' = Model,
%%        'Version' = Version
%%    } = Req,
    State.