public with sharing class B2BFirstTimePasswordHelper {

    // Generate a random password of specified length
    public static String generateRandomPassword(Integer passwordLength) {
        Blob aesKey = Crypto.generateAesKey(192);
        String key = EncodingUtil.base64Encode(aesKey);
        string password = '';
        key = key.replaceAll('[+/=]', ''); // Remove '+' '/' and '=' characters
        key = key.replaceAll('[^n-wA-DP-Z0-9a-mE-Ox-z]', '0'); // Replace any remaining non-alphanumeric with '0'
        //nopqrstuvwABCDPQRSTUVWXYZ0123456789abcdefghijkEFGHIJKLMNOlmxyz
        password  += key.substring(0, 8);

        return password;
    }
}