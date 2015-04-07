//
//  DetailViewController.m
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import "DetailViewController.h"
#import "LibraryAppDelegate.h"
#import <Social/Social.h>
#import "LibraryData.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_M_B(s) [UIFont fontWithName:@"Machinato-Bold" size:s]
#define FONT_M(s) [UIFont fontWithName:@"Machinato" size:s]
#define FONT_M_EL(s) [UIFont fontWithName:@"Machinato-ExtraLight" size:s]

@interface DetailViewController ()

@end

@implementation DetailViewController {
    UIAlertController *alertController;
    NSDateFormatter *serverDateFormat;
}
@synthesize backgroundImageView;
@synthesize userChooseColor;
@synthesize delegate =_delegate;
#pragma mark - Managing the detail item

- (void)setDetailItem:(LibraryData*)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [self configureView];
    }
}

-(void) configureTextView:(UITextView *)textView WithText:(NSString *)text {
    
    [self.actionSheet setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont fontWithName:@"Machinato-ExtraLight" size:15.0], NSFontAttributeName,
                                              userChooseColor, NSForegroundColorAttributeName,
                                              nil]
                                    forState:UIControlStateNormal];
    [textView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [textView.layer setBorderWidth:2.0];
    textView.alpha = 0.7;
    textView.layer.cornerRadius = 5;
    textView.clipsToBounds = YES;
    textView.editable = NO;
    textView.text = text;
    if ([text containsString:@"0(NSNull)"]) {
        textView.hidden = YES;
    }
    
}
-(void) configureTextViewNonEdit:(UITextView *)textView WithText:(NSString *)text {
    
    if ([textView.text containsString:@"0(NSNull)"] || [textView.text isEqualToString:@""]) {
        textView.hidden = YES;
    }
    else {
        textView.hidden = NO;
    }
    textView.text = text;

    
}
- (void)configureView {
    serverDateFormat = [[NSDateFormatter alloc] init];
    [serverDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if (self.detailItem) {
        [self resetTtile];
        self.bookTitle.font = FONT_M(22);
        self.author.font = FONT_M(20);
        self.publisher.font = FONT_M_EL(18);
        self.tags.font = FONT_M_EL(18);
        self.lastCheckedOutBy.font = FONT_M_EL(18);
        [self configureTextView:self.bookTitle WithText:_detailItem.title];
        [self configureTextView:self.author WithText:_detailItem.author];
        [self configureTextView:self.publisher WithText:[NSString stringWithFormat:@"Publisher: %@", _detailItem.publisher]];
        [self configureTextView:self.tags WithText:[NSString stringWithFormat:@"Tags: %@",_detailItem.categories]];
        [self configureTextView:self.lastCheckedOutBy WithText:[NSString stringWithFormat:@"Last Checked Out:\n%@ @ %@",_detailItem.lastCheckedOutBy,_detailItem.lastCheckedOut]];
        

        
    }
}

-(IBAction)clickedOnCheckedout:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information Needed"
                                                        message:@"Please give your name and checkedout date"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Confirm", nil];
    alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alertView show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
    }else{
        NSString *name = [[alertView textFieldAtIndex:0] text];
        if (![name isEqualToString:@""]) {
            [self updateCheckedoutByWith:name];
        }
        else {
            [self alertStatus:@"Error" :@"Name cannot be empty" :1 :1];
        }
    }
}


- (void) updateCheckedoutByWith:(NSString *)name {
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143%@",_detailItem.url]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *sendData = @"lastCheckedOutBy=";
    sendData = [sendData stringByAppendingString:[NSString stringWithFormat:@"%@", name]];
    
    NSDate *currentTime = [NSDate date];
    NSString *dateWithFormat = [serverDateFormat stringFromDate: currentTime];
    
    sendData = [sendData stringByAppendingString:[NSString stringWithFormat:@"&lastCheckedOut=%@",dateWithFormat]];
    [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            [self alertStatus:@"You have successfully checked out the book!" :@"Success" :1 :3];
        }
        else {            
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"CheckedOut failed" :errorMsg :1 :1];
        }
    }];
    
    
    
    
}
- (void) deleteLibraryData {
    
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143%@",_detailItem.url]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            [self alertStatus:@"Delete succeed!" :@"Success" :1 :11];
            NSLog(@"Status Code: %li %@", (long)urlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]);
            NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
        else {
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"Delete failed" :errorMsg :1 :1];
            
            NSLog(@"An error occured, Status Code: %li, respsonse : %@", (long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            NSLog(@"Description: %@", [error localizedDescription]);
            
        }
    }];
    
    
    
    
}

