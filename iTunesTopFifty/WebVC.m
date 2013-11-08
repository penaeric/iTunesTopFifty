//
//  WebVC.m
//  iTunesTopFifty
//
//  Created by Eric Pena on 11/7/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "WebVC.h"

@interface WebVC () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupView];
}


- (void)setupView
{
    // Load the page
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
    [self.webView loadRequest:request];
}


#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error loading page: {%@}", [error localizedDescription]);
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // Show the indicator while a page is loading
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Hide the indicator once the page is finished loading
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
