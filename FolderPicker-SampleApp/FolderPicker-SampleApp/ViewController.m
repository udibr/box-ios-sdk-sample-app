//
//  ViewController.m
//  FolderPicker-SampleApp
//
//  Created on 5/27/13.
//  Copyright (c) 2013 Box, Inc. All rights reserved.
//

#import "ViewController.h"

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
    dispatch_sync(dispatch_get_main_queue(), ^(void){
        
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
        [self boxFolderPicker];
        return;
    }
    if (error.code == BoxSDKOAuth2ErrorAccessTokenExpired) {
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^(void){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Box" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

- (IBAction)browseAction:(id)sender {
    [[BoxSDK sharedSDK].foldersManager folderInfoWithID:@"0" requestBuilder:nil
                                                success:^(BoxFolder * folder) {
                                                    [self boxFolderPicker];
                                                }
                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary){
                                                    [self boxError:error];
                                                }];
    
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


@end