- (void) restoreBackToNonEdit {
    self.bookTitle.editable = NO;
    self.author.editable = NO;
    self.publisher.editable = NO;
    self.tags.editable = NO;
    
    [self.Checkout removeTarget:nil action:NULL forControlEvents: UIControlEventTouchUpInside];
    [self.Checkout addTarget:self action:@selector(clickedOnCheckedout:) forControlEvents:UIControlEventTouchUpInside];
    [self.Checkout setTintColor:userChooseColor];
    self.Checkout.titleLabel.text = @"Check Out";
    [self configureTextViewNonEdit:self.bookTitle WithText:self.bookTitle.text];
    [self configureTextViewNonEdit:self.author WithText:self.author.text];
    [self configureTextViewNonEdit:self.publisher WithText:[NSString stringWithFormat:@"Publisher: %@",self.publisher.text]];
    [self configureTextViewNonEdit:self.tags WithText:[NSString stringWithFormat:@"Tags: %@",self.tags.text]];
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag :(int)mode
{
    if (mode == 1) {
        NSLog(@"here");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        alertView.tag = tag;
        [alertView show];
    }
    else if (mode == 2){
        NSLog(@"here");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Confirm", nil];
        alertView.tag = tag;
        [alertView show];
        
    }
    else if (mode == 12) {
        alertController = [UIAlertController
                           alertControllerWithTitle:title
                           message:msg
                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self restoreBackToNonEdit];
                                       UIViewController *vc = [self presentingViewController];
                                       [vc dismissViewControllerAnimated:YES completion:nil];
                                   }];
        [alertController addAction:okAction];
        [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
    }
    else if (mode == 11) {
        alertController = [UIAlertController
                           alertControllerWithTitle:title
                           message:msg
                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                   }];
        [alertController addAction:okAction];
        [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
    }
    else {
        NSLog(@"in successful checkout");
        
        alertController = [UIAlertController
                           alertControllerWithTitle:title
                           message:msg
                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"poping back!");
                                   }];
        [alertController addAction:okAction];
        [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];

    }
    
}


-(IBAction)clickedOnEdit:(id)sender {
    
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143%@",_detailItem.url]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *sendData;
    
    NSMutableString *updateRequest = [[NSMutableString alloc] init];
    if (![self.bookTitle.text isEqualToString:self.detailItem.title]) {
        if ([self.bookTitle.text isEqualToString:@""]) {
            [self alertStatus:@"Please make sure book title field is filled out!" :@"Submit Failed!" :0:1];
        }
        else  {
            [updateRequest appendFormat:@"title=%@&",self.bookTitle.text];
        }
    }
    if (![self.author.text isEqualToString:self.detailItem.author]) {
        if ([self.author.text isEqualToString:@""]) {
            [self alertStatus:@"Please make sure author field is filled out!" :@"Submit Failed!" :0:1];
        }
        else {
            [updateRequest appendFormat:@"author=%@&",self.author.text];
        }
    }
    if (![self.publisher.text isEqualToString:self.detailItem.publisher]) {
        [updateRequest appendFormat:@"publisher=%@&",self.publisher.text];
    }
    if (![self.tags.text isEqualToString:self.detailItem.categories]) {
        [updateRequest appendFormat:@"categories=%@&",self.tags.text];
    }
    if ([updateRequest isEqualToString:@""]) {
        [self restoreBackToNonEdit];
        return;
    }
    if ([updateRequest characterAtIndex:([updateRequest length] - 1)] == '&') {
        sendData = [updateRequest substringToIndex:[updateRequest length] - 1];
    }
    else {
        sendData = [NSString stringWithString:updateRequest];
    }
    [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"sending request %@",sendData);
    
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            [self alertStatus:@"You have successfully edited the information about this book!" :@"Success" :1 :12];
        }
        else {
            
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"Edited failed" :errorMsg :1 :1];
        }
    }];

}

