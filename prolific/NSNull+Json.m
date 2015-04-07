//
//  NSNull+Json.m
//  prolific
//
//  Created by Liu Di on 4/4/15.
//
//  This category is for extend NSNull so when Json
//  parses null, return value will not be set to NSNull,
//  it saves a lot of checkings in the code
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import "NSNull+Json.h"

@interface NSNull (JSON)
@end

@implementation NSNull (JSON)

- (NSUInteger)length { return 0; }

- (NSInteger)integerValue { return 0; };

- (float)floatValue { return 0; };

- (NSString *)description { return @"0(NSNull)"; }

- (NSArray *)componentsSeparatedByString:(NSString *)separator { return @[]; }

- (id)objectForKey:(id)key { return nil; }

- (BOOL)boolValue { return NO; }

@end
