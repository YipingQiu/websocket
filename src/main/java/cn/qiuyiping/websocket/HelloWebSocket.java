package cn.qiuyiping.websocket;

import javax.websocket.ContainerProvider;
import javax.websocket.DeploymentException;
import javax.websocket.Session;
import javax.websocket.WebSocketContainer;
import java.io.IOException;
import java.net.URI;

public class HelloWebSocket {

    public static void main(String[] args){

        WebSocketContainer container = ContainerProvider.getWebSocketContainer();
        try {
            Session session = container.connectToServer(Client.class, URI.create("ws://localhost:8080/ws"));
            session.getBasicRemote().sendText("hi");
            //session.close();
        } catch (DeploymentException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
