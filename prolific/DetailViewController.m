//
//  DetailViewController.m
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import "DetailViewController.h"
#import "LibraryAppDelegate.h"
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
        self.bookTitle.text = self.detailItem.title;
        self.lastCheckedOut.text = [self.detailItem.lastCheckedOut description];
        self.publisher.text = self.detailItem.publisher;
        self.author.text = self.detailItem.author;
        self.tags.text = self.detailItem.categories;
        
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
        //cancel clicked ...do your action
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
    NSLog(@"sending request %@",sendData);
    // Send POST
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            // Sign in success
            [self alertStatus:nil :nil :1 :3];
            NSLog(@"Status Code: %li %@", (long)urlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]);
            NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
        else {
            
            // Sign in fail alert
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
                           alertControllerWithTitle:@"Success"
                           message:@"Checkedout succeed"
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

-(IBAction)clickedOnActionSheet:(id)sender {
    alertController = [UIAlertController
                       alertControllerWithTitle:@"Actions"
                       message:@"Choose your action"
                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *shareAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Share", @"Share action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"poping back!");
                               }];
    [alertController addAction:shareAction];
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
