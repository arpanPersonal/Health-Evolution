@isTest
public class B2BFirstTimePasswordHelperTest {

    @isTest
    static void testGenerateRandomPassword() {
        Integer passwordLength = 8;
        String generatedPassword = B2BFirstTimePasswordHelper.generateRandomPassword(passwordLength);
        System.assertNotEquals(generatedPassword, null, 'Generated password should not be null');
        System.assertNotEquals(generatedPassword, '', 'Generated password should not be empty');
        System.assertEquals(generatedPassword.length(), 8, 'Generated password should have a length of 8');
        //System.assertPatternMatch(generatedPassword, '^[A-Za-z0-9]+$', 'Generated password should contain only alphanumeric characters');
    }
}