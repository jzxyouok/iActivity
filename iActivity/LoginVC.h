//
//  LoginVC.h
//  iActivity
//
//  Created by 伍 兵 on 14-7-23.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVC : UIViewController
{
    IBOutlet UITextField * nameField;
    IBOutlet UITextField * passwordField;
    
    IBOutlet UILabel* alertLabel;
}

-(void)textAlert:(NSString*)msg;
@end
