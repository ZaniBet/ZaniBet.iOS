//
//  MPUnityRouter.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MPUnityRouter.h"
#import "UnityAdsInstanceMediationSettings.h"

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MoPub.h"
    #import "MPRewardedVideoError.h"
    #import "MPRewardedVideo.h"
#endif

@interface MPUnityRouter ()

@property (nonatomic, assign) BOOL isAdPlaying;

@end

@implementation MPUnityRouter

- (id) init {
    self = [super init];
    self.delegateMap = [[NSMutableDictionary alloc] init];

    return self;
}

+ (MPUnityRouter *)sharedRouter
{
    static MPUnityRouter * sharedRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRouter = [[MPUnityRouter alloc] init];
    });
    return sharedRouter;
}

- (void)initializeWithGameId:(NSString *)gameId
{
    static dispatch_once_t unityInitToken;
    dispatch_once(&unityInitToken, ^{
        UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setName:@"MoPub"];
        [mediationMetaData setVersion:[[MoPub sharedInstance] version]];
        [mediationMetaData commit];
        [UnityAds initialize:gameId delegate:self];
    });
}

- (void)requestVideoAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId delegate:(id<MPUnityRouterDelegate>)delegate;
{
    // Collect and pass the user's consent/non-consent from MoPub to the Unity Ads SDK
    if ([[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusConsented || [[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusDenied) {
        UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];

        // If the user consented - pass YES
        // If the user denied - pass NO
        if([[MoPub sharedInstance] currentConsentStatus] == MPConsentStatusConsented) {
            [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
        }
        else {
            [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
        }

        [gdprConsentMetaData commit];
    }

    if (!self.isAdPlaying) {
        [self.delegateMap setObject:delegate forKey:placementId];
        [self initializeWithGameId:gameId];

        // Need to check immediately as an ad may be cached.
        if ([self isAdAvailableForPlacementId:placementId]) {
            [self unityAdsReady:placementId];
        }
        // MoPub timeout will handle the case for an ad failing to load.
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId
{
    return [UnityAds isReady:placementId];
}

- (void)presentVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate
{
    if (!self.isAdPlaying && [self isAdAvailableForPlacementId:placementId]) {
        self.isAdPlaying = YES;
        self.currentPlacementId = placementId;
        [UnityAds show:viewController placementId:placementId];
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

- (id<MPUnityRouterDelegate>)getDelegate:(NSString*) placementId {
    return [self.delegateMap valueForKey:placementId];
}

- (void)clearDelegate:(id<MPUnityRouterDelegate>)delegate
{
    if (self.delegate == delegate)
    {
        [self setDelegate:nil];
    }
}

#pragma mark - UnityAdsExtendedDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    if (!self.isAdPlaying) {
        id delegate = [self getDelegate:placementId];
        if (delegate != nil) {
            [delegate unityAdsReady:placementId];
        }
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    id delegate = [self getDelegate:self.currentPlacementId];
    if (delegate != nil) {
        [delegate unityAdsDidError:error withMessage:message];
    }
}

- (void)unityAdsDidStart:(NSString *)placementId {
    id delegate = [self getDelegate:placementId];
    if (delegate != nil) {
        [delegate unityAdsDidStart:placementId];
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    id delegate = [self getDelegate:placementId];
    if (delegate != nil) {
        [delegate unityAdsDidFinish:placementId withFinishState:state];
    }
    [self.delegateMap removeObjectForKey:placementId];
    self.isAdPlaying = NO;
}

- (void)unityAdsDidClick:(NSString *)placementId {
    id delegate = [self getDelegate:placementId];
    if (delegate != nil) {
        [delegate unityAdsDidClick:placementId];
    }
}

- (void)unityAdsPlacementStateChanged:(NSString *)placementId oldState:(UnityAdsPlacementState)oldState newState:(UnityAdsPlacementState)newState {
    id delegate = [self getDelegate:placementId];
    if (delegate != nil && [delegate respondsToSelector:@selector(unityAdsPlacementStateChanged:oldState:newState:)]) {
        [delegate unityAdsPlacementStateChanged:placementId oldState:oldState newState:newState];
    }
}

@end
