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
@class LibraryAppDelegate;
@interface MasterViewController ()

@property (nonatomic, strong) NSMutableArray *loadedLibraryData;
@property (nonatomic, strong) NSArray *filterResult;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIButton *actionSheet;
@property NSMutableURLRequest *originalRequest;
@end

@implementation MasterViewController {
    UIAlertController *alertController;
    BOOL flagForDeletion;
    NSIndexPath *currentIndexPath;
}
@synthesize originalRequest = _originalRequest;
@synthesize filterResult = _filterResult;
- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [self fetchAndParseJson];
}

- (void)viewInit {
    self.title = @"Book";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewBook:)];
    self.navigationItem.leftBarButtonItem = addButton;
    self.loadedLibraryData = [[NSMutableArray alloc] init];
    [self fetchAndParseJson];

}

- (IBAction)clickOnActionSheet:(id)sender {
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
    UIAlertAction *refreshAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Refresh", @"Refresh action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"refreshing the table!!!");
                                        [self fetchAndParseJson];
                                    }];
    [alertController addAction:refreshAction];
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

- (void) setDeleteFlagTrue {
    NSLog(@"in setdeleteflag true");
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
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
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

//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) fetchAndParseJson {
    NSLog(@"in fectch and parse");
    NSError *error = nil;
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
//    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    NSURL *url = [NSURL URLWithString:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143/books" ];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    _originalRequest = request;
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response = nil;

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    

    NSString* newStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"after return data %@....",newStr);
    if ([newStr isEqualToString:@""]) {
        return;
    }
    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:returnData
                                                          options:0 error:&error];
    NSLog(@"json object array count %lu",(unsigned long)[jsonObject count]);
// TODO: ADD error test
    [self.loadedLibraryData removeAllObjects];
    for (NSDictionary *bookDict in jsonObject) {
        LibraryData *libraryData = [[LibraryData alloc] init];
        [libraryData loadWithDictionary:bookDict];
        [self.loadedLibraryData addObject:libraryData];
        NSLog(@"loading %@",[libraryData title]);

    }
    [self.tableView reloadData];
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
        libraryData = [_filterResult objectAtIndex:indexPath.row];
    } else {
        libraryData = [self.loadedLibraryData objectAtIndex:indexPath.row];
    }
    
//    [cell loadWithData:libraryData];
//    cell.bookTitle.text = @"123123";
    cell.textLabel.text = libraryData.title;
    cell.detailTextLabel.text = libraryData.author;
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
