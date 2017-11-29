<%--
  Created by IntelliJ IDEA.
  User: lenovo
  Date: 2017/11/29
  Time: 15:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>WebRTC PeerConnection</title>
</head>
<body>
<div id="container">

    <div class="highlight">
        <p>New codelab: <a href="https://codelabs.developers.google.com/codelabs/webrtc-web">Realtime communication with
            WebRTC</a></p>
    </div>

    <h1><a href="//webrtc.github.io/samples/" title="WebRTC samples homepage">WebRTC samples</a>
        <span>Peer connection</span></h1>

    <video id="localVideo" autoplay muted></video>
    <video id="remoteVideo" autoplay></video>

    <div>
        <button id="startButton">Start</button>
        <button id="callButton">Call</button>
        <button id="hangupButton">Hang Up</button>
    </div>

    <p>View the console to see logging. The <code>MediaStream</code> object <code>localStream</code>, and the <code>RTCPeerConnection</code>
        objects <code>pc1</code> and <code>pc2</code> are in global scope, so you can inspect them in the console as
        well.</p>

    <p>For more information about RTCPeerConnection, see <a href="http://www.html5rocks.com/en/tutorials/webrtc/basics/"
                                                            title="HTML5 Rocks article about WebRTC by Sam Dutton">Getting
        Started With WebRTC</a>.</p>


    <a href="https://github.com/webrtc/samples/tree/gh-pages/src/content/peerconnection/pc1"
       title="View source for this page on GitHub" id="viewSource">View source on GitHub</a>

