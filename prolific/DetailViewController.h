//
//  DetailViewController.h
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LibraryData;
@interface DetailViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) LibraryData *detailItem;
@property (weak, nonatomic) IBOutlet UITextField *bookTitle;
@property (weak, nonatomic) IBOutlet UITextField *author;
@property (weak, nonatomic) IBOutlet UITextField *publisher;
@property (weak, nonatomic) IBOutlet UITextField *tags;
@property (weak, nonatomic) IBOutlet UITextField *lastCheckedOut;
@property (weak, nonatomic) IBOutlet UITextField *lastCheckedOutBy;

@property (weak, nonatomic) IBOutlet UIButton *Checkout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionSheet;

-(void) showAlert;

@end

