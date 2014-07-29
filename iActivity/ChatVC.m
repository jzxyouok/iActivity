//
//  ChatVC.m
//  iActivity
//
//  Created by 伍 兵 on 14-7-27.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import "ChatVC.h"

@interface ChatVC ()
{
    NSMutableArray* msgArray;
}
@end

@implementation ChatVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableView.layer.borderColor=[UIColor redColor].CGColor;
    tableView.layer.borderWidth=2;
    
   NSString* currentJID= [[GlobalDataManager sharedDataManager] currentChatJID];
    self.title=[NSString stringWithFormat:@"与%@聊天",currentJID];
    
    
    msgArray =[[NSMutableArray alloc] initWithCapacity:0];
    [APP setMsgDelegate:self];
    
    
    //键盘出现通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘更改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    //键盘消失通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //侦听消失键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:HIDE_KEYBOARD_NOTIFICATION object:nil];
    // Do any additional setup after loading the view.
}
-(void)keybardWillShow:(NSNotification*)notify
{
     CGRect rect= [[[notify userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"rect:%@",NSStringFromCGRect(rect));
    CGPoint point1=inputToolBar.center;
    [UIView animateWithDuration:0.25 animations:^{
        inputToolBar.center=CGPointMake(point1.x, point1.y-rect.size.height);
        tableView.center=CGPointMake(inputToolBar.center.x, inputToolBar.center.y-inputToolBar.bounds.size.height/2-tableView.bounds.size.height/2);
    }];
    
}
-(void)keybardDidShow:(NSNotification*)notify
{
    
}
-(void)keybardWillHide:(NSNotification*)notify
{
    //CGRect rect= [[[notify userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGPoint point1=inputToolBar.center;
    [UIView animateWithDuration:0.25 animations:^{
    inputToolBar.center=CGPointMake(point1.x, self.view.bounds.size.height-inputToolBar.bounds.size.height/2);
         tableView.center=CGPointMake(inputToolBar.center.x, inputToolBar.center.y-inputToolBar.bounds.size.height/2-tableView.bounds.size.height/2);
    }];
}
#pragma mark - msgDelegate
-(void)receivedMsgDict:(NSDictionary *)aDict
{
    [msgArray addObject:aDict];
    [tableView reloadData];
}
-(void)sendMsgDict:(NSDictionary *)aMsgDict
{
    
    [msgArray addObject:aMsgDict];
    NSLog(@"count:%d",msgArray.count);
    [tableView reloadData];
}
#pragma mark - tableView delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return msgArray.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSDictionary* msgDict=[msgArray objectAtIndex:indexPath.row];
#if 0
    UITableViewCell* cell=[aTableView dequeueReusableCellWithIdentifier:@"ID"];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc ] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ID"];
    }
   
    cell.textLabel.text=[msgDict objectForKey:@"msg"];
#else
    ChatViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"chatCellID"];
    cell.contentLabel.text= [msgDict objectForKey:@"msg"];
    cell.leftHead.hidden=NO;
    cell.rightHead.hidden=NO;
    if([[msgDict objectForKey:@"type"] isEqualToString:@"send"])
    {
        cell.leftHead.hidden=YES;
    }
    else
    {
        cell.rightHead.hidden=YES;
    }
#endif
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)hideKeyboard:(NSNotification*)notify
{
    [inputToolBar myResignFirstResponse];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
