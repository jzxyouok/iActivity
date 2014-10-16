//
//  BaseCell.m
//  iActivity
//
//  Created by Peter on 14-10-14.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import "BaseCell.h"

@implementation BaseCell
@synthesize imgView;
@synthesize label;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
