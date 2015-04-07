//
//  MasterViewController.m
//  prolific
//
//  Created by Liu Di on 4/1/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AddBookViewController.h"
#import "LibraryData.h"
#import "LibraryAppDelegate.h"
#import "UIImage+Resize.h"
#define FONT_M_B(s) [UIFont fontWithName:@"Machinato-Bold" size:s]
#define FONT_M(s) [UIFont fontWithName:@"Machinato" size:s]
#define FONT_M_EL(s) [UIFont fontWithName:@"Machinato-ExtraLight" size:s]



@interface MasterViewController ()
@end

@implementation MasterViewController {
    UIAlertController *alertController;
    BOOL flagForDeletion;
    NSIndexPath *currentIndexPath;
    UIImage *userImage;
    BOOL isBlurred;
    NSString *blurButtonTitle;
    NSString *currentImageName;
    UIColor *userChooseColor;
}
@synthesize originalRequest = _originalRequest;
@synthesize filterResult = _filterResult;
@synthesize delegate = _delegate;


- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.alpha = .3;
    [[UISearchBar appearance] setAlpha:0.5];
    [[UISearchBar appearance] setBackgroundColor:[UIColor blackColor]];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    isBlurred = YES;
    blurButtonTitle = @"Set Blur Off";
    userImage = tempImageView.image;
    userChooseColor = [UIColor whiteColor];
    _delegate = [UIApplication sharedApplication].delegate;

    self.backgroundImageView = tempImageView;
    [self backGroundSet];
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor grayColor]];
    self.actionSheet.titleLabel.font = FONT_M_EL(15);


}

-(void) viewWillAppear:(BOOL)animated {
    [self fetchAndParseJson];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetTtile];
    [self viewInit];
    [self fetchAndParseJson];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewInit {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewBook:)];
    self.navigationItem.leftBarButtonItem = addButton;
    self.loadedLibraryData = [[NSMutableArray alloc] init];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

}

-(void) resetTtile {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = FONT_M_B(22);
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = userChooseColor;
    label.text = NSLocalizedString(@"Library", @"");
    [label sizeToFit];
    
    self.navigationItem.titleView = label;
}

-(void) backGroundBlur:(UIImageView *)tempImageView {
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:[userImage CGImage]] forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@10 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    CGRect rect          = [outputImage extent];
    
    rect.origin.x        += (rect.size.width  - tempImageView.image.size.width ) / 2;
    rect.origin.y        += (rect.size.height - tempImageView.image.size.height) / 2;
    rect.size            = tempImageView.image.size;
    
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:rect];
    UIImage *image       = [UIImage imageWithCGImage:cgimg];
    tempImageView = [tempImageView initWithImage:image];
    [tempImageView setFrame:self.tableView.frame];
    self.backgroundImageView = tempImageView;
    self.tableView.backgroundView = tempImageView;
}

-(void ) backGroundSet {
    UIImageView *tempImageView = self.backgroundImageView;
    if (isBlurred == YES) {
        [self backGroundBlur:tempImageView];
    }
    else {
        tempImageView.image = userImage;
        self.backgroundImageView.image = userImage;
        self.backgroundImageView = tempImageView;
        self.tableView.backgroundView = tempImageView;
        
    }
    _delegate.appBackground = userImage;
    
}

-(UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}
#pragma mark - ActionSheet setup
- (IBAction)clickOnActionSheet:(id)sender {
    alertController = [UIAlertController
                       alertControllerWithTitle:@"Actions"
                       message:@"Choose your action"
                       preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *refreshAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Refresh", @"Refresh action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        [self fetchAndParseJson];
                                    }];
    [alertController addAction:refreshAction];
    

    
    UIAlertAction *luckyAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"I am feeling lucky!", @"lucky action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        
                                        userChooseColor = [self randomColor];
                                        
                                        [self.tableView reloadData];
                                        
                                        LibraryAppDelegate *delegate = [UIApplication sharedApplication].delegate;
                                        [delegate.window setTintColor:userChooseColor];
                                        [self resetTtile];
                                        
                                    }];
    [alertController addAction:luckyAction];
    UIAlertAction *changeBackGroundAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Change Background", @"Change Background action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"refreshing the table!!!");
                                        [self takePhoto];
                                    }];
    [alertController addAction:changeBackGroundAction];
    UIAlertAction *blurredAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(blurButtonTitle, @"Blur action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        if (isBlurred == YES) {
                                            isBlurred = NO;
                                            blurButtonTitle = @"Set Blur On";
                                        }
                                        else {
                                            isBlurred = YES;
                                            blurButtonTitle = @"Set Blur Off";
                                        }
                                        [self backGroundSet];
                                        
                                    }];
    [alertController addAction:blurredAction];
    UIAlertAction *deleteAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Delete All Books", @"Delete action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       UIAlertController *temp = [UIAlertController
                                                                  alertControllerWithTitle:@"Confirm on delete"
                                                                  message:@"Are you sure you want to clean all the books?"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *confirmAction = [UIAlertAction
                                                                       actionWithTitle:NSLocalizedString(@"Confirm", @"Confirm action")
                                                                       style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction *action)
                                                                       {
                                                                           [self deleteAllLibraryData];
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

- (void) deleteAllLibraryData {
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143/clean"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            flagForDeletion = true;
            [self alertStatus:@"Delete all books succeed!" :@"Success" :1 :11];
        }
        else {
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"Delete failed" :errorMsg :1 :1];
            
        }
    }];

}


