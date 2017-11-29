<%--
  Created by IntelliJ IDEA.
  User: lenovo
  Date: 2017/11/27
  Time: 9:41
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>video/audio</title>
</head>
<body>
<canvas id="canvas"></canvas>
<video id="video" autoplay></video>
</body>
<script src="jquery-3.2.1.js"></script>
<script src="plugins/vConsole-3.0.0/dist/vconsole.min.js"></script>
<script>
var vConsole = new VConsole();

    $(document).ready(function () {
        var video = document.querySelector('#video');
        navigator.webkitGetUserMedia(
            {
                'video' : true,
                'audio' : true
            },
            function (stream) {
                video.src = URL.createObjectURL(stream);
//                video.play();
            },
            function (error) {
                console.error(error)
            }
        );
    });

</script>
</html>
