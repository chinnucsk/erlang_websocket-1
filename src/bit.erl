-module(bit).
-export([start/0, stop/0, loop/1]).
-define(LOG(L), error_logger:info_report([{line, ?LINE},L])).

start() ->
  Loop = fun (WebSocket) ->
      ?MODULE:loop(WebSocket)
  end,
  mochiweb_websocket:start([{name, ?MODULE}, {loop, Loop}]).

stop() ->
  mochiweb_websocket:stop(?MODULE).

loop(WebSocket) ->
  Data = WebSocket:get_data(),
  ?LOG([{recv_data, Data}]),
  Data1 = base64:decode(Data),
  ?LOG([{decode_data, Data1}]),
  <<V1:8, V2:8>> = Data1,
  NewData = base64:encode(<<(V1+1):8, (V2+2):8>>),
  WebSocket:send(NewData, size(NewData)).