- (void)insertNewBook:(id)sender {
    _delegate.appBackground = [userImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(self.backgroundImageView.frame.size.width, self.backgroundImageView.frame.size.height) interpolationQuality:kCGInterpolationHigh];
    _delegate.userChooseColor = userChooseColor;
    [self performSegueWithIdentifier:@"addBookSegue" sender:self];
}

- (void) setDeleteFlagTrue {
    flagForDeletion = true;
    [self.loadedLibraryData removeObjectAtIndex:currentIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (BOOL) deleteLibraryDataAtUrl:(NSString *)urlString {
    
    // Prepare for sending POST
    flagForDeletion = false;
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143%@",urlString]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    // Send POST
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            [self performSelectorOnMainThread:@selector(setDeleteFlagTrue) withObject:nil waitUntilDone:NO];
            [self alertStatus:@"Delete succeed!" :@"Success" :1 :11];
        }
        else {
            
            // Sign in fail alert
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"Delete failed" :errorMsg :1 :1];
            
        }
    }];
    return flagForDeletion;
    
    
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag :(int)mode
{
    if (mode == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        alertView.tag = tag;
        [alertView show];
    }
    else if (mode == 2){
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
                                       [self fetchAndParseJson];
                                       [self.tableView reloadData];
                                       
                                   }];
        [alertController addAction:okAction];
        [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
    }
    else {
        alertController = [UIAlertController
                           alertControllerWithTitle:@"Success"
                           message:@"Checkedout succeed"
                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        [alertController addAction:okAction];
        [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
        
    }
    
}


-(void) showAlert {
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) showThisAlert:(UIAlertController *) alert {
    [self presentViewController:alert animated:YES completion:nil];
    
}


#pragma mark - Search Bar Delegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(title contains[c] %@) OR (categories contains[c] %@) OR (author contains[c] %@)", searchText,searchText,searchText];
    _filterResult = [self.loadedLibraryData filteredArrayUsingPredicate:resultPredicate];
    
}




#pragma mark - Load Data into Table


- (void)reloadTableWithData:(NSData *)responseData {
    NSError *error = nil;
    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    [self.loadedLibraryData removeAllObjects];
    for (NSDictionary *bookDict in jsonObject) {
        LibraryData *libraryData = [[LibraryData alloc] init];
        [libraryData loadWithDictionary:bookDict];
        [self.loadedLibraryData addObject:libraryData];
    }
    [self.tableView reloadData];
}

-(void) fetchAndParseJson {
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143/books" ];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    _originalRequest = request;
    [request setURL:url];
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        NSString* newStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            if (![newStr isEqualToString:@""]) {
                [self performSelectorOnMainThread:@selector(reloadTableWithData:) withObject:responseData waitUntilDone:NO];
            }

        }
        else {
            
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"Load table failed" :errorMsg :1 :1];
        }
    }];
}

- (NSURLRequest *)connection: (NSURLConnection *)connection
             willSendRequest: (NSURLRequest *)request
            redirectResponse: (NSURLResponse *)redirectResponse;
{
    if (redirectResponse) {

        NSMutableURLRequest *r = [_originalRequest mutableCopy];
        [r setURL: [request URL]];
        return r;
    } else {
        return request;
    }
}


#pragma mark - Take phote API
-(void)takePhoto {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    
    [self presentModalViewController:imagePickerController animated:YES];
}

#pragma mark - Image picker delegate methdos
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // Resize the image from the camera
    UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(self.backgroundImageView.frame.size.width, self.backgroundImageView.frame.size.height) interpolationQuality:kCGInterpolationHigh];
    // Crop the image to a square
    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -self.backgroundImageView.frame.size.width)/2, (scaledImage.size.height -self.backgroundImageView.frame.size.height)/2, self.backgroundImageView.frame.size.width, self.backgroundImageView.frame.size.height)];
    // Show the photo on the screen
    self.backgroundImageView.image = croppedImage;
    userImage = croppedImage;
    if (isBlurred == YES) {
        [self backGroundBlur:self.backgroundImageView];
    }
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}



#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        _delegate.userChooseColor = userChooseColor;
        NSIndexPath *indexPath = nil;
        LibraryData *libraryData = nil;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            libraryData = [_filterResult objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            libraryData = [_loadedLibraryData objectAtIndex:indexPath.row];
        }
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:libraryData];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
        [controller setBackgroundImageView:[[UIImageView alloc] initWithImage:[userImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(self.backgroundImageView.frame.size.width, self.backgroundImageView.frame.size.height) interpolationQuality:kCGInterpolationHigh]]];
        [controller.view addSubview:controller.backgroundImageView];
        [controller.view sendSubviewToBack:controller.backgroundImageView];

    }
}
#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filterResult count];
        
    } else {
        return [self.loadedLibraryData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LibCell"];

    if (cell == nil)
    {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LibCell"];
    }
    LibraryData *libraryData = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        libraryData = [_filterResult objectAtIndex:indexPath.row];
    } else {
        libraryData = [self.loadedLibraryData objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = libraryData.title;
    cell.textLabel.textColor = userChooseColor;
    cell.textLabel.font = FONT_M(18);
    cell.detailTextLabel.text = libraryData.author;
    cell.detailTextLabel.textColor = userChooseColor;
    cell.detailTextLabel.font = FONT_M(14);
    cell.backgroundColor = [UIColor clearColor];
    return cell;

    
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LibraryData *selectedData = [self.loadedLibraryData objectAtIndex:indexPath.row];
        currentIndexPath = indexPath;
        [self deleteLibraryDataAtUrl:[selectedData url]];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


@end
