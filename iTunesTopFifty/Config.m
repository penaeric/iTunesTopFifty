//
//  Config.m
//  iTunesTopFifty
//
//  Created by Eric Pena on 11/7/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "Config.h"

@implementation Config

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}


+ (Config *)sharedInstance
{
    static Config *sharedInstance = nil;
    
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}


- (NSString *)url
{
    return @"http://itunes.apple.com/us/rss/topsongs/limit=50/xml";
}

@end
