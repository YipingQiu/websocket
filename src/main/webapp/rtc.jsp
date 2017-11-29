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
</body>

<script src="jquery-3.2.1.js"></script>
<script>
    var my_session;
    var ws = new WebSocket('ws://localhost:8080/websocket/rtcws');

    ws.onmessage =  function (msgevent) {
        var data = $.parseJSON(msgevent.data);
        if(data.mySessionId){
            my_session = data.mySessionId;
        }
        if(data.allSessionId){
            $('#sessions').empty();
            for(var i = 0; i < data.allSessionId.length; i++){
                if(data.allSessionId[i] != my_session){
                    $('#sessions').append('<option value="' + data.allSessionId[i] + '">' + data.allSessionId[i] + '</option>');
                }
            }
        }
    };
</script>
</html>
