//
//  TableViewImageCell.h
//  OptimizeUITableView
//
//  Created by Doan Cuong on 9/8/14.
//  Copyright (c) 2014 Doan Cuong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface TableViewImageCell : UITableViewCell
@property (strong, atomic) NSMutableString *imagePath;
-(id)initWithStyleAndFilePath:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
                     filePath:(NSString *)imagePath;
@end
