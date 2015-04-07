//
//  LibraryBook.m
//  prolific
//
//  Created by Liu Di on 4/2/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import "LibraryData.h"

@implementation LibraryData
@synthesize title = _title;
@synthesize author = _author;
@synthesize lastCheckedOut = _lastCheckedOut;
@synthesize lastCheckedOutBy = _lastCheckedOutBy;
@synthesize publisher = _publisher;
@synthesize url = _url;
@synthesize bookId = _bookId;
@synthesize categories = _categories;
- (void)loadWithDictionary:(NSDictionary *)dict
{
    self.title = [[dict objectForKey:@"title"] description];
    self.author = [[dict objectForKey:@"author"] description];
    self.lastCheckedOut = [[dict objectForKey:@"lastCheckedOut"] description];
    self.lastCheckedOutBy = [[dict objectForKey:@"lastCheckedOutBy"] description];
    self.publisher = [[dict objectForKey:@"publisher"] description];
    self.url = [[dict objectForKey:@"url"] description];
    self.bookId = [[dict objectForKey:@"id"] integerValue];
    self.categories = [[dict objectForKey:@"categories"] description];
    
}

@end
