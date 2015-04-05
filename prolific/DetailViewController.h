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
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UILabel *publisher;
@property (weak, nonatomic) IBOutlet UILabel *tags;
@property (weak, nonatomic) IBOutlet UILabel *lastCheckedOut;
@property (weak, nonatomic) IBOutlet UIButton *Checkout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionSheet;

-(void) showAlert;

@end

