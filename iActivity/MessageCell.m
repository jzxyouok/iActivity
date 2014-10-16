//
//  MessageCell.m
//  iActivity
//
//  Created by Peter on 14-10-14.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)awakeFromNib {
        //self.imgView.frame=CGRectMake(8, 8, 40, 40);
    msgCountLabel.layer.cornerRadius=msgCountLabel.frame.size.width/2.0;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
