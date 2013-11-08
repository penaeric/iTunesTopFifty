//
//  AppDelegate.m
//  iTunesTopFifty
//
//  Created by Eric Pena on 11/7/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "AppDelegate.h"
#import "UIKit+AFNetworking.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return YES;
}

@end
