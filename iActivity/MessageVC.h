//
//  MessageVC.h
//  iActivity
//
//  Created by 伍 兵 on 14-7-23.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableVC.h"
#import "MessageCell.h"
#import "LoginVC.h"
@interface MessageVC : BaseTableVC
@property(nonatomic,retain) LoginVC* loginVC;
@end
