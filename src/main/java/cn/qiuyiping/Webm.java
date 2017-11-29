package cn.qiuyiping;


import java.io.*;
import java.util.Base64;

public class Webm {

    public static void decoderBase64File(String base64Code, String targetPath) throws Exception {
        byte[] buffer = Base64.getDecoder().decode(base64Code);
        File file = new File(targetPath);
        if (!file.exists()) {
            file.createNewFile();
        }
        FileOutputStream out = new FileOutputStream(targetPath);
        out.write(buffer);
        out.close();
    }

    public static void main(String[] args) {
        try {
//            StringBuffer sb = readFile("E:\\dir\\video.txt");
//            decoderBase64File(sb.toString(), "E:\\dir\\video.webm");
            encoderWebmToBase64("C:\\Users\\lenovo\\Desktop\\3388.webm", "C:\\Users\\lenovo\\Desktop\\3388webm.txt");
        } catch (Exception e) {
            e.printStackTrace();

        }

    }

    private static void encoderWebmToBase64(String fileSrc, String fileTar) throws IOException {
        InputStream in = null;
        byte[] data = null;
        //读取图片字节数组
        try {
            in = new FileInputStream(fileSrc);
            data = new byte[in.available()];
            in.read(data);
            in.close();
            String base = new String(Base64.getEncoder().encode(data));

            File file = new File(fileTar);
            if (!file.exists()) {
                file.createNewFile();
            }
            FileWriter fw = new FileWriter(fileTar);
            fw.write(base,0,base.length());
            fw.flush();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static StringBuffer readFile(String file) throws IOException {
        FileReader fr = new FileReader(file);
        BufferedReader br = new BufferedReader(fr);
        String line = "";
        StringBuffer sb = new StringBuffer();
        while ((line = br.readLine()) != null) {
            sb.append(line);
        }
        br.close();
        fr.close();
        return sb;
    }

}
