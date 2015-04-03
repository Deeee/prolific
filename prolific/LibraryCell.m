//
//  LibraryCell.m
//  prolific
//
//  Created by Liu Di on 4/2/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import "LibraryCell.h"
@implementation LibraryCell
@synthesize bookAuthor;
@synthesize bookTitle;
- (void)loadWithData:(LibraryData *)libraryData
{
    self.bookTitle.text = libraryData.title;
    self.bookAuthor.text = libraryData.author;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    //read
    if(self = [super init]){
        bookTitle=[aDecoder decodeObjectForKey:@"bookTitle"];
        bookAuthor=[aDecoder decodeObjectForKey:@"bookAuthor"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    //save
    [encoder encodeObject:bookTitle forKey:@"bookTitle"];
    [encoder encodeObject:bookAuthor forKey:@"bookAuthor"];
}
@end
