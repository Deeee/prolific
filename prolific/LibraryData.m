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
- (void)loadWithDictionary:(NSDictionary *)dict
{
    self.title = [dict objectForKey:@"title"];
    self.author = [dict objectForKey:@"author"];
    self.lastCheckedOut = [dict objectForKey:@"lastCheckedOut"];
    self.lastCheckedOutBy = [dict objectForKey:@"lastCheckedOutBy"];
    self.publisher = [dict objectForKey:@"publisher"];
    self.url = [dict objectForKey:@"url"];
    self.bookId = [[dict objectForKey:@"id"] integerValue];
    
}

-(NSString *) getTitle {
    return _title;
}
@end
