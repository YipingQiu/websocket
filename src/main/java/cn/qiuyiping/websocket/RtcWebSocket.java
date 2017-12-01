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
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author lenovo
 */
@ServerEndpoint("/rtcws")
public class RtcWebSocket {

    private static final List<Session> sessionList = new ArrayList<>();
    private static final Map<String, Session> sessionMap = new ConcurrentHashMap<>();

    @OnMessage
    public void onMessage(String message) throws IOException {
        JSONObject data = JSONObject.parseObject(message);
        if (data.getJSONObject("offer") != null || data.getJSONObject("answer") != null || data.getJSONObject("icecandidate") != null) {
            data = data.getJSONObject("offer") != null ? data.getJSONObject("offer") :
                    data.getJSONObject("answer") != null ? data.getJSONObject("answer") :
                            data.getJSONObject("icecandidate");
            sessionMap.get(data.getString("to")).getBasicRemote().sendText(message);
        }
    }

    @OnOpen
    public void onOpen(Session session) throws IOException {
        System.out.println("Client connected");
        sessionList.add(session);
        sessionMap.put(session.getId(), session);
        JSONObject data = new JSONObject();
        data.put("mySessionId", session.getId());
        session.getBasicRemote().sendText(data.toString());
        sendAllSession();
    }

    private void sendAllSession() throws IOException {
        JSONObject data = new JSONObject();
        JSONArray array = new JSONArray();
        for (Session sess : sessionList) {
            array.add(sess.getId());
        }
        data = new JSONObject();
        data.put("allSessionId", array);
        for (Session sess : sessionList) {
            sess.getBasicRemote().sendText(data.toJSONString());
        }
    }

    @OnClose
    public void onClose(Session session) throws IOException {
        sessionList.remove(session);
        sessionList.remove(session.getId());
        System.out.println("Connection closed");
        sendAllSession();
    }

}