- (IBAction)postToFacebook:(id)sender {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[NSString stringWithFormat:@"%@, I love this book!!",_detailItem.title]];
        [self presentViewController:controller animated:YES completion:Nil];
}

- (IBAction)postToTwitter:(id)sender {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@, I love this book!!",_detailItem.title]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
}

-(IBAction)clickedOnActionSheet:(id)sender {
    alertController = [UIAlertController
                       alertControllerWithTitle:@"Actions"
                       message:@"Choose your action"
                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *shareFBAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Share On FaceBook", @"Share Facebook action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self performSelectorOnMainThread:@selector(postToFacebook:) withObject:nil waitUntilDone:NO];
                               }];
    [alertController addAction:shareFBAction];
    UIAlertAction *shareTTAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Share On Twitter", @"Share Twitter action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {

                                        [self performSelectorOnMainThread:@selector(postToTwitter:) withObject:nil waitUntilDone:NO];
                                    }];
    [alertController addAction:shareTTAction];
    UIAlertAction *editAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Edit", @"Edit action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      self.bookTitle.editable = YES;
                                      self.author.editable = YES;
                                      self.publisher.editable = YES;
                                      self.tags.editable = YES;
                                      
                                      self.bookTitle.hidden = NO;
                                      self.author.hidden = NO;
                                      self.publisher.hidden = NO;
                                      self.tags.hidden = NO;
                                      
                                      self.publisher.text = [self.publisher.text substringWithRange:NSMakeRange(11, [self.publisher.text length]-11)];
                                      self.tags.text = [self.tags.text substringWithRange:NSMakeRange(6, [self.tags.text length]-6)];
                                      NSLog(@"in edit action %@, %@",self.publisher.text, self.tags.text);
                                      [self.Checkout removeTarget:nil action:NULL forControlEvents: UIControlEventTouchUpInside];
                                      [self.Checkout addTarget:self action:@selector(clickedOnEdit:) forControlEvents:UIControlEventTouchUpInside];
                                      [self.Checkout setTintColor:[UIColor redColor]];
                                      self.Checkout.titleLabel.text = @"Confirm";

                                  }];
    [alertController addAction:editAction];
    UIAlertAction *deleteAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Delete", @"Delete action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      UIAlertController *temp = [UIAlertController
                                                                 alertControllerWithTitle:@"Confirm on delete"
                                                                 message:@"Are you sure you want to delete this book's information?"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                      UIAlertAction *confirmAction = [UIAlertAction
                                                                    actionWithTitle:NSLocalizedString(@"Confirm", @"Confirm action")
                                                                    style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action)
                                                                    {
                                                                        [self deleteLibraryData];
                                                                    }];
                                      [temp addAction:confirmAction];
                                      UIAlertAction *cancelAction = [UIAlertAction
                                                                      actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                                      style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action)
                                                                      {
                                                                      }];
                                      [temp addAction:cancelAction];
                                      [self performSelectorOnMainThread:@selector(showThisAlert:) withObject:temp waitUntilDone:NO];


                                      
                                  }];
    [alertController addAction:deleteAction];
    UIAlertAction *cancelAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                  }];
    [alertController addAction:cancelAction];
    [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];

}
-(void) showAlert {
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) showThisAlert:(UIAlertController *) alert {
    [self presentViewController:alert animated:YES completion:nil];

}

-(void) resetTtile {
    _delegate = [UIApplication sharedApplication].delegate;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = FONT_M_B(22);
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    self.userChooseColor = _delegate.userChooseColor;
    label.textColor = self.userChooseColor; // change this color
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(_detailItem.title, @"");
    [label sizeToFit];
}
- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.actionSheet setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont fontWithName:@"Machinato-ExtraLight" size:15.0], NSFontAttributeName,
                                              userChooseColor, NSForegroundColorAttributeName,
                                              nil]
                                    forState:UIControlStateNormal];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    self.Checkout.titleLabel.font = FONT_M_B(22);
    self.Checkout.titleLabel.text = @"Check Out";
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormat setDateFormat:@"MMMM dd, hh:mm a"];
    NSDate *serverDate = [serverDateFormat dateFromString:_detailItem.lastCheckedOut];
    NSString *serverDateString = [dateFormat stringFromDate:serverDate];
    _detailItem.lastCheckedOut = serverDateString;
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
