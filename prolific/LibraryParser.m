//
//  LibraryParser.m
//  prolific
//
//  Created by Liu Di on 4/2/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import "LibraryParser.h"
#import "LibraryData.h"
@implementation LibraryParser
@synthesize libraryItems = _libraryItems;
@synthesize currentItem = _currentItem;
@synthesize currentItemValue = _currentItemValue;
@synthesize delegate = _delegate;
@synthesize retrieverQueue = _retrieverQueue;

- (id) init {
    if (![super init]) {
        return nil;
    }
    _libraryItems = [[NSMutableArray alloc] init];
    return self;
}

- (NSOperationQueue *)retrieverQueue {
    if (nil == _retrieverQueue) {
        _retrieverQueue = [[NSOperationQueue alloc] init];
        _retrieverQueue.maxConcurrentOperationCount = 1;
    }
    return _retrieverQueue;
}

- (void) startProcess {
    SEL method = @selector(fetchAndParseJson);
    [[self libraryItems] removeAllObjects];
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:method object:nil];
    [self.retrieverQueue addOperation:op];
}

-(BOOL) fetchAndParseJson {
    NSError *error = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    NSURL *url = [NSURL URLWithString:@"http://prolific-interview.herokuapp.com/5515bb0b2a638f0009b47143/books" ];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    id JSONData = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingAllowFragments error:&error];
    return YES;
    
    
}
@end
