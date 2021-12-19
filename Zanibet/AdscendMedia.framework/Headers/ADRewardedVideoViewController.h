//
//  ADRewardedVideoViewController.h
//  AdscendMedia
//
//  Created by Tabish on 9/29/15.
//  Copyright © 2015 AdscendMedia. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ADRewardedVideoViewControllerDelegate <NSObject>
- (void)onUserCredited;
- (void)onUserNotCredited;
- (void)onCloseVideoVCPressed;
@end

@interface ADRewardedVideoViewController : UIViewController

+ (void) newRewardedVideoForPublisherId:(NSString*)publisherId profileId:(NSString*)profileId subId1:(NSString*)subId1 delegate:(id<ADRewardedVideoViewControllerDelegate>)delegate success:(void (^) (ADRewardedVideoViewController *))success failure:(void (^) (NSString *))failure;

- (void) presentFrom:(UIViewController *)fromController failure:(void (^) (NSString *))failure;

@property (nonatomic, weak) id<ADRewardedVideoViewControllerDelegate> delegate; //required for receiving user credited call back

//for Unity SDK only
//don't use anything under here directly as they are not meant for public use
+ (void) unityRewardedVideoForPublisherId:(NSString*)publisherId profileId:(NSString*)profileId subId1:(NSString*)subId1 delegate:(id<ADRewardedVideoViewControllerDelegate>)delegate success:(void (^) (ADRewardedVideoViewController *))success failure:(void (^) (NSString *))failure;


@end
