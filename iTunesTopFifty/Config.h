//
//  Config.h
//  iTunesTopFifty
//
//  Created by Eric Pena on 11/7/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@interface Config : NSObject

/** Unique Config instance
 */
+ (Config *)sharedInstance;

/** URL where to get the songs from
 */
- (NSString *)url;

@end
