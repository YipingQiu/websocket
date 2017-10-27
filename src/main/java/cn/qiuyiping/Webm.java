package cn.qiuyiping;


import java.io.*;
import java.util.Base64;

public class Webm {

	public static void decoderBase64File(String base64Code, String targetPath) throws Exception {
		byte[] buffer = Base64.getDecoder().decode(base64Code);
		File file = new File(targetPath);
		if(!file.exists()){
			file.createNewFile();
		}
		FileOutputStream out = new FileOutputStream(targetPath);
		out.write(buffer);
		out.close();
	}

	public static void main(String[] args) {
		try {
			StringBuffer sb = readFile("C:\\Users\\Jack\\Desktop\\video2.txt");
			decoderBase64File(sb.toString(), "C:\\Users\\Jack\\Desktop\\video.webm");
		} catch (Exception e) {
			e.printStackTrace();

		}

	}

	private static StringBuffer readFile(String file) throws IOException {
		FileReader fr=new FileReader(file);
		BufferedReader br=new BufferedReader(fr);
		String line="";
		StringBuffer sb = new StringBuffer();
		while ((line=br.readLine())!=null) {
			sb.append(line);
		}
		br.close();
		fr.close();
		return sb;
	}

}
