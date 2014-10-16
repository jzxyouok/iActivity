//
//  BaseTableVC.h
//  iActivity
//
//  Created by Peter on 14-10-14.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableVC : UITableViewController
{
    GlobalDataManager * dataCenter;
}
-(void)dataInit;
@end
