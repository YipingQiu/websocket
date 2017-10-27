package cn.qiuyiping.jedis;

import redis.clients.jedis.Jedis;

import java.text.SimpleDateFormat;
import java.util.Date;

public class JedisConnect {

	public static void main (String[] args){
		//Jedis jedis = new Jedis("192.168.56.101",6379);
		Jedis jedis = new Jedis("123.56.14.218",6379);

		jedis.auth("root");
		jedis.connect();
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
		jedis.set("today", simpleDateFormat.format(new Date()));
		System.out.println(jedis.get("today"));
	}

}
