$(document).ready(function() {
  if (!window.WebSocket) {  
    alert("WebSocket not supported by this browser!");  
    return;
  }  

  var host = $("#cnf_host").val();
  var port = $("#cnf_port").val();

  var ws = build_websocket(host, port);

  //$("#txt_msg").val($.base64Encode("Hello Base64"));
  //
  $("#btn_bit_send").click(function() {
    var buf = new ArrayBuffer(2);
    var bytes = new Uint8Array(buf);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = 0xF0;
    }

    console.log(bytes);
    console.log(buf);
    var code = Base64.encode(bytes)
    console.log(code);
    console.log(Base64.decode(code));

    ws.send(code);
    console.log("Send Data: " + code);
  });
 
  //$("#btn_send").click(function() {
    //ws.send($("#txt_msg").val());
    //console.log("WS SEND: " + $("#txt_msg").val());
  //});

  //$("#btn_big_send").click(function() {
    //var max = new Number($("#txt_len").val());
    //var msg = "";

    //for (var i = 1; i <= max; i++) {
      //msg += 'A';
    //}

    //ws.send(msg);
    //console.log("WS SEND: " + max + " Length Msg" );
  //});
});

function build_websocket(host, port) {
  var url = "ws://" + host + ":" + port + "/";
  console.log(url);
  var ws = new WebSocket(url, "chat");  

  ws.onmessage = function(evt) {  
    //console.log('WS MSG: ' + $.base64Decode(evt.data));
    console.log(Base64.decode(evt.data));
    console.log(evt);
  };

  ws.onclose = function() { 
    console.log('WS CLOSE');
  };  

  ws.onerror = function() {
    console.log('WS ERROR');
  }

  ws.onopen = function() {  
    console.log('WS OPEN');
  };  

  return ws;
}
