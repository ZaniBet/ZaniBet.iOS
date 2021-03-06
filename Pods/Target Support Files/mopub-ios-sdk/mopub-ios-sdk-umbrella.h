#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MoPub_AbstractAvidAdSession.h"
#import "MoPub_AbstractAvidManagedAdSession.h"
#import "MoPub_Avid.h"
#import "MoPub_AvidAdSessionManager.h"
#import "MoPub_AvidDeferredAdSessionListener.h"
#import "MoPub_AvidDisplayAdSession.h"
#import "MoPub_AvidManagedDisplayAdSession.h"
#import "MoPub_AvidManagedVideoAdSession.h"
#import "MoPub_AvidVideoAdSession.h"
#import "MoPub_AvidVideoPlaybackListener.h"
#import "MoPub_ExternalAvidAdSessionContext.h"
#import "MPViewabilityAdapterAvid.h"
#import "MPBannerAdManager.h"
#import "MPBannerAdManagerDelegate.h"
#import "MPBannerCustomEvent+Internal.h"
#import "MPBannerCustomEventAdapter.h"
#import "MPBaseBannerAdapter.h"
#import "MPPrivateBannerCustomEventDelegate.h"
#import "MPAdAlertGestureRecognizer.h"
#import "MPAdAlertManager.h"
#import "MPActivityViewControllerHelper+TweetShare.h"
#import "MPActivityViewControllerHelper.h"
#import "MPAdBrowserController.h"
#import "MPAdConfiguration.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPAdImpressionTimer.h"
#import "MPAdServerCommunicator.h"
#import "MPAdServerURLBuilder.h"
#import "MPAPIEndpoints.h"
#import "MPClosableView.h"
#import "MPCountdownTimerView.h"
#import "MPEnhancedDeeplinkRequest.h"
#import "MPLastResortDelegate.h"
#import "MPProgressOverlayView.h"
#import "MPRealTimeTimer.h"
#import "MPURLActionInfo.h"
#import "MPURLResolver.h"
#import "MPVideoConfig.h"
#import "MPXMLParser.h"
#import "MPAdWebViewAgent.h"
#import "MPHTMLBannerCustomEvent.h"
#import "MPHTMLInterstitialCustomEvent.h"
#import "MPHTMLInterstitialViewController.h"
#import "MPWebView.h"
#import "MPBaseInterstitialAdapter.h"
#import "MPInterstitialAdManager.h"
#import "MPInterstitialAdManagerDelegate.h"
#import "MPInterstitialCustomEventAdapter.h"
#import "MPInterstitialViewController.h"
#import "MPPrivateInterstitialCustomEventDelegate.h"
#import "MPAdServerKeys.h"
#import "MPAdvancedBiddingManager.h"
#import "MPConsentDialogViewController.h"
#import "MPConsentManager.h"
#import "MPCoreInstanceProvider.h"
#import "MPHTTPNetworkSession.h"
#import "MPHTTPNetworkTaskData.h"
#import "MPMediationManager.h"
#import "MPMemoryCache.h"
#import "MPReachabilityManager.h"
#import "MPURL.h"
#import "MPURLRequest.h"
#import "MPVASTTracking.h"
#import "MPForceableOrientationProtocol.h"
#import "MPMRAIDBannerCustomEvent.h"
#import "MPMRAIDInterstitialCustomEvent.h"
#import "MPMRAIDInterstitialViewController.h"
#import "MRBridge.h"
#import "MRBundleManager.h"
#import "MRCommand.h"
#import "MRConstants.h"
#import "MRController.h"
#import "MRError.h"
#import "MRExpandModalViewController.h"
#import "MRNativeCommandHandler.h"
#import "MRProperty.h"
#import "MRVideoPlayerManager.h"
#import "NSBundle+MPAdditions.h"
#import "NSDate+MPAdditions.h"
#import "NSDictionary+MPAdditions.h"
#import "NSError+MPAdditions.h"
#import "NSHTTPURLResponse+MPAdditions.h"
#import "NSJSONSerialization+MPAdditions.h"
#import "NSMutableArray+MPAdditions.h"
#import "NSString+MPAdditions.h"
#import "NSString+MPConsentStatus.h"
#import "NSURL+MPAdditions.h"
#import "UIButton+MPAdditions.h"
#import "UIColor+MPAdditions.h"
#import "UIView+MPAdditions.h"
#import "UIWebView+MPAdditions.h"
#import "MOPUBExperimentProvider.h"
#import "MPAnalyticsTracker.h"
#import "MPError.h"
#import "MPGeolocationProvider.h"
#import "MPGlobal.h"
#import "MPIdentityProvider.h"
#import "MPInternalUtils.h"
#import "MPLogging.h"
#import "MPLogProvider.h"
#import "MPReachability.h"
#import "MPSessionTracker.h"
#import "MPStoreKitProvider.h"
#import "MPTimer.h"
#import "MPUserInteractionGestureRecognizer.h"
#import "MPVASTAd.h"
#import "MPVASTCompanionAd.h"
#import "MPVASTCreative.h"
#import "MPVASTDurationOffset.h"
#import "MPVASTIndustryIcon.h"
#import "MPVASTInline.h"
#import "MPVASTLinearAd.h"
#import "MPVASTMacroProcessor.h"
#import "MPVASTManager.h"
#import "MPVASTMediaFile.h"
#import "MPVASTModel.h"
#import "MPVASTResource.h"
#import "MPVASTResponse.h"
#import "MPVASTStringUtilities.h"
#import "MPVASTTrackingEvent.h"
#import "MPVASTWrapper.h"
#import "MoPub-Bridging-Header.h"
#import "MoPub.h"
#import "MOPUBDisplayAgentType.h"
#import "MPAdConversionTracker.h"
#import "MPAdvancedBidder.h"
#import "MPAdView.h"
#import "MPBannerCustomEvent.h"
#import "MPBannerCustomEventDelegate.h"
#import "MPBool.h"
#import "MPConsentChangedNotification.h"
#import "MPConsentChangedReason.h"
#import "MPConsentError.h"
#import "MPConsentStatus.h"
#import "MPConstants.h"
#import "MPInterstitialAdController.h"
#import "MPInterstitialCustomEvent.h"
#import "MPInterstitialCustomEventDelegate.h"
#import "MPLogLevel.h"
#import "MPMediationSdkInitializable.h"
#import "MPMediationSettingsProtocol.h"
#import "MPMoPubConfiguration.h"
#import "MPNativeAdRequest+MPNativeAdSource.h"
#import "MPAdPlacerInvocation.h"
#import "MPCollectionViewAdPlacerCell.h"
#import "MPDiskLRUCache.h"
#import "MPImageDownloadQueue.h"
#import "MPMoPubNativeAdAdapter.h"
#import "MPMoPubNativeCustomEvent.h"
#import "MPNativeAd+Internal.h"
#import "MPNativeAdConfigValues+Internal.h"
#import "MPNativeAdConfigValues.h"
#import "MPNativeAdRendererConstants.h"
#import "MPNativeAdRendererImageHandler.h"
#import "MPNativeAdSourceQueue.h"
#import "MPNativeAdUtils.h"
#import "MPNativeCache.h"
#import "MPNativePositionResponseDeserializer.h"
#import "MPNativePositionSource.h"
#import "MPNativeView.h"
#import "MPTableViewAdPlacerCell.h"
#import "MPTableViewCellImpressionTracker.h"
#import "MPAdPositioning.h"
#import "MPClientAdPositioning.h"
#import "MPCollectionViewAdPlacer.h"
#import "MPNativeAd.h"
#import "MPNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdData.h"
#import "MPNativeAdDelegate.h"
#import "MPNativeAdError.h"
#import "MPNativeAdRenderer.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPNativeAdRendererSettings.h"
#import "MPNativeAdRendering.h"
#import "MPNativeAdRenderingImageLoader.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPNativeAdSource.h"
#import "MPNativeAdSourceDelegate.h"
#import "MPNativeCustomEvent.h"
#import "MPNativeCustomEventDelegate.h"
#import "MPServerAdPositioning.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPStreamAdPlacementData.h"
#import "MPStreamAdPlacer.h"
#import "MPTableViewAdPlacer.h"
#import "MOPUBActivityIndicatorView.h"
#import "MOPUBAVPlayer.h"
#import "MOPUBAVPlayerView.h"
#import "MOPUBFullscreenPlayerViewController.h"
#import "MOPUBNativeVideoAdAdapter.h"
#import "MOPUBNativeVideoAdConfigValues.h"
#import "MOPUBNativeVideoCustomEvent.h"
#import "MOPUBNativeVideoImpressionAgent.h"
#import "MOPUBPlayerManager.h"
#import "MOPUBPlayerView.h"
#import "MOPUBPlayerViewController.h"
#import "MOPUBReplayView.h"
#import "MOPUBNativeVideoAdRenderer.h"
#import "MOPUBNativeVideoAdRendererSettings.h"
#import "MPMoPubRewardedPlayableCustomEvent.h"
#import "MPMoPubRewardedVideoCustomEvent.h"
#import "MPPrivateRewardedVideoCustomEventDelegate.h"
#import "MPRewardedVideo+Internal.h"
#import "MPRewardedVideoAdapter.h"
#import "MPRewardedVideoAdManager.h"
#import "MPRewardedVideoConnection.h"
#import "MPRewardedVideo.h"
#import "MPRewardedVideoCustomEvent+Caching.h"
#import "MPRewardedVideoCustomEvent.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideoReward.h"
#import "MPViewabilityAdapter.h"
#import "MPViewabilityOption.h"
#import "MPViewabilityTracker.h"
#import "MPWebView+Viewability.h"
#import "MPViewabilityAdapterMoat.h"

FOUNDATION_EXPORT double MoPubVersionNumber;
FOUNDATION_EXPORT const unsigned char MoPubVersionString[];

