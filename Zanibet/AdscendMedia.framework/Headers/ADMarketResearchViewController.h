//
//  ADMarketResearchViewController.h
//  AdscendMedia
//
//  Created by Tabish on 2/8/16.
//  Copyright © 2016 AdscendMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ADMarketResearchVCDelegate <NSObject>
- (void)onCloseMarketResearchVCPressed;
@end


@interface ADMarketResearchViewController : UIViewController

//the only way you should access the market research surveys
+ (ADMarketResearchViewController*)newMarketResearchForPublisherId:(NSString*)publisherId profileId:(NSString*)profileId subId1:(NSString*)subId1 delegate:(id<ADMarketResearchVCDelegate>)delegate;

@property (nonatomic, weak) id<ADMarketResearchVCDelegate> delegate; //required for receiving close button call back

//optional properties
@property (nonatomic, strong) NSString* subid2;
@property (nonatomic, strong) NSString* subid3;
@property (nonatomic, strong) NSString* subid4;

//for Unity SDK only
//don't use anything under here directly as they are not meant for public use
+ (ADMarketResearchViewController*)unityMarketResearchForPublisherId:(NSString*)publisherId profileId:(NSString*)profileId subId1:(NSString*)subId1 delegate:(id<ADMarketResearchVCDelegate>)delegate;

@end