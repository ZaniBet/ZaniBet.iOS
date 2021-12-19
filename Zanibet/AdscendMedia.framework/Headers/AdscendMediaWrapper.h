//
//  AdscendMediaWrapper.h
//  AdscendMedia
//
//  Created by Abhijit on 7/27/16.
//  Copyright © 2016 AdscendMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdscendMediaWrapper : NSObject

/*!
 Gets new completed offers.
 
 @param pubId - publisher Id
 @param profileId - profile Id
 @param subId1 - subId1
 */
+ (void) getCompletedOffersWithPubId:(NSString *)pubId profileId:(NSString *)profileId subId1:(NSString *)subId1 success:(void(^)(NSArray *completedOffers))success failure:(void(^)(void))failure;

/*!
 Get offers from server.
 
 @param pubId - publisher Id
 @param adWallId - adWall Id
 @param subId1 - subId1
 @param offset - offset index from which offers are to be retrieved (e.g. offset = 0 will return all offers starting from index 0 and offset = 20 will return offers starting from index 30)
 
 */
+ (void) getOfferList:(NSString *)pubId adWallId:(NSString *)adWallId subId1:(NSString *)subId1 offset:(NSUInteger)offset success:(void (^) (NSArray *offerList, BOOL moreAvailable))success failure:(void (^) (NSString *))failure;

/*!
 Get Surveys from server.
 
 @param pubId - publisher Id
 @param profileId - profile Id
 @param subId1 - subId1
 @param productId - @"4" or @"10";   
 // @"4" is for surveys on offer wall profile
 // @"10" is for surveys on mr profile
 */
+ (void) getSurveyListForPubId:(NSString *)pubId profileId:(NSString *)profileId subId1:(NSString *)subId1 productId:(NSString *)productId success:(void (^) (NSArray *surveyList))success notFound:(void (^) (void))notFound failure:(void (^) (void))failure;

/*!
 Get Transactions from server.
 
 @param pubId - publisher Id
 @param profileId - profile Id
 @param subId1 - subId1
 */
+ (void) getTransactionListForPubId:(NSString *)pubId adWallId:(NSString *)adWallId subId1:(NSString *)subId1 success:(void (^) (NSArray *transactionList))success failure:(void (^) (void))failure;

@end
