//
//  DetailViewController.h
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LibraryData;
@class LibraryAppDelegate;
@interface DetailViewController : UIViewController<UIAlertViewDelegate>
@property UIImageView *backgroundImageView;
@property (strong, nonatomic) LibraryData *detailItem;
@property (weak, nonatomic) IBOutlet UITextView *bookTitle;
@property (weak, nonatomic) IBOutlet UITextView *author;
@property (weak, nonatomic) IBOutlet UITextView *publisher;
@property (weak, nonatomic) IBOutlet UITextView *tags;
@property (weak, nonatomic) IBOutlet UITextView *lastCheckedOut;
@property (weak, nonatomic) IBOutlet UITextView *lastCheckedOutBy;

@property (weak, nonatomic) IBOutlet UIButton *Checkout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionSheet;
@property UIColor *userChooseColor;
@property LibraryAppDelegate *delegate;

-(void) showAlert;

@end

