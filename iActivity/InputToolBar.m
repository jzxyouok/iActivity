//
//  InputToolBar.m
//  iActivity
//
//  Created by 伍 兵 on 14-7-28.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import "InputToolBar.h"

@implementation InputToolBar
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)myResignFirstResponse
{
    [textField resignFirstResponder];
}
-(IBAction)sendBtnClicked:(id)sender
{
    [APP  sendMsg:textField.text];
    
    if([delegate  respondsToSelector:@selector(sendMsgDict:)])
        [delegate sendMsgDict:@{@"msg":textField.text,@"fromJID":@"",@"type":@"send"}];
    textField.text=@"";
    [textField resignFirstResponder];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
