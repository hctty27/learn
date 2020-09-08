# RSA前后端加解密

项目中有个地方需要从后台重定向到前端的登录页面，参数是直接拼接到URL后面的，考虑到安全性，所以采用将URL后面的参数进行RSA加密，前端再解密

前端js下载地址：http://travistidwell.com/jsencrypt/

java后台代码：

```java
import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Base64;
import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

import javax.crypto.Cipher;
import java.io.IOException;
import java.security.*;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.HashMap;
import java.util.Map;

/**
 * RSA加解密工具类，实现公钥加密私钥解密和私钥解密公钥解密
 */
@Slf4j
public class RSAUtil {

    public static final String PUB_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCP17zJbtyRmAIOGGKCoTXWSRyv0ld1Vd7hYnkSHRcYCsEVPc04IrzTo/AwUFMy4RxNGdEvbwI7K/FZebgpZtCtssBiZex8kAkjubbt8YHUWw5ucqgYXKbEmogZUijcYqduI16hPxG9aiHgyhKTKZM0d1/VvE31sJNatbQ/98WEVwIDAQAB";
    public static final String PRIV_KEY = "MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAI/XvMlu3JGYAg4YYoKhNdZJHK/SV3VV3uFieRIdFxgKwRU9zTgivNOj8DBQUzLhHE0Z0S9vAjsr8Vl5uClm0K2ywGJl7HyQCSO5tu3xgdRbDm5yqBhcpsSaiBlSKNxip24jXqE/Eb1qIeDKEpMpkzR3X9W8TfWwk1q1tD/3xYRXAgMBAAECgYAJZ6SrUvlO965it4txWRMJELy0bj9Tp6qr9+FMouRIqSNYvTK20eagu95PemEGOZu9GswHmu19avEb1Y6J/nP0Xjk+AsMV2TTv+qfhG85SOrit8/WnNoHQk9EUuFZTD/7XsgbalTHegldFKNeJy6qp8zL86+gsze8eRcOCvOlIoQJBANUfsT+1ow62y6HgBQ7BLXPcts09uxC1CA1UAYcvM4BGzoGb+4YQUWl2rEa5F6JsBwu0VzY8Nb69S8Ptp466cQcCQQCsx+3obxdhuvGJx0VjHX2tfNWKE5tcQKcBmpSSVf+7XujTQTT782ZfyxQBi6D5iLONbbZj1KZO67ucDp2kfI4xAkA1CUb9uMDUJ48zQGFh05bxD0r6dlM4DCTt1CrxLkDdukEnpd6I9USdPygODX+hLsruEbnmSEODrO3O2zRoY2M/AkBRFl9T91cM2bRjye6Jjpyd3/lDnOIL0JfQS+CwMMYdBHTWOEMKf3erO15/Py1kDsDdfgDcJz+JyF465i0btgzxAkAaNGK/0OIS1QYydSVJMGoVqN5zj5vKb43zzrs7ycd+JWD9e+YEs+VYy+clSNoklnXINAmyIcdm6zVHtI3CtSif";

    //生成秘钥对
    public static KeyPair getKeyPair() throws Exception {
        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
        keyPairGenerator.initialize(2048);
        KeyPair keyPair = keyPairGenerator.generateKeyPair();
        return keyPair;
    }

    //获取公钥(Base64编码)
    public static String getPublicKey(KeyPair keyPair) {
        PublicKey publicKey = keyPair.getPublic();
        byte[] bytes = publicKey.getEncoded();
        return byte2Base64(bytes);
    }

    //获取私钥(Base64编码)
    public static String getPrivateKey(KeyPair keyPair) {
        PrivateKey privateKey = keyPair.getPrivate();
        byte[] bytes = privateKey.getEncoded();
        return byte2Base64(bytes);
    }

    //将Base64编码后的公钥转换成PublicKey对象
    public static PublicKey string2PublicKey(String pubStr) throws Exception {
        byte[] keyBytes = base642Byte(pubStr);
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(keyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        PublicKey publicKey = keyFactory.generatePublic(keySpec);
        return publicKey;
    }

    //将Base64编码后的私钥转换成PrivateKey对象
    public static PrivateKey string2PrivateKey(String priStr) throws Exception {
        byte[] keyBytes = base642Byte(priStr);
        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(keyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        PrivateKey privateKey = keyFactory.generatePrivate(keySpec);
        return privateKey;
    }

    //公钥加密
    public static String publicEncrypt(String content, String publicKey) {
        try {
            Cipher cipher = Cipher.getInstance("RSA");
            cipher.init(Cipher.ENCRYPT_MODE, string2PublicKey(publicKey));
            byte[] bytes = cipher.doFinal(content.getBytes());
            return byte2Base64(bytes);
        } catch (Exception e) {
            log.error("公钥加密失败{}", e);
        }
        return null;
    }

    //私钥解密
    public static String privateDecrypt(String content, String privateKey) {
        try {
            Cipher cipher = Cipher.getInstance("RSA");
            cipher.init(Cipher.DECRYPT_MODE, string2PrivateKey(privateKey));
            byte[] bytes = cipher.doFinal(base642Byte(content));
            return new String(bytes);
        } catch (Exception e) {
            log.error("私钥解密失败{}", e);
        }
        return null;
    }

    //字节数组转Base64编码
    public static String byte2Base64(byte[] bytes) {
        BASE64Encoder encoder = new BASE64Encoder();
        return encoder.encode(bytes);
    }

    //Base64编码转字节数组
    public static byte[] base642Byte(String base64Key) throws IOException {
        BASE64Decoder decoder = new BASE64Decoder();
        return decoder.decodeBuffer(base64Key);
    }

    public static void main(String[] args) {
//        try {
//            String publicKeyStr = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCWY1VKIXGStXOMtSkb2nqV9A4V6MqlTPv8Dg9Sdxm8TZgOYJJxFAjpUOwt0au6q5JDTrslZngg9um1IhNJlRLEySbTvN7Bzeq6XOpZx5w6XRZ+7/o0Ui4YvcYwIHB5DgS5XJnLa3vLqWOk4NAtY0lqC20170mHi5Fmjdak63OTzwIDAQAB";
//            //=================客户端=================
//            String message = "{\"userPhone\":\"13500035111\",\"loginToken\":\"NN8dR1712810NWC78ZSFc7aOD3ymS41Q\",\"merchantNo\":\"shang001\"}";
//            //用公钥加密
//            String byte2Base64 = RSAUtil.publicEncrypt(message, publicKeyStr);
//            System.out.println("公钥加密并Base64编码的结果：" + byte2Base64);
//            //===================服务端================
//            String privateKeyStr = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAJZjVUohcZK1c4y1KRvaepX0DhXoyqVM+/wOD1J3GbxNmA5gknEUCOlQ7C3Rq7qrkkNOuyVmeCD26bUiE0mVEsTJJtO83sHN6rpc6lnHnDpdFn7v+jRSLhi9xjAgcHkOBLlcmctre8upY6Tg0C1jSWoLbTXvSYeLkWaN1qTrc5PPAgMBAAECgYAJuQBRm5npHzwKM8glmdllCnNCrVs0lqaP5CTPcw3B485Z15qAHwh4dRff2ndcySzalyN4RoirsOrpH/vZPP8KinIhOT9zcHInWMKEPqGH+twB+c0hS6x2YZFuJqW3+zy56jnUMn3MDjNF5A5N9hD6taP1V+UOqgZvYwwMSCFLkQJBANZtQS2AqahHNjPgjkWcuaG8zXzgbu0VeU+wXDjxR81aLLJBOK6AGe7w5yJnip2w/FqGxPfORcn/bLxyDHOhpQcCQQCzi5zeeiXt1cxeGGqVxNvC51PuSna9YnPs+phiwwGVdAqVdMOJzsThs5EDVhX4eQYIeA4B6PItiPLHsw+6AXD5AkAp/ac/4+xVeeyRaC40T6bCl5ieFc1jPEtPYbgNpqJrAneySLdy5L8vXZnF0QUCMICasb2s0YY1MoH2vVbW5hbNAkEAsCxD5oFQikiI2aN3ojGhuWMnFeB3Fmlueo+ByxaxjSZp5DDIVYZP5W8+0Vk9Aawu4Ux74h/i0g9Yud7XhZo4cQJARyq8WJGDawo65CVcQQ2opbL8LqApr7Co4CAKmV4YFDraY00q9h1Dbj7WO+urJz7XUqbEYG0Yga+37jQAnQHUUQ==";
//            //解密后的明文
//            System.out.println("解密后的明文: " + RSAUtil.privateDecrypt(byte2Base64, privateKeyStr));
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
        Map<Integer, String> integerStringMap = genKeyPair();
        System.out.println(JSONObject.toJSONString(integerStringMap));
    }

    public static Map<Integer, String> genKeyPair() {
        Map<Integer, String> keyMap = new HashMap<Integer, String>(); // 用于封装随机产生的公钥与私钥
        try {
            // KeyPairGenerator类用于生成公钥和私钥对，基于RSA算法生成对象
            KeyPairGenerator keyPairGen = KeyPairGenerator.getInstance("RSA");

            // 初始化密钥对生成器，密钥大小为96-1024位
            keyPairGen.initialize(1024, new SecureRandom());

            // 生成一个密钥对，保存在keyPair中
            KeyPair keyPair = keyPairGen.generateKeyPair();
            RSAPrivateKey privateKey = (RSAPrivateKey) keyPair.getPrivate(); // 得到私钥
            RSAPublicKey publicKey = (RSAPublicKey) keyPair.getPublic(); // 得到公钥

            // 得到公钥字符串
            String publicKeyString = new String(Base64.encodeBase64(publicKey.getEncoded()));
            // 得到私钥字符串
            String privateKeyString = new String(Base64.encodeBase64((privateKey.getEncoded())));
            // 将公钥和私钥保存到Map
            keyMap.put(0, publicKeyString); // 0表示公钥
            keyMap.put(1, privateKeyString); // 1表示私钥
        } catch (Exception e) {
            return null;
        }

        return keyMap;
    }

}
```

