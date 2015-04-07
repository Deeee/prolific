//
//  MasterViewController.h
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryAppDelegate.h"
@class DetailViewController;

@interface MasterViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource,NSURLConnectionDataDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSMutableArray *loadedLibraryData;
@property (nonatomic, strong) NSArray *filterResult;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIButton *actionSheet;
@property NSMutableURLRequest *originalRequest;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, assign) CGFloat screenHeight;
@property LibraryAppDelegate *delegate;

-(void) fetchAndParseJson;

@end

