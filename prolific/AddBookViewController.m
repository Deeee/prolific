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
@property (weak, nonatomic) IBOutlet UITextField *booktitle;
@property (weak, nonatomic) IBOutlet UITextField *author;
@property (weak, nonatomic) IBOutlet UITextField *publisher;
@property (weak, nonatomic) IBOutlet UITextField *categories;
@property (weak, nonatomic) IBOutlet UIButton *submit;


@end

@implementation AddBookViewController
@synthesize toolbar;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.toolbarItem.title = @"hhh";
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
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];

}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}
@end
