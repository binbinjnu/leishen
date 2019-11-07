%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%     雷神项目协议encode decode
%%% @end
%%% Created : 30. 10月 2019 10:51
%%%-------------------------------------------------------------------
-module(net_pack_leishen).
-author("Administrator").

-include("hrl_common.hrl").
-include("hrl_logs.hrl").

%% API
-export([
    pack/1,
    pack_bin/1,
    unpacks/1]).

pack_bin(Msg) ->
    Bin = pack(Msg),
    iolist_to_binary(Bin).

pack(Msgs) ->
    try
        do_pack(Msgs)
    catch
        Err:Reason ->
            ?WARNING("Invalid Msgs: ~p, Err:~p, Reason:~p", [Msgs, Err, Reason]),
            []
    end.

do_pack(Msgs) when is_list(Msgs) ->
    [do_pack(Msg) || Msg <- Msgs];
do_pack(Msg) when is_binary(Msg)->
    Msg;
do_pack({}) ->
    [];
do_pack(Msg) when is_tuple(Msg)->
    MsgIDAtom = erlang:element(1, Msg),
    [A, B, C, D, E, F, G, H] = erlang:atom_to_list(MsgIDAtom),
    I = letter_to_number([A]),
    II = erlang:list_to_integer([B], 16),
    III = erlang:list_to_integer([C, D], 16),
    IV = erlang:list_to_integer([E, F, G, H], 16),
    MsgIDBin = <<I:4, II:4, III:8, IV:16>>,
    try
        Content = proto_pb:encode_msg(Msg),
        MsgBin = <<MsgIDBin/binary, Content/binary>>,
        Len = erlang:byte_size(MsgBin) + 1,
        <<0:8, Len:24, 0:8, MsgBin/binary>>
    catch _:_ ->
        ?ERROR("Invalid msg ~p",[Msg]),
        []
    end;
do_pack(?undefined) ->
    [];
do_pack(_E) ->
    ?WARNING("Invalid Msg:~p", [_E]),
    erlang:error(invalid_msg).

unpacks(Bin) ->
    unpacks(Bin, []).

unpacks(<<>>, Acc) ->
    lists:reverse(Acc);
unpacks(<<0:8, Len:24, Bin:Len/binary, Res/binary>>, Acc) ->
    <<_Ordinal:8, I:4, II:4, III:8, IV:16, Bin1/binary>> = Bin,
    I1 = number_to_letter(I),
    II1 = erlang:list_to_atom(erlang:integer_to_list(II, 16)),
    III1 = erlang:list_to_atom(erlang:integer_to_list(III, 16)),
    IV1 = erlang:list_to_atom(erlang:integer_to_list(IV, 16)),
    MsgIDList = io_lib:format("~s~s~2..0s~4..0s", [I1, II1, III1, IV1]),
    MsgIDAtom = erlang:list_to_atom(MsgIDList),
    try
        Cont = proto_pb:decode_msg(Bin1, MsgIDAtom),
        unpacks(Res, [{MsgIDAtom, Cont} | Acc])
    catch
        _:_ ->
            ?WARNING("Decode error ~w: ~w", [MsgIDAtom, Bin1]),
            unpacks(Res, Acc)
    end;
unpacks(_E, Acc) ->
    ?WARNING("msg err ~p", [_E]),
    lists:reverse(Acc).

letter_to_number("S") -> 1;
letter_to_number("C") -> 2;
letter_to_number("N") -> 3;
letter_to_number("P") -> 4;
letter_to_number("I") -> 5;
letter_to_number("F") -> 6.

number_to_letter(1) ->   'S';
number_to_letter(2) ->   'C';
number_to_letter(3) ->   'N';
number_to_letter(4) ->   'P';
number_to_letter(5) ->   'I';
number_to_letter(6) ->   'F'.

%% 原生的pb性能约高 50%

% 15> G = [{oid,20},{gid,30101},{num,10}].
% 16> G2 = {s2cgoodsinfo_goodsinfo, 20, 30101,10}.

% 17> bench:rp(pbson, encode, [G]).
% Single Process:    1261065 call per sec,    2097152 times in  1663 ms
%      1 Process:    1125685 call per sec,    2097152 times in  1863 ms
%     10 Process:    3855058 call per sec,    5242880 times in  1360 ms
%    100 Process:    3900952 call per sec,    6553600 times in  1680 ms
%   1000 Process:    3778597 call per sec,    4096000 times in  1084 ms
% ok
% 18> bench:rp(message_pb, encode, [G2]).
% Single Process:    1710564 call per sec,    2097152 times in  1226 ms
%      1 Process:    1630755 call per sec,    2097152 times in  1286 ms
%     10 Process:    5714310 call per sec,   10485760 times in  1835 ms
%    100 Process:    5877668 call per sec,    6553600 times in  1115 ms
%   1000 Process:    5595628 call per sec,    8192000 times in  1464 ms
% ok

% E = [{oid,7},
%  {eid,17001},
%  {pos,6},
%  {elevel,1},
%  {grade,0},
%  {sate,0},
%  {strong,0},
%  {gems,[]}]

% E2 = {goodseqbrief, 7, 17001, 6, 1, 0 , 0,0,[]}.

% 12> bench:rp(pbson, encode, [E]).
% Single Process:     643693 call per sec,    1048576 times in  1629 ms
%      1 Process:     606463 call per sec,    1048576 times in  1729 ms
%     10 Process:    2107266 call per sec,    2621440 times in  1244 ms
%    100 Process:    2137508 call per sec,    3276800 times in  1533 ms
%   1000 Process:    2045954 call per sec,    2048000 times in  1001 ms
% ok

% 14> bench:rp(message_pb, encode, [E2]).
% Single Process:     920611 call per sec,    1048576 times in  1139 ms
%      1 Process:     830884 call per sec,    1048576 times in  1262 ms
%     10 Process:    2872810 call per sec,    5242880 times in  1825 ms
%    100 Process:    2978909 call per sec,    3276800 times in  1100 ms
%   1000 Process:    2913229 call per sec,    4096000 times in  1406 ms
% ok

