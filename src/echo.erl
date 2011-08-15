-module(echo).

-export([start/0, stop/0, loop/1]).

start() ->
  Loop = fun (WebSocket) ->
      ?MODULE:loop(WebSocket)
  end,
  mochiweb_websocket:start([{name, ?MODULE}, {loop, Loop}]).

stop() ->
  mochiweb_websocket:stop(?MODULE).

loop(WebSocket) ->
  Data = WebSocket:get_data(),
  error_logger:info_msg("Send Same Msg: ~p~n", [Data]),
  Data1 = list_to_binary(Data),
  error_logger:info_msg("Convert Msg: [~p] ~p~n", [size(Data1), Data1]),
  WebSocket:send(Data1, size(Data1)).
