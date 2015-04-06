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
@interface DetailViewController ()
@end

@implementation DetailViewController {
    UIAlertController *alertController;
}
#pragma mark - Managing the detail item

- (void)setDetailItem:(LibraryData*)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSLog(@"in configureview");
        self.bookTitle.borderStyle = UITextBorderStyleNone;
        [self.bookTitle setBackgroundColor:[UIColor clearColor]];
        [self.bookTitle setEnabled:NO];
        self.bookTitle.text = self.detailItem.title;
        
        self.author.borderStyle = UITextBorderStyleNone;
        [self.author setBackgroundColor:[UIColor clearColor]];
        [self.author setEnabled:NO];
        self.author.text = self.detailItem.author;
        
        self.lastCheckedOut.borderStyle = UITextBorderStyleNone;
        [self.lastCheckedOut setBackgroundColor:[UIColor clearColor]];
        [self.lastCheckedOut setEnabled:NO];
        self.lastCheckedOut.text = [self.detailItem.lastCheckedOut description];
        
        self.publisher.borderStyle = UITextBorderStyleNone;
        [self.publisher setBackgroundColor:[UIColor clearColor]];
        [self.publisher setEnabled:NO];
        self.publisher.text = self.detailItem.publisher;
        
        self.tags.borderStyle = UITextBorderStyleNone;
        [self.tags setBackgroundColor:[UIColor clearColor]];
        [self.tags setEnabled:NO];
        self.tags.text = self.detailItem.categories;
        
        self.lastCheckedOutBy.borderStyle = UITextBorderStyleNone;
        [self.lastCheckedOutBy setBackgroundColor:[UIColor clearColor]];
        [self.lastCheckedOutBy setEnabled:NO];
        self.lastCheckedOutBy.text = self.detailItem.lastCheckedOutBy;
        
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
    
    // Prepare for sending POST
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143%@",_detailItem.url]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *sendData = @"lastCheckedOutBy=";
    sendData = [sendData stringByAppendingString:[NSString stringWithFormat:@"%@", name]];
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:hh:mm:ss zzz"];
    NSString *dateWithFormat = [dateFormatter stringFromDate: currentTime];
    
    sendData = [sendData stringByAppendingString:[NSString stringWithFormat:@"&lastCheckedOut=%@",dateWithFormat]];
    [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"sending request %@",sendData);
    // Send POST
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            [self alertStatus:@"You have successfully checked out the book!" :@"Success" :1 :3];
            NSLog(@"Status Code: %li %@", (long)urlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]);
            NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
        else {            
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"CheckedOut failed" :errorMsg :1 :1];
            
            NSLog(@"An error occured, Status Code: %li, respsonse : %@", (long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            NSLog(@"Description: %@", [error localizedDescription]);
            
        }
    }];
    
    
    
    
}
- (void) deleteLibraryData {
    
    // Prepare for sending POST
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143%@",_detailItem.url]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    // Send POST
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            // Sign in success
            [self alertStatus:@"Delete succeed!" :@"Success" :1 :11];
            NSLog(@"Status Code: %li %@", (long)urlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]);
            NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
        else {
            
            // Sign in fail alert
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"Delete failed" :errorMsg :1 :1];
            
            NSLog(@"An error occured, Status Code: %li, respsonse : %@", (long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            NSLog(@"Description: %@", [error localizedDescription]);
            
        }
    }];
    
    
    
    
}

