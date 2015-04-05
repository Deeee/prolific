//
//  AddBookViewController.m
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import "AddBookViewController.h"

@interface AddBookViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *toolbar;
@property (weak, nonatomic) IBOutlet UINavigationItem *toolbarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *bookTitle;
@property (weak, nonatomic) IBOutlet UITextField *author;
@property (weak, nonatomic) IBOutlet UITextField *publisher;
@property (weak, nonatomic) IBOutlet UITextField *categories;

@property (weak, nonatomic) IBOutlet UIButton *submit;


@end

@implementation AddBookViewController {
    UIAlertController *alertController;
}
@synthesize toolbar;
@synthesize author;
@synthesize publisher;
@synthesize categories;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.toolbarItem.title = @"Add Book";
    self.author.placeholder = @"Author";
    self.bookTitle.placeholder = @"Book Title";
    self.publisher.placeholder =@"Publisher";
    self.categories.placeholder = @"Categories";
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickOnDone:)];
//
//    toolbar.topItem.rightBarButtonItem = self.doneButton;
    // Do view setup here.
    self.toolbarItem.rightBarButtonItem = self.doneButton;
}
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

-(IBAction)clickOnDone:(id) sender {
    if((![[self.bookTitle text] isEqualToString:@""]) || (![[self.author text] isEqualToString:@""] )|| (![[self.publisher text] isEqualToString:@""]) || (![[self.categories text] isEqualToString:@""])) {
        [self alertStatus:@"Leaving the screen with unsaved changes?" :@"Confirm your action" :0:2];
    }
    else {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }

}

-(IBAction)clickOnSubmit:(id)sender {
    if([[self.bookTitle text] isEqualToString:@""] || [[self.author text] isEqualToString:@""] ) {
        [self alertStatus:@"Please make sure book title and author are filled" :@"Submit Failed!" :0:1];
    }
    else {
        // Prepare for sending POST
        NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
        [mainQueue setMaxConcurrentOperationCount:5];
        NSURL *url = [NSURL URLWithString:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143/books/"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        NSString *sendData = @"title=";
        sendData = [sendData stringByAppendingString:[NSString stringWithFormat:@"%@", [self.bookTitle text]]];
        
        sendData = [sendData stringByAppendingString:@"&author="];
        sendData = [sendData stringByAppendingString:[NSString stringWithFormat:@"%@", [self.author text]]];
        sendData = [sendData stringByAppendingString:[NSString stringWithFormat:@"&categories=%@",[self.categories text]]];
        sendData = [sendData stringByAppendingString:[NSString stringWithFormat:@"&publisher=%@",[self.publisher text]]];
        [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        // Send POST
        [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {

            
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            
            if ([urlResponse statusCode] >= 200 && responseData != nil) {
                // Sign in success
                [self alertStatus:@"Submit succeed" :@"Sucess" :1 :3];
                NSLog(@"Status Code: %li %@", (long)urlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]);
                NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            }
            else {
                
                // Sign in fail alert
                [self alertStatus:@"Submit failed" :@"Failed" :1 :1];
                
                NSLog(@"An error occured, Status Code: %li, respsonse : %@", (long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                NSLog(@"Description: %@", [error localizedDescription]);
                
            }
        }];
        
        
        
    }
}
- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}
-(void) showAlert {
    [self presentViewController:alertController animated:YES completion:nil];
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
    else {
        alertController = [UIAlertController
                           alertControllerWithTitle:@"Success"
                           message:@"Submit succeed"
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

}
- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
