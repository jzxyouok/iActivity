//
//  ChatVC.h
//  iActivity
//
//  Created by 伍 兵 on 14-7-27.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgTableView.h"
#import "ChatViewCell.h"
#import "InputToolBar.h"
@interface ChatVC : UIViewController<XMPPMsgDelegate,UITableViewDataSource,UITableViewDelegate,InputToolBarDelegate>
{
    IBOutlet MsgTableView* tableView;
    IBOutlet InputToolBar* inputToolBar;
}
@end