- (void) restoreBackToNonEdit {
    self.bookTitle.borderStyle = UITextBorderStyleNone;
    [self.bookTitle setEnabled:NO];
    
    self.author.borderStyle = UITextBorderStyleNone;
    [self.author setEnabled:NO];
    
    self.lastCheckedOut.borderStyle = UITextBorderStyleNone;
    [self.lastCheckedOut setEnabled:NO];
    
    self.publisher.borderStyle = UITextBorderStyleNone;
    [self.publisher setEnabled:NO];
    
    self.tags.borderStyle = UITextBorderStyleNone;
    [self.tags setEnabled:NO];
    
    self.lastCheckedOutBy.borderStyle = UITextBorderStyleNone;
    [self.lastCheckedOutBy setEnabled:NO];
    
    [self.Checkout removeTarget:nil action:NULL forControlEvents: UIControlEventTouchUpInside];
    [self.Checkout addTarget:self action:@selector(clickedOnCheckedout:) forControlEvents:UIControlEventTouchUpInside];
    [self.Checkout setTintColor:[UIColor blueColor]];
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
//                                       [self                                   performSelectorOnMainThread:[self.navigationController.navigationItem.leftBarButtonItem action] withObject:nil waitUntilDone:NO];
//                                       [self dismissViewControllerAnimated:YES completion:nil];
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
            //fire no empty title
        }
        else  {
            [updateRequest appendFormat:@"title=%@&",self.bookTitle.text];
        }
    }
    if (![self.author.text isEqualToString:self.detailItem.author]) {
        if ([self.author.text isEqualToString:@""]) {
            //fire no empty title
        }
        else {
            [updateRequest appendFormat:@"author=%@",self.author.text];
        }
    }
    if (![self.publisher.text isEqualToString:self.detailItem.publisher]) {
        [updateRequest appendFormat:@"publisher=%@",self.publisher.text];
    }
    if (![self.tags.text isEqualToString:self.detailItem.categories]) {
        [updateRequest appendFormat:@"categories=%@",self.tags.text];
    }
    if (![self.lastCheckedOut.text isEqualToString:self.detailItem.lastCheckedOut]) {
        [updateRequest appendFormat:@"lastCheckedOut=%@",self.lastCheckedOut.text];
    }
    if (![self.lastCheckedOutBy.text isEqualToString:self.detailItem.lastCheckedOutBy]) {
        [updateRequest appendFormat:@"lastCheckedOutBy=%@",self.lastCheckedOutBy.text];
    }
    if ([updateRequest isEqualToString:@""]) {
        [self restoreBackToNonEdit];
        return;
    }
    if ([updateRequest characterAtIndex:([updateRequest length] - 1)] == '&') {
        NSLog(@"last character is %c",[updateRequest characterAtIndex:([updateRequest length] - 1)]);
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
            // Sign in success
            [self alertStatus:@"You have successfully edited the information about this book!" :@"Success" :1 :12];
            NSLog(@"Status Code: %li %@", (long)urlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]);
            NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
        else {
            
            // Sign in fail alert
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"Edited failed" :errorMsg :1 :1];
            
            NSLog(@"An error occured, Status Code: %li, respsonse : %@", (long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            NSLog(@"Description: %@", [error localizedDescription]);
            
        }
    }];

}

- (IBAction)postToFacebook:(id)sender {
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[NSString stringWithFormat:@"%@, I love this book!!",_detailItem.title]];
        [self presentViewController:controller animated:YES completion:Nil];
//    }
}

- (IBAction)postToTwitter:(id)sender {
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
//    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@, I love this book!!",_detailItem.title]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
//    }
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
                                      self.bookTitle.borderStyle = UITextBorderStyleBezel;
                                      [self.bookTitle setEnabled:YES];
                                      
                                      self.author.borderStyle = UITextBorderStyleBezel;
                                      [self.author setEnabled:YES];
                                      
                                      self.lastCheckedOut.borderStyle = UITextBorderStyleBezel;
                                      [self.lastCheckedOut setEnabled:YES];
                                      
                                      self.publisher.borderStyle = UITextBorderStyleBezel;
                                      [self.publisher setEnabled:YES];
                                      
                                      self.tags.borderStyle = UITextBorderStyleBezel;
                                      [self.tags setEnabled:YES];
                                      
                                      self.lastCheckedOutBy.borderStyle = UITextBorderStyleBezel;
                                      [self.lastCheckedOutBy setEnabled:YES];
                                      
                                      [self.Checkout removeTarget:nil action:NULL forControlEvents: UIControlEventTouchUpInside];
                                      [self.Checkout addTarget:self action:@selector(clickedOnEdit:) forControlEvents:UIControlEventTouchUpInside];
                                      [self.Checkout setTintColor:[UIColor redColor]];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