```java
"redirect:" + memberLoginRequest.getMemberWebIP().trim() + "?params=" + URLEncoder.encode(RSAUtil.publicEncrypt(jsonObject.toString(), publicKey),"utf-8");
```

服务端跳转的时候会将“+”号替换成空格，所以用URLEncoder.encode可以解决

前端解密：

```js
var encrypt = new JSEncrypt();
var publicKey = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAJZjVUohcZK1c4y1KRvaepX0DhXoyqVM+/wOD1J3GbxNmA5gknEUCOlQ7C3Rq7qrkkNOuyVmeCD26bUiE0mVEsTJJtO83sHN6rpc6lnHnDpdFn7v+jRSLhi9xjAgcHkOBLlcmctre8upY6Tg0C1jSWoLbTXvSYeLkWaN1qTrc5PPAgMBAAECgYAJuQBRm5npHzwKM8glmdllCnNCrVs0lqaP5CTPcw3B485Z15qAHwh4dRff2ndcySzalyN4RoirsOrpH/vZPP8KinIhOT9zcHInWMKEPqGH+twB+c0hS6x2YZFuJqW3+zy56jnUMn3MDjNF5A5N9hD6taP1V+UOqgZvYwwMSCFLkQJBANZtQS2AqahHNjPgjkWcuaG8zXzgbu0VeU+wXDjxR81aLLJBOK6AGe7w5yJnip2w/FqGxPfORcn/bLxyDHOhpQcCQQCzi5zeeiXt1cxeGGqVxNvC51PuSna9YnPs+phiwwGVdAqVdMOJzsThs5EDVhX4eQYIeA4B6PItiPLHsw+6AXD5AkAp/ac/4+xVeeyRaC40T6bCl5ieFc1jPEtPYbgNpqJrAneySLdy5L8vXZnF0QUCMICasb2s0YY1MoH2vVbW5hbNAkEAsCxD5oFQikiI2aN3ojGhuWMnFeB3Fmlueo+ByxaxjSZp5DDIVYZP5W8+0Vk9Aawu4Ux74h/i0g9Yud7XhZo4cQJARyq8WJGDawo65CVcQQ2opbL8LqApr7Co4CAKmV4YFDraY00q9h1Dbj7WO+urJz7XUqbEYG0Yga+37jQAnQHUUQ==";
encrypt.setPublicKey(publicKey);
var param = encrypt.decrypt(this.$route.query.params);
```

