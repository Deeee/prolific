//
//  LibraryBook.h
//  prolific
//
//  Created by Liu Di on 4/2/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryData : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *author;
@property(nonatomic, copy) NSString *categories;
@property(nonatomic, copy) NSString *lastCheckedOut;
@property(nonatomic, copy) NSString *lastCheckedOutBy;
@property(nonatomic, copy) NSString *publisher;
@property(nonatomic, copy) NSString *url;
@property NSInteger bookId;
- (void)loadWithDictionary:(NSDictionary *)dict;
@end
