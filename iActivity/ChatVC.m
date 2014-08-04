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
    //[tableView registerClass:[ChatViewCell class] forCellReuseIdentifier:@"chatCellID"];
    
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
    [self performSelector:@selector(scrollToLastMsg) withObject:nil afterDelay:0.3];
}
-(void)scrollToLastMsg
{
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:msgArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
-(void)sendMsgDict:(NSDictionary *)aMsgDict
{
    
    [msgArray addObject:aMsgDict];
    NSLog(@"count:%d",msgArray.count);
    [tableView reloadData];
     [self performSelector:@selector(scrollToLastMsg) withObject:nil afterDelay:0.3];
    
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* msgDict=[msgArray objectAtIndex:indexPath.row];
    CGSize size=[self sizeOfMsg:[msgDict objectForKey:@"msg"]];
    return MAX(CELL_MIN_HEIGHT, size.height)+8;
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
    NSString* msg=[msgDict objectForKey:@"msg"];
    CGSize size=[self sizeOfMsg:msg];
    size=CGSizeMake(size.width, MAX(CELL_MIN_HEIGHT, size.height));
    cell.contentLabel.text=msg;
    cell.leftHead.hidden=NO;
    cell.rightHead.hidden=NO;
    CGFloat cellHeight=[tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    if([[msgDict objectForKey:@"type"] isEqualToString:@"send"])
    {
        CGRect textRect=CGRectMake(320-50-size.width, (cellHeight-size.height)/2.0, size.width, size.height);
        cell.leftHead.hidden=YES;
        cell.contentLabel.frame=textRect;
        cell.contentBack.frame=CGRectMake(textRect.origin.x-10, textRect.origin.y-2, textRect.size.width+25, textRect.size.height+4);
        cell.contentBack.image=[[UIImage imageNamed:@"bubbleRight.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    }
    else
    {
        CGRect textRect=CGRectMake(50, (cellHeight-size.height)/2.0, size.width, size.height);
        cell.rightHead.hidden=YES;
        cell.contentLabel.frame=textRect;
        cell.contentBack.frame=CGRectMake(textRect.origin.x-15, textRect.origin.y-2, textRect.size.width+25, textRect.size.height+4);
        cell.contentBack.image=[[UIImage imageNamed:@"bubbleLeft.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
    
#endif
    return cell;
}

-(CGSize)sizeOfMsg:(NSString*)aMsg
{
    NSDictionary* attriDict=@{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    CGRect rect= [aMsg boundingRectWithSize:CGSizeMake(160, 480) options:NSStringDrawingUsesLineFragmentOrigin attributes:attriDict context:nil];
    //NSLog(@"rect:%@",NSStringFromCGRect(rect));
    return rect.size;
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
