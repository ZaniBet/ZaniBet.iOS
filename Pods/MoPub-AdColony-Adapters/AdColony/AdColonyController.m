//
//  AdColonyController.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdColony/AdColony.h>
#import "AdColonyController.h"
#import "AdColonyGlobalMediationSettings.h"
#if __has_include("MoPub.h")
    #import "MoPub.h"
    #import "MPRewardedVideo.h"
#endif

typedef enum {
    INIT_STATE_UNKNOWN,
    INIT_STATE_INITIALIZED,
    INIT_STATE_INITIALIZING
} InitState;

NSString *const kAdColonyExplicitConsentGiven = @"explicit_consent_given";
NSString *const kAdColonyConsentResponse = @"consent_response";

@interface AdColonyController()

@property (atomic, assign) InitState initState;
@property (atomic, retain) NSArray *callbacks;
@property (atomic, strong) NSSet *currentAllZoneIds;
@property (atomic, assign) BOOL testModeEnabled;

@end

@implementation AdColonyController

+ (void)initializeAdColonyCustomEventWithAppId:(NSString *)appId allZoneIds:(NSArray *)allZoneIds userId:(NSString *)userId callback:(void(^)())callback {
    AdColonyController *instance = [AdColonyController sharedInstance];

    @synchronized (instance) {
        NSSet * allZoneIdsSet = [NSSet setWithArray:allZoneIds];
        BOOL zoneIdsSame = [instance.currentAllZoneIds isEqualToSet:allZoneIdsSet];

        if (instance.initState == INIT_STATE_INITIALIZED && zoneIdsSame) {
            if (callback) {
                callback();
            }
        } else {
            instance.callbacks = [instance.callbacks arrayByAddingObject:callback];

            if (instance.initState != INIT_STATE_INITIALIZING) {
                instance.initState = INIT_STATE_INITIALIZING;

                AdColonyGlobalMediationSettings *settings = [[MoPub sharedInstance] globalMediationSettingsForClass:[AdColonyGlobalMediationSettings class]];
                AdColonyAppOptions *options = [AdColonyAppOptions new];

                if (userId && userId.length > 0) {
                    options.userID = userId;
                } else if (settings && settings.customId.length > 0) {
                    options.userID = settings.customId;
                }

                instance.currentAllZoneIds = allZoneIdsSet;
                options.testMode = instance.testModeEnabled;

                if (MoPub.sharedInstance.isGDPRApplicable == MPBoolYes) {
                    [options setOption:kAdColonyExplicitConsentGiven withNumericValue:@YES];
                    [options setOption:kAdColonyConsentResponse withNumericValue:@(MoPub.sharedInstance.canCollectPersonalInfo)];
                }

                [AdColony configureWithAppID:appId zoneIDs:allZoneIds options:options completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
                    @synchronized (instance) {
                        instance.initState = INIT_STATE_INITIALIZED;
                        for (void(^localCallback)() in instance.callbacks) {
                            localCallback();
                        }
                    }
                }];
            }
        }
    }
}

+ (void)enableClientSideTestMode {
    AdColonyController *instance = [AdColonyController sharedInstance];

    @synchronized (instance) {
        instance.testModeEnabled = YES;

        if (instance.initState == INIT_STATE_INITIALIZED || instance.initState == INIT_STATE_INITIALIZING) {
            AdColonyAppOptions *options = [AdColony getAppOptions];
            options.testMode = YES;
            [AdColony setAppOptions:options];
        }
    }
}

+ (void)disableClientSideTestMode {
    AdColonyController *instance = [AdColonyController sharedInstance];

    @synchronized (instance) {
        instance.testModeEnabled = NO;

        if (instance.initState == INIT_STATE_INITIALIZED || instance.initState == INIT_STATE_INITIALIZING) {
            AdColonyAppOptions *options = [AdColony getAppOptions];
            options.testMode = NO;
            [AdColony setAppOptions:options];
        }
    }
}

+ (AdColonyController *)sharedInstance {
    static dispatch_once_t onceToken;
    static AdColonyController *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [AdColonyController new];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _initState = INIT_STATE_UNKNOWN;
        _callbacks = @[];
    }
    return self;
}

@end
