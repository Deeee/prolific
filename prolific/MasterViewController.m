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
@interface MasterViewController ()
@property (nonatomic, strong) NSMutableArray *loadedLibraryData;

@property NSMutableArray *objects;

@end

@implementation MasterViewController
@synthesize originalRequest = _originalRequest;
- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewInit {
    self.title = @"Book";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewBook:)];
    self.navigationItem.leftBarButtonItem = addButton;
    self.loadedLibraryData = [[NSMutableArray alloc] init];
    [self fetchAndParseJson];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Send a synchronous request
//    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
//    NSHTTPURLResponse *response = nil;
//    NSError * error = nil;
//    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
//                                          returningResponse:&response
//                                                      error:&error];
//    NSLog(@"Response code: %ld", (long)[response statusCode]);
//    
//    if (error == nil)
//    {
//        // Parse data here
//    }
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
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
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
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [self.loadedLibraryData count];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loadedLibraryData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LibraryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    static NSString *cellIdentifier = @"LibraryCell";
//    LibraryCell *cell = nil;
    
//    if (cell == nil)
//    {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
//        cell = (LibraryCell *)[nib objectAtIndex:0];
//    }
    
    LibraryData *libraryData = [self.loadedLibraryData objectAtIndex:[indexPath row]];
    
    [cell loadWithData:libraryData];
    
    cell.textLabel.text = libraryData.title;
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
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