顺便记录一下前端加密后台解密：

前端加密：

```js
var encrypt = new JSEncrypt();
var publicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCWY1VKIXGStXOMtSkb2nqV9A4V6MqlTPv8Dg9Sdxm8TZgOYJJxFAjpUOwt0au6q5JDTrslZngg9um1IhNJlRLEySbTvN7Bzeq6XOpZx5w6XRZ+7/o0Ui4YvcYwIHB5DgS5XJnLa3vLqWOk4NAtY0lqC20170mHi5Fmjdak63OTzwIDAQAB";
encrypt.setPublicKey(publicKey);
var encrypted = encrypt.encrypt(query.tradePwd);
query.tradePwd = encrypted;
```

后台解密：

```java
String privateKeyStr = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAJZjVUohcZK1c4y1KRvaepX0DhXoyqVM+/wOD1J3GbxNmA5gknEUCOlQ7C3Rq7qrkkNOuyVmeCD26bUiE0mVEsTJJtO83sHN6rpc6lnHnDpdFn7v+jRSLhi9xjAgcHkOBLlcmctre8upY6Tg0C1jSWoLbTXvSYeLkWaN1qTrc5PPAgMBAAECgYAJuQBRm5npHzwKM8glmdllCnNCrVs0lqaP5CTPcw3B485Z15qAHwh4dRff2ndcySzalyN4RoirsOrpH/vZPP8KinIhOT9zcHInWMKEPqGH+twB+c0hS6x2YZFuJqW3+zy56jnUMn3MDjNF5A5N9hD6taP1V+UOqgZvYwwMSCFLkQJBANZtQS2AqahHNjPgjkWcuaG8zXzgbu0VeU+wXDjxR81aLLJBOK6AGe7w5yJnip2w/FqGxPfORcn/bLxyDHOhpQcCQQCzi5zeeiXt1cxeGGqVxNvC51PuSna9YnPs+phiwwGVdAqVdMOJzsThs5EDVhX4eQYIeA4B6PItiPLHsw+6AXD5AkAp/ac/4+xVeeyRaC40T6bCl5ieFc1jPEtPYbgNpqJrAneySLdy5L8vXZnF0QUCMICasb2s0YY1MoH2vVbW5hbNAkEAsCxD5oFQikiI2aN3ojGhuWMnFeB3Fmlueo+ByxaxjSZp5DDIVYZP5W8+0Vk9Aawu4Ux74h/i0g9Yud7XhZo4cQJARyq8WJGDawo65CVcQQ2opbL8LqApr7Co4CAKmV4YFDraY00q9h1Dbj7WO+urJz7XUqbEYG0Yga+37jQAnQHUUQ==";
//解密后的明文
System.out.println("解密后的明文: " + RSAUtil.privateDecrypt(tradePwd, privateKeyStr));
```

