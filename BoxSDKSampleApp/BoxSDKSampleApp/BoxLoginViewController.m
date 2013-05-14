//
//  BoxLoginViewController.m
//  BoxSDKSampleApp
//
//  Created on 3/2/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <BoxSDK/BoxSDK.h>

#import "BoxFolderViewController.h"
#import "BoxLoginViewController.h"

@interface BoxLoginViewController ()
@property (nonatomic, readwrite, strong) BoxAuthorizationViewController *authorizationController;

- (void)boxAPIAuthenticationDidSucceed:(NSNotification *)notification;
- (void)boxAPIAuthenticationDidFail:(NSNotification *)notification;
- (void)boxAPIInitiateLogin:(NSNotification *)notification;

@end

@implementation BoxLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create Box Authorization controller

    self.authorizationController = [[BoxAuthorizationViewController alloc]
                                    initWithOAuth2Session:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIAuthenticationDidSucceed:)
                                                 name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIAuthenticationDidFail:)
                                                 name:BoxOAuth2SessionDidReceiveAuthenricationErrorNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIInitiateLogin:)
                                                 name:BoxOAuth2SessionDidReceiveRefreshErrorNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];

    // attempt to heartbeat. This will succeed if we successfully refresh
    BoxFolderBlock successBlock = ^(BoxFolder *folder)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            // A user's root folder has ID = 0
            BoxFolderViewController *folderViewController = [BoxFolderViewController folderViewFromStoryboardWithFolderID:@"0" folderName:@"All Files"];

            [self.navigationController pushViewController:folderViewController animated:YES];
        });
    };

    [[BoxSDK sharedSDK].foldersManager folderInfoWithID:@"0" requestBuilder:nil success:successBlock failure:nil];
}

#pragma mark - Handle OAuth2 session notifications
- (void)boxAPIAuthenticationDidSucceed:(NSNotification *)notification
{
    NSLog(@"Received OAuth2 successfully authenticated notification");
    BoxOAuth2Session *session = (BoxOAuth2Session *) [notification object];
    NSLog(@"Access token  (%@) expires at %@", session.accessToken, session.accessTokenExpiration);
    NSLog(@"Refresh token (%@)", session.refreshToken);

    [self.authorizationController dismissViewControllerAnimated:YES completion:nil];

    dispatch_sync(dispatch_get_main_queue(), ^{
        // A user's root folder has ID = 0
        BoxFolderViewController *folderViewController = [BoxFolderViewController folderViewFromStoryboardWithFolderID:@"0" folderName:@"All Files"];

        [self.navigationController pushViewController:folderViewController animated:YES];
    });
}

- (void)boxAPIAuthenticationDidFail:(NSNotification *)notification
{
    NSLog(@"Received OAuth2 failed authenticated notification");
    NSString *oauth2Error = [[notification userInfo] valueForKey:BoxOAuth2AuthenticationErrorKey];
    NSLog(@"Authentication error  (%@)", oauth2Error);

    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.authorizationController dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)boxAPIInitiateLogin:(NSNotification *)notification
{
    NSLog(@"Refresh failed. User is logged out. Initiate login flow");

    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.navigationController popToViewController:self animated:YES];

        [self presentViewController:self.authorizationController animated:YES completion:nil];
    });
    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIButton events
- (IBAction)clickLoginButton:(id)sender
{
    [self presentViewController:self.authorizationController animated:YES completion:nil];
}

@end
