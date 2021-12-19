//
//  MPBannerCustomEvent+Internal.h
//  MoPubSampleApp
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPBannerCustomEvent.h"

@interface MPBannerCustomEvent (Internal)

/**
 * Track impressions for trackers that are included in the creative's markup.
 * Extended class implements this method if necessary.
 * Currently, only HTML and MRAID banners use trackers included in markup.
 * Mediated networks track impressions via their own means.
 */
- (void)trackImpressionsIncludedInMarkup;

/**
 * Start viewability tracker. The default implementation of this method does nothing.
 * Subclasses can override this method if necessary.
 */
- (void)startViewabilityTracker;

@end
