//
//  AddBookViewController.h
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryAppDelegate.h"
@interface AddBookViewController : UIViewController<UIBarPositioningDelegate,UITextFieldDelegate>
@property UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UINavigationItem *toolbarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *bookTitle;
@property (weak, nonatomic) IBOutlet UITextField *author;
@property (weak, nonatomic) IBOutlet UITextField *publisher;
@property (weak, nonatomic) IBOutlet UITextField *categories;
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property LibraryAppDelegate *delegate;
@property UIColor *userChooseColor;

-(void) resetTtile;

-(IBAction) clickOnDone:(id) sender;
-(IBAction) backgroundTap:(id)sender;
-(IBAction) clickOnSubmit:(id)sender;

-(void) showAlert;
-(void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag :(int)mode;
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
