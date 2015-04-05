//
//  AppDelegate.h
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LibraryData;
@class MasterViewController;
@class DetailViewController;
@interface LibraryAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (readwrite, retain) LibraryData *currentlySelectedLibraryData;

@end

