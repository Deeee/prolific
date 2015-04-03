//
//  LibraryParser.h
//  prolific
//
//  Created by Liu Di on 4/2/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@class LibraryBook;

@protocol LibraryParserDelegate;

@interface LibraryParser : NSObject {
    LibraryBook *_currentItem;
    NSMutableString *_currentItemValue;
    NSMutableArray *_libraryItems;
    id<LibraryParserDelegate> _delegate;
    NSOperationQueue *_retrieverQueue;
}
@property(nonatomic, retain) LibraryBook *currentItem;
@property(nonatomic, retain) NSMutableString *currentItemValue;
@property(readonly) NSMutableArray *libraryItems;
@property(nonatomic, retain) NSOperationQueue *retrieverQueue;
@property id<LibraryParserDelegate> delegate;

- (void) startProcess;

@end

@protocol LibraryParserDelegate <NSObject>

-(void) processCompleted;
-(void) processHasErrors;

@end