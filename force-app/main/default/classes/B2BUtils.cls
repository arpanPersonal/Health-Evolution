public with sharing class B2BUtils {
    // A cache which maps community Ids to WebStore Ids
    // private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();
  
    // // A cache to map a string to ConnectApi.CartItemSortOrder
    // private static Map<String, ConnectApi.CartItemSortOrder> sortOrderCache = new Map<String, ConnectApi.CartItemSortOrder>();
  
    // /**
    //  * @description Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning
    //  * @param  communityId The Id of the community from which the call originated
    //  * @return weStoreId The webStoreId corresponding to the community Id.
    //  * @example
    //  * String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId('0DB2D0000004Xz7');
    //  */
    // public static String resolveCommunityIdToWebstoreId(String communityId) {
    //   if (communityIdToWebStoreIdCache.containsKey(communityId)) {
    //     return communityIdToWebStoreIdCache.get(communityId);
    //   } else {
    //     String webStoreId = [
    //       SELECT WebStoreId
    //       FROM WebStoreNetwork
    //       WHERE NetworkId = :communityId
    //       WITH SECURITY_ENFORCED
    //       LIMIT 1
    //     ]
    //     .WebStoreId;
    //     communityIdToWebStoreIdCache.put(communityId, webStoreId);
    //     return webStoreId;
    //   }
    // }

    public static String getUserAccountID() {
        String userId = UserInfo.getUserId();
        String contactId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        return [SELECT AccountId FROM Contact WHERE Id = :contactId].AccountId;
    }

    public static String getUserContactID(){
        String userId = UserInfo.getUserId();
        return [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
    }

    public static String getAccountActiveOrCheckoutWebCart() {
        String effectiveAccountId = getUserAccountID();
        List <WebCart> wcs = [SELECT Id FROM WebCart WHERE (Status ='Checkout' OR Status ='Active') AND accountId =:effectiveAccountId ORDER BY CreatedDate DESC LIMIT 1];
        if (wcs.isEmpty()) {
            return null;
        }
        return wcs[0].Id;
  }
}