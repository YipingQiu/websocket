<%--
  Created by IntelliJ IDEA.
  User: lenovo
  Date: 2017/11/29
  Time: 20:34
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
<select id="sessions">
</select>
<button id="call">call</button>
<hr>
<video id="me" autoplay></video>
<video id="to" autoplay></video>
<video id="callee" autoplay></video>
</body>

<script src="jquery-3.2.1.js"></script>
<script src="plugins/vConsole-3.0.0/dist/vconsole.min.js"></script>
<script>
    var vConsole = new VConsole();
    var my_session;
    var g_stream;
    var me = document.querySelector("#me");
    var callee = document.querySelector("#callee");
    var ws = new WebSocket('wss://192.168.137.1:8443/websocket/rtcws');

    var pc = new webkitRTCPeerConnection(null);

    var sendOfferFn = function (desc) {
        pc.setLocalDescription(desc);
        ws.send(JSON.stringify({
            offer: {
                "event": "offer",
                "to": $('#sessions').val(),
                "from": my_session,
                "sdp": desc
            }
        }));
    };

    var sendAnswerFn = function (desc) {
        pc.setLocalDescription(desc);
        ws.send(JSON.stringify({
            answer: {
                "event": "answer",
                "to": $('#sessions').val(),
                "from": my_session,
                "sdp": desc
            }
        }));
    };

    pc.onicecandidate = function (event) {
        console.log(event);
        if (event.candidate !== null) {
            ws.send(JSON.stringify({
                "icecandidate": {
                    "event": "icecandidate",
                    "to": $('#sessions').val(),
                    "from": my_session,
                    "candidate": event.candidate
                }
            }));
        }
    };
    pc.onaddstream = function (event) {
        document.getElementById('to').src = URL.createObjectURL(event.stream);
    };

    ws.onmessage = function (msgevent) {
        var data = $.parseJSON(msgevent.data);
        console.log(data);
        if (data.mySessionId) {
            my_session = data.mySessionId;
        }
        if (data.allSessionId) {
            $('#sessions').empty();
            for (var i = 0; i < data.allSessionId.length; i++) {
                if (data.allSessionId[i] != my_session) {
                    $('#sessions').append('<option value="' + data.allSessionId[i] + '">' + data.allSessionId[i] + '</option>');
                }
            }
        }
        if (data.offer) {
            pc.setRemoteDescription(new RTCSessionDescription(data.offer.sdp));
            pc.createAnswer(sendAnswerFn, function (error) {
                console.log('Failure callback: ' + error);
            });
        }
        if (data.answer) {
            pc.setRemoteDescription(new RTCSessionDescription(data.answer.sdp));
        }
        if(data.icecandidate){
            pc.addIceCandidate(new RTCIceCandidate(data.icecandidate.candidate));
        }
    };

    navigator.webkitGetUserMedia(
        {
            'video': true,
            'audio': true
        },
        function (stream) {
            g_stream = stream;
            me.src = URL.createObjectURL(stream);
            pc.addStream(g_stream);
        },
        function (error) {
            console.log(error);
        }
    );

    $('#call').on('click', function () {
        var sessionId = $('#sessions').val();
        console.log(sessionId);
        if (sessionId == undefined) {
            return;
        }

        pc.createOffer(sendOfferFn, function (error) {
            console.log(error);
        });
    });
</script>
</html>
