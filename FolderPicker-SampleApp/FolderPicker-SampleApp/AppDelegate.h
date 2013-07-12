//
//  AppDelegate.h
//  FolderPicker-SampleApp
//
//  Created on 5/27/13.
//  Copyright (c) 2013 Box, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

- (void)logoutFromBox;

@end
