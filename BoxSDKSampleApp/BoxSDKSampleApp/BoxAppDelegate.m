//
//  BoxAppDelegate.m
//  BoxSDKSampleApp
//
//  Created on 2/19/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxAppDelegate.h"

#import "KeychainItemWrapper.h"

#define REFRESH_TOKEN_KEY   (@"box_api_refresh_token")

@interface BoxAppDelegate ()

@property (nonatomic, readwrite, strong) KeychainItemWrapper *keychain;
- (void)boxAPITokensDidRefresh:(NSNotification *)notification;

@end

@implementation BoxAppDelegate

@synthesize keychain = _keychain;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup BoxSDK
#warning Set your client ID and client secret in the BoxSDK
#warning Register your app for the URL scheme boxsdk-YOUR_CLIENT_ID in BoxSDKSampleApp-Info.plist
    [BoxSDK sharedSDK].OAuth2Session.clientID = @"YOUR_CLIENT_ID";
    [BoxSDK sharedSDK].OAuth2Session.clientSecret = @"YOUR_CLIENT_SECRET";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPITokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPITokensDidRefresh:)
                                                 name:BoxOAuth2SessionDidRefreshTokensNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];

    // set up stored OAuth2 refresh token
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:REFRESH_TOKEN_KEY accessGroup:nil];

    id storedRefreshToken = [self.keychain objectForKey:(__bridge id)kSecValueData];
    if (storedRefreshToken)
    {
        [BoxSDK sharedSDK].OAuth2Session.refreshToken = storedRefreshToken;
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    [[BoxSDK sharedSDK].OAuth2Session performAuthorizationCodeGrantWithReceivedURL:url];
    return YES;
}

- (void)boxAPITokensDidRefresh:(NSNotification *)notification
{
    BoxOAuth2Session *OAuth2Session = (BoxOAuth2Session *) notification.object;

    [self.keychain setObject:@"BoxSDKSampleApp" forKey: (__bridge id)kSecAttrService];
    [self.keychain setObject:OAuth2Session.refreshToken forKey:(__bridge id)kSecValueData];
}

@end
