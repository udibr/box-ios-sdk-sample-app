//
//  ViewController.m
//  FolderPicker-SampleApp
//
//  Created on 5/27/13.
//  Copyright (c) 2013 Box, Inc. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic, readwrite, strong) BoxFolderPickerViewController *folderPicker;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)boxFolderPicker
{
    // On rare cases using dispatch_sync(dispatch_get_main_queue(),... will cause a crash inside the Box SDK
    // it looks like using a short timmer avoids this
    // TODO: the crash in the SDK should be fixed
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *thumbnailPath = [basePath stringByAppendingPathComponent:@"BOX"];
        
        self.folderPicker = [[BoxSDK sharedSDK] folderPickerWithRootFolderID:BoxAPIFolderIDRoot
                                                           thumbnailsEnabled:YES
                                                        cachedThumbnailsPath:thumbnailPath
                                                        fileSelectionEnabled:YES];
        self.folderPicker.delegate = self;
        
        UINavigationController *controller = [[BoxFolderPickerNavigationController alloc] initWithRootViewController:self.folderPicker];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:controller animated:YES completion:nil];
    });
}

- (void)boxError:(NSError*)error
{
    if (error.code == BoxSDKOAuth2ErrorAccessTokenExpiredOperationReachedMaxReenqueueLimit) {
        // Launch the picker again if for some reason the OAuth2 session cannot be refreshed.
        // this will bring the login screen which will be followed by the file picker itself
        [self boxFolderPicker];
        return;
    } else if (error.code == BoxSDKOAuth2ErrorAccessTokenExpired) {
        // This error code appears as part of the re-authentication process and should be ignored
        return;
    } else {
        // we really failed, let the user know
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Box" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (IBAction)browseAction:(id)sender {
    if ([BoxSDK sharedSDK].OAuth2Session.isAuthorized) {
        // in order to avoid a short lag, jump immediatly to the file picker if we are already authorized
        [self boxFolderPicker];
    } else {
        // try sending a hearbeat
        [[BoxSDK sharedSDK].foldersManager folderInfoWithID:BoxAPIFolderIDRoot requestBuilder:nil
                                                    success:^(BoxFolder * folder) {
                                                        [self boxFolderPicker];
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary){
                                                        [self boxError:error];
                                                    }];
    }
}

- (IBAction)purgeAction:(id)sender
{
    [self.folderPicker purgeCache];
}


- (void)folderPickerController:(BoxFolderPickerViewController *)controller didSelectBoxItem:(BoxItem *)item
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.nameLabel.text = [NSString stringWithFormat:@"%@ picked : %@", item.type, item.name];
        self.idLabel.text = item.modelID;
    }];
    
}

- (void)folderPickerControllerDidCancel:(BoxFolderPickerViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// We must provide a way to logout from Box because otherwise there is no way to switch Box users.
// Even deleting the App will not help because the refreshToken is stored in the keychain which is retained
- (IBAction)logoutAction:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logoutFromBox];
}

@end