</div>
</body>
<script src="jquery-3.2.1.js"></script>
<script src="https://webrtc.github.io/adapter/adapter-latest.js"></script>
<script>
    var startButton = document.getElementById('startButton');
    var callButton = document.getElementById('callButton');
    var hangupButton = document.getElementById('hangupButton');
    callButton.disabled = true;
    hangupButton.disabled = true;
    startButton.onclick = start;
    callButton.onclick = call;
    hangupButton.onclick = hangup;

    var startTime;
    var localVideo = document.getElementById('localVideo');
    var remoteVideo = document.getElementById('remoteVideo');

    localVideo.addEventListener('loadedmetadata', function () {
        trace('Local video videoWidth: ' + this.videoWidth + 'px,  videoHeight: ' + this.videoHeight + 'px');
    });

    remoteVideo.addEventListener('loadedmetadata', function () {
        trace('Remote video videoWidth: ' + this.videoWidth + 'px,  videoHeight: ' + this.videoHeight + 'px');
    });

    remoteVideo.onresize = function () {
        trace('Remote video size changed to ' +
            remoteVideo.videoWidth + 'x' + remoteVideo.videoHeight);
        // We'll use the first onsize callback as an indication that video has started
        // playing out.
        if (startTime) {
            var elapsedTime = window.performance.now() - startTime;
            trace('Setup time: ' + elapsedTime.toFixed(3) + 'ms');
            startTime = null;
        }
    };

    var localStream;
    var pc1;
    var pc2;
    var offerOptions = {
        offerToReceiveAudio: 1,
        offerToReceiveVideo: 1
    };

    function getName(pc) {
        return (pc === pc1) ? 'pc1' : 'pc2';
    }

    function getOtherPc(pc) {
        return (pc === pc1) ? pc2 : pc1;
    }

    function gotStream(stream) {
        trace('Received local stream');
        localVideo.srcObject = stream;
        localStream = stream;
        callButton.disabled = false;
    }

    function start() {
        trace('Requesting local stream');
        startButton.disabled = true;
        navigator.mediaDevices.getUserMedia({
            audio: true,
            video: true
        })
            .then(gotStream)
            .catch(function (e) {
                alert('getUserMedia() error: ' + e.name);
            });
    }

    function call() {
        callButton.disabled = true;
        hangupButton.disabled = false;
        trace('Starting call');
        startTime = window.performance.now();
        var videoTracks = localStream.getVideoTracks();
        var audioTracks = localStream.getAudioTracks();
        if (videoTracks.length > 0) {
            trace('Using video device: ' + videoTracks[0].label);
        }
        if (audioTracks.length > 0) {
            trace('Using audio device: ' + audioTracks[0].label);
        }
        var servers = null;
        pc1 = new RTCPeerConnection(servers);
        trace('Created local peer connection object pc1');
        pc1.onicecandidate = function (e) {
            onIceCandidate(pc1, e);
        };
        pc2 = new RTCPeerConnection(servers);
        trace('Created remote peer connection object pc2');
        pc2.onicecandidate = function (e) {
            onIceCandidate(pc2, e);
        };
        pc1.oniceconnectionstatechange = function (e) {
            onIceStateChange(pc1, e);
        };
        pc2.oniceconnectionstatechange = function (e) {
            onIceStateChange(pc2, e);
        };
        pc2.ontrack = gotRemoteStream;

        localStream.getTracks().forEach(
            function (track) {
                pc1.addTrack(
                    track,
                    localStream
                );
            }
        );
        trace('Added local stream to pc1');

        trace('pc1 createOffer start');
        pc1.createOffer(
            offerOptions
        ).then(
            onCreateOfferSuccess,
            onCreateSessionDescriptionError
        );
    }

    function onCreateSessionDescriptionError(error) {
        trace('Failed to create session description: ' + error.toString());
    }

    function onCreateOfferSuccess(desc) {
        trace('Offer from pc1\n' + desc.sdp);
        trace('pc1 setLocalDescription start');
        pc1.setLocalDescription(desc).then(
            function () {
                onSetLocalSuccess(pc1);
            },
            onSetSessionDescriptionError
        );
        trace('pc2 setRemoteDescription start');
        pc2.setRemoteDescription(desc).then(
            function () {
                onSetRemoteSuccess(pc2);
            },
            onSetSessionDescriptionError
        );
        trace('pc2 createAnswer start');
        // Since the 'remote' side has no media stream we need
        // to pass in the right constraints in order for it to
        // accept the incoming offer of audio and video.
        pc2.createAnswer().then(
            onCreateAnswerSuccess,
            onCreateSessionDescriptionError
        );
    }

    function onSetLocalSuccess(pc) {
        trace(getName(pc) + ' setLocalDescription complete');
    }

    function onSetRemoteSuccess(pc) {
        trace(getName(pc) + ' setRemoteDescription complete');
    }

    function onSetSessionDescriptionError(error) {
        trace('Failed to set session description: ' + error.toString());
    }

    function gotRemoteStream(e) {
        if (remoteVideo.srcObject !== e.streams[0]) {
            remoteVideo.srcObject = e.streams[0];
            trace('pc2 received remote stream');
        }
    }

    function onCreateAnswerSuccess(desc) {
        trace('Answer from pc2:\n' + desc.sdp);
        trace('pc2 setLocalDescription start');
        pc2.setLocalDescription(desc).then(
            function () {
                onSetLocalSuccess(pc2);
            },
            onSetSessionDescriptionError
        );
        trace('pc1 setRemoteDescription start');
        pc1.setRemoteDescription(desc).then(
            function () {
                onSetRemoteSuccess(pc1);
            },
            onSetSessionDescriptionError
        );
    }

    function onIceCandidate(pc, event) {
        getOtherPc(pc).addIceCandidate(event.candidate)
            .then(
                function () {
                    onAddIceCandidateSuccess(pc);
                },
                function (err) {
                    onAddIceCandidateError(pc, err);
                }
            );
        trace(getName(pc) + ' ICE candidate: \n' + (event.candidate ?
            event.candidate.candidate : '(null)'));
    }

    function onAddIceCandidateSuccess(pc) {
        trace(getName(pc) + ' addIceCandidate success');
    }

    function onAddIceCandidateError(pc, error) {
        trace(getName(pc) + ' failed to add ICE Candidate: ' + error.toString());
    }

    function onIceStateChange(pc, event) {
        if (pc) {
            trace(getName(pc) + ' ICE state: ' + pc.iceConnectionState);
            console.log('ICE state change event: ', event);
        }
    }

    function hangup() {
        trace('Ending call');
        pc1.close();
        pc2.close();
        pc1 = null;
        pc2 = null;
        hangupButton.disabled = true;
        callButton.disabled = false;
    }

    function trace(data) {
        console.log(data);
    }

</script>
</html>
