package cn.qiuyiping.websocket;


import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * @author lenovo
 */
@ServerEndpoint("/rtcws")
public class RtcWebSocket {

    private static final List<Session> sessions = new ArrayList<>();

    @OnMessage
    public void onMessage(String message) throws IOException, InterruptedException {

    }

    @OnOpen
    public void onOpen(Session session) throws IOException {
        System.out.println("Client connected");
        sessions.add(session);
        JSONObject data = new JSONObject();
        data.put("mySessionId", session.getId());
        session.getBasicRemote().sendText(data.toString());
        sendAllSession();
    }

    private void sendAllSession() throws IOException {
        JSONObject data = new JSONObject();
        JSONArray array = new JSONArray();
        for(Session sess : sessions){
            array.add(sess.getId());
        }
        data = new JSONObject();
        data.put("allSessionId", array);
        for(Session sess : sessions){
            sess.getBasicRemote().sendText(data.toJSONString());
        }
    }

    @OnClose
    public void onClose(Session session) throws IOException {
        sessions.remove(session);
        System.out.println("Connection closed");
        sendAllSession();
    }

}
