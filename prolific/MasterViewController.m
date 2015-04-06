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
#import "LibraryCell.h"
#import "LibraryAppDelegate.h"
#import "UIImage+Resize.h"

@class LibraryAppDelegate;
@interface MasterViewController ()

@property (nonatomic, strong) NSMutableArray *loadedLibraryData;
@property (nonatomic, strong) NSArray *filterResult;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIButton *actionSheet;
@property NSMutableURLRequest *originalRequest;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, assign) CGFloat screenHeight;
@end

@implementation MasterViewController {
    UIAlertController *alertController;
    BOOL flagForDeletion;
    NSIndexPath *currentIndexPath;
    UIImage *userImage;
    BOOL isBlurred;
    NSString *blurButtonTitle;
    NSString *currentImageName;
}
@synthesize originalRequest = _originalRequest;
@synthesize filterResult = _filterResult;
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
    
    isBlurred = YES;
    blurButtonTitle = @"Set Blur Off";
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    userImage = tempImageView.image;
    self.backgroundImageView = tempImageView;
    [self backGroundSet];

}

-(void) viewWillAppear:(BOOL)animated {
    [self fetchAndParseJson];
}

-(void) backGroundBlur:(UIImageView *)tempImageView {
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:[userImage CGImage]] forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@10 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    CGRect rect          = [outputImage extent];
    
    // these three lines ensure that the final image is the same size
    
    rect.origin.x        += (rect.size.width  - tempImageView.image.size.width ) / 2;
    rect.origin.y        += (rect.size.height - tempImageView.image.size.height) / 2;
    rect.size            = tempImageView.image.size;
    
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:rect];
    UIImage *image       = [UIImage imageWithCGImage:cgimg];
    tempImageView = [tempImageView initWithImage:image];
    [tempImageView setFrame:self.tableView.frame];
    [self.searchDisplayController.searchResultsTableView setBackgroundView:tempImageView];
    self.backgroundImageView = tempImageView;
    self.tableView.backgroundView = tempImageView;
}

-(void ) backGroundSet {
    //if user doesnt have image
    UIImageView *tempImageView = self.backgroundImageView;
    UIImage *image;
    if (isBlurred == YES) {
        [self backGroundBlur:tempImageView];
    }
    else {
        tempImageView.image = userImage;
        self.backgroundImageView.image = userImage;
        [self.searchDisplayController.searchResultsTableView setBackgroundView:tempImageView];
        self.backgroundImageView = tempImageView;
        self.tableView.backgroundView = tempImageView;

    }
//    UIImageView *newView = [[UIImageView alloc] initWithImage:image];
//    [self.searchDisplayController.searchResultsTableView setBackgroundView:tempImageView];
//    self.backgroundImageView = tempImageView;
//    self.tableView.backgroundView = tempImageView;

}

- (void)viewInit {
    self.title = @"Library";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewBook:)];
    self.navigationItem.leftBarButtonItem = addButton;
    
    
    self.loadedLibraryData = [[NSMutableArray alloc] init];
    

    [self fetchAndParseJson];

}

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
    // Crop the image to a square (yikes, fancy!)
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
                                   actionWithTitle:NSLocalizedString(@"Delete", @"Delete action")
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
    // Prepare for sending POST
    NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
    [mainQueue setMaxConcurrentOperationCount:5];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143/clean"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    // Send POST
    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            // Sign in success
            flagForDeletion = true;
            [self alertStatus:@"Delete all books succeed!" :@"Success" :1 :11];
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
            // Sign in success
            [self performSelectorOnMainThread:@selector(setDeleteFlagTrue) withObject:nil waitUntilDone:NO];
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
    NSLog(@"returning bool %d, ture is %d",flagForDeletion, true);
    return flagForDeletion;
    
    
}


-(void) showAlert {
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) showThisAlert:(UIAlertController *) alert {
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(title contains[c] %@) OR (categories contains[c] %@) OR (author contains[c] %@)", searchText,searchText,searchText];
    _filterResult = [self.loadedLibraryData filteredArrayUsingPredicate:resultPredicate];
    NSLog(@"in filter content loadeddata count %ld, result count %ld",(unsigned long)[self.loadedLibraryData count],(unsigned long)[_filterResult count]);

    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    

//    [self.searchDisplayController.searchResultsTableView setBackgroundView:tempImageView];
    // Send a synchronous request
    [self viewInit];
    // Do any additional setup after loading the view, typically from a nib.


    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewBook:(id)sender {
    [self performSegueWithIdentifier:@"addBookSegue" sender:self];
}

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
    NSLog(@"in fectch and parse");
    NSURL *url = [NSURL URLWithString:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143/books" ];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    _originalRequest = request;
    [request setURL:url];
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        NSString* newStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

        if ([urlResponse statusCode] >= 200 && responseData != nil) {
            NSLog(@"Status Code: %li %@", (long)urlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]);
            NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            
            if (![newStr isEqualToString:@""]) {
                [self performSelectorOnMainThread:@selector(reloadTableWithData:) withObject:responseData waitUntilDone:NO];
            }

        }
        else {
            
            NSString *errorMsg = [NSString stringWithFormat:@"An error occured, Status Code: %li, respsonse : %@",(long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
            [self alertStatus:@"Load table failed" :errorMsg :1 :1];
            
            NSLog(@"An error occured, Status Code: %li, respsonse : %@", (long)urlResponse.statusCode,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            NSLog(@"Description: %@", [error localizedDescription]);
            
        }
    }];
}
- (NSURLRequest *)connection: (NSURLConnection *)connection
             willSendRequest: (NSURLRequest *)request
            redirectResponse: (NSURLResponse *)redirectResponse;
{
    NSLog(@"here in redirect");
    if (redirectResponse) {
        // The request you initialized the connection with should be kept as
        // _originalRequest.
        // Instead of trying to merge the pieces of _originalRequest into Cocoa
        // touch's proposed redirect request, we make a mutable copy of the
        // original request, change the URL to match that of the proposed
        // request, and return it as the request to use.
        //
        NSMutableURLRequest *r = [_originalRequest mutableCopy];
        [r setURL: [request URL]];
        return r;
    } else {
        return request;
    }
}



#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
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
    }
}

//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        LibraryData *object = self.loadedLibraryData[indexPath.row];
//        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//        [controller setDetailItem:object];
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
//    }

#pragma mark - Table View

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [self.loadedLibraryData count];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filterResult count];
        
    } else {
        return [self.loadedLibraryData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LibCell"];
//    LibraryCell *cell = nil;
//    LibraryCell *cell = (LibraryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (cell == nil)
    {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
//        NSLog(@"nib count %ld",[nib count]);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LibCell"];
    }
    LibraryData *libraryData = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"preparing display filter result, count %ld",[_filterResult count]);
        libraryData = [_filterResult objectAtIndex:indexPath.row];
    } else {
        libraryData = [self.loadedLibraryData objectAtIndex:indexPath.row];
    }
    
//    [cell loadWithData:libraryData];
//    cell.bookTitle.text = @"123123";
    cell.textLabel.text = libraryData.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = libraryData.author;
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
//    NSDate *object = self.objects[indexPath.row];
//    cell.textLabel.text = [object description];
//    return cell;
    
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LibraryData *selectedData = [self.loadedLibraryData objectAtIndex:indexPath.row];
        currentIndexPath = indexPath;
        [self deleteLibraryDataAtUrl:[selectedData url]];
        //        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
