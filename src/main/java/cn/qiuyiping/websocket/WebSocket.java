package cn.qiuyiping.websocket;


import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

@ServerEndpoint("/ws")
public class WebSocket {

    private static final List<Session> sessions = new ArrayList<Session>();

    @OnMessage
    public void onMessage(String message) throws IOException, InterruptedException {
        System.out.println(sessions.size());
        for(Session session : sessions){
            System.out.println(session.getRequestURI());
            session.getBasicRemote().sendText(new SimpleDateFormat("HH:mm:ss").format(new Date()) + "\t" + message);
        }

        // Print the client message for testing purposes
//        System.out.println("Received: " + message);

        // Send the first message to the client
//        session.getBasicRemote().sendText("This is the first server message");

        // Send 3 messages to the client every 5 seconds
//        int sentMessages = 0;
//        while (sentMessages < 10) {
//            Thread.sleep(1000);
//            session.getBasicRemote().sendText("This is an intermediate server message. Count: " + sentMessages);
//            sentMessages++;
//        }

        // Send a final message to the client
//        session.getBasicRemote().sendText("This is the last server message");
    }

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
        System.out.println("Client connected");
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
        System.out.println("Connection closed");
    }

}
