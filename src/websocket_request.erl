%%
%% This is a wrapper for the Socket connection
%% @author Dave Bryson [http://weblog.miceda.org]
%%
-module(websocket_request,[Socket]).

-export([get/1,get_data/0,send/2]).

%% Get the Socket if you need it
get(socket) ->
    Socket.

%% Return the data from the Socket. Parse it from the WebSocket format
get_data() ->
  case gen_tcp:recv(Socket, 0) of
    {ok, Data} ->
      parse_data(Data);
    _Other ->
      exit(normal)
    end.

%parse_data(Data) ->
  %<<Fin:1, _Rsv:3, Opcode:4, Mask:1, Size:7, MaskKey:32, Msg/binary>> = Data,
  %error_logger:info_report([{fin, Fin}, {opcode, Opcode}, {mask, Mask}, {size, Size}, {mask_key, MaskKey}, {is, is_integer(MaskKey)}, {msg, Msg}]),
  %unmask_data(binary_to_list(Msg), <<MaskKey:32>>, 4, []).

parse_data(<<Fin:1, _Rsv:3, Opcode:4, Mask:1, 126:7, Size:16, MaskKey:32, Msg/binary>>) ->
  unmask_data(binary_to_list(Msg), <<MaskKey:32>>, 4, []);

parse_data(<<Fin:1, _Rsv:3, Opcode:4, Mask:1, Size:7, MaskKey:32, Msg/binary>>) ->
  unmask_data(binary_to_list(Msg), <<MaskKey:32>>, 4, []).


unmask_data([], _MaskKey, _Index, Result) ->
  lists:reverse(Result);

unmask_data([H|T], MaskKey, Index, Result) ->
  error_logger:info_report([H, T, MaskKey, Index, Result]),
  Unmask = H bxor binary:at(MaskKey, Index rem 4),
  error_logger:info_msg("Unmask: ~p~n", [Unmask]),
  unmask_data(T, MaskKey, Index + 1, [Unmask|Result]).

send(Msg, Size) when Size =< 125 ->
  error_logger:info_msg("Send [~p] Msg: ~p~n", [Size, Msg]),
  %%       FIN  RSV  OPCODE  MASK  SIZE    DATA
  Data = <<1:1, 0:3, 1:4,    0:1,  Size:7, Msg/binary>>,
  gen_tcp:send(Socket, Data);

send(Msg, Size) ->
  error_logger:info_msg("Send [~p] Msg: ~p~n", [Size, Msg]),
  %%       FIN  RSV  OPCODE  MASK  SIZE            DATA
  Data = <<1:1, 0:3, 1:4,    0:1,  126:7, Size:16, Msg/binary>>,
  gen_tcp:send(Socket, Data).
