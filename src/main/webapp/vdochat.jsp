<%@ page language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Java后端WebSocket的Tomcat实现</title>
</head>
<body>
Welcome<br/><input id="text" type="text"/>
<button onclick="send()">发送消息</button>
<hr/>
<button onclick="closeWebSocket()">关闭WebSocket连接</button>
<hr/>
<div id="message"></div>

<video id="vid1" width="640" height="480" autoplay></video>
<video id="vid2" width="640" height="480" autoplay></video><br>
<a id="create" href="/websocket/vdochat.jsp#true" onclick="init()">点击此链接新建聊天室</a><br>
<p id="tips" style="background-color:red">请在其他浏览器中打开：http://此电脑   加入此视频聊天</p>
</body>

<script type="text/javascript">
    var isCaller = window.location.href.split('#')[1];
    var websocket = null;
    //判断当前浏览器是否支持WebSocket
    if ('WebSocket' in window) {
        websocket = new WebSocket("ws://localhost:8080/websocket/webrtc");
    }
    else {
        alert('当前浏览器 Not support websocket')
    }

    //连接发生错误的回调方法
    websocket.onerror = function () {
        setMessageInnerHTML("WebSocket连接发生错误");
    };

    //连接成功建立的回调方法
    websocket.onopen = function () {
        setMessageInnerHTML("WebSocket连接成功");
    };

    // 创建PeerConnection实例 (参数为null则没有iceserver，即使没有stunserver和turnserver，仍可在局域网下通讯)
    var pc = new webkitRTCPeerConnection(null);

    // 发送ICE候选到其他客户端
    pc.onicecandidate = function(event) {
        setMessageInnerHTML("我看看 1");
        if (event.candidate !== null) {
            setMessageInnerHTML("我看看 2");
            websocket.send(JSON.stringify({
                "event" : "_ice_candidate",
                "data" : {
                    "candidate" : event.candidate
                }
            }));
        }
    };

    //接收到消息的回调方法
    websocket.onmessage = function (event) {
        setMessageInnerHTML("接收到的信息");
        setMessageInnerHTML(event.data);
        if(event.data=="new user") {
            console.log("new user");
            location.reload();
        } else {
            var json = JSON.parse(event.data);
            console.log('onmessage: ', json);
            //如果是一个ICE的候选，则将其加入到PeerConnection中，否则设定对方的session描述为传递过来的描述
            if (json.event === "_ice_candidate") {
                pc.addIceCandidate(new RTCIceCandidate(json.data.candidate));
            } else {
                pc.setRemoteDescription(new RTCSessionDescription(json.data.sdp));
                // 如果是一个offer，那么需要回复一个answer
                if (json.event === "_offer") {
                    pc.createAnswer(sendAnswerFn, function(error) {
                        console.log('Failure callback: ' + error);
                    });
                }
            }
        }
    }

    //连接关闭的回调方法
    websocket.onclose = function () {
        setMessageInnerHTML("WebSocket连接关闭");
    }

    //监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。
    window.onbeforeunload = function () {
        closeWebSocket();
    }

    //将消息显示在网页上
    function setMessageInnerHTML(innerHTML) {
        document.getElementById('message').innerHTML += innerHTML + '<br/>';
    }

    //关闭WebSocket连接
    function closeWebSocket() {
        websocket.close();
    }

    //发送消息
    function send() {
        var message = document.getElementById('text').value;
        websocket.send(message);
    }

    // stun和turn服务器
    var iceServer = {
        "iceServers" : [ {
            "url" : "stun:stun.l.google.com:19302"
        }, {
            "url" : "turn:numb.viagenie.ca",
            "username" : "webrtc@live.com",
            "credential" : "muazkh"
        } ]
    };



    // 如果检测到媒体流连接到本地，将其绑定到一个video标签上输出
    pc.onaddstream = function(event) {
        document.getElementById('vid2').src = URL
            .createObjectURL(event.stream);
    };

    // 发送offer和answer的函数，发送本地session描述
    var sendOfferFn = function(desc) {
        pc.setLocalDescription(desc);
        websocket.send(JSON.stringify({
            "event" : "_offer",
            "data" : {
                "sdp" : desc
            }
        }));
    }, sendAnswerFn = function(desc) {
        pc.setLocalDescription(desc);
        websocket.send(JSON.stringify({
            "event" : "_answer",
            "data" : {
                "sdp" : desc
            }
        }));
    };

    // 获取本地音频和视频流
    navigator.webkitGetUserMedia({
            "audio" : true,
            "video" : true
        },
        function(stream) {
            //绑定本地媒体流到video标签用于输出
            document.getElementById('vid1').src = URL
                .createObjectURL(stream);
            //向PeerConnection中加入需要发送的流
            pc.addStream(stream);
            //如果是发起方则发送一个offer信令
            if (isCaller) {
                pc.createOffer(sendOfferFn, function(error) {
                    console.log('Failure callback: ' + error);
                });
            }
        }, function(error) {
            //处理媒体流创建失败错误
            console.log('getUserMedia error: ' + error);
        });

    window.onload=function(){
        if(isCaller==null||isCaller==undefined) {
            var tips = document.getElementById("tips");
            tips.remove();
        } else {
            var create = document.getElementById("create");
            create.remove();
        }
    };
    function init() {
        location.reload();
    }
</script>
</html>