//
//  ChatViewCell.h
//  iActivity
//
//  Created by 伍 兵 on 14-7-28.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewCell : UITableViewCell
{
    IBOutlet UIImageView * leftHead;
    IBOutlet UIImageView * rightHead;
    IBOutlet UIImageView * contentBack;
    IBOutlet UILabel * contentLabel;
}
@property(nonatomic,strong)IBOutlet UIImageView* leftHead;
@property(nonatomic,strong)IBOutlet UIImageView* rightHead;
@property(nonatomic,strong)IBOutlet UIImageView* contentBack;
@property(nonatomic,strong)IBOutlet UILabel* contentLabel;

@end
