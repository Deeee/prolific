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
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag :(int)mode;
-(void) showThisAlert:(UIAlertController *) alert;

-(void) configureTextView:(UITextView *)textView WithText:(NSString *)text;
-(void) configureTextViewNonEdit:(UITextView *)textView WithText:(NSString *)text;
-(void) restoreBackToNonEdit;
-(void) resetTtile;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

-(IBAction) clickedOnCheckedout:(id)sender;
-(IBAction) clickedOnEdit:(id)sender;
-(IBAction) postToFacebook:(id)sender;
-(IBAction) postToTwitter:(id)sender;
-(IBAction) backgroundTap:(id)sender;

-(void) updateCheckedoutByWith:(NSString *)name;
-(void) deleteLibraryData;
@end

