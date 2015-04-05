//
//  LibraryCell.h
//  prolific
//
//  Created by Liu Di on 4/2/15.
//  Copyright (c) 2015 Liu Di. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LibraryData.h"

@interface LibraryCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *bookTitle;
@property (nonatomic, strong) IBOutlet UILabel *bookAuthor;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
- (void)loadWithData:(LibraryData *)bookData;
@end
