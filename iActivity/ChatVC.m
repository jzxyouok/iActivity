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
-(void)addBtnClicked:(UIButton *)aBtn
{
    UIImagePickerController* picker=[[UIImagePickerController alloc] init];
    picker.delegate=self;
    picker.sourceType= UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        NSLog(@"presented");
    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed");
    }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    //base64编码
    NSString* imageString=[UIImageJPEGRepresentation(image, 0.2) base64EncodedString];
    NSString* encodeString=[@"Base64" stringByAppendingString:imageString];
    NSLog(@"encodeImageString:%@",encodeString);
    //发送
    [APP sendMsg:encodeString];
    //
    [self sendMsgDict:@{@"msg":encodeString,@"fromJID":@"",@"type":@"send"}];
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed");
        //[self updateHeadImage:image];
    }];
}
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
    NSString* msg=[msgDict objectForKey:@"msg"];
    if([msg hasPrefix:@"Base64"])
    {
        NSData* imageData=[[msg substringFromIndex:6] base64DecodedData];
        UIImage * image=[UIImage imageWithData:imageData];
        return [self rectForImageSize:image.size isRight:YES].size.height+8;
    }
    CGSize size=[self sizeOfMsg:msg];
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
    //图片和语音
    if([msg hasPrefix:@"Base64"])
    {
        NSData* imageData=[[msg substringFromIndex:6] base64DecodedData];
        UIImage * image=[UIImage imageWithData:imageData];
        if([[msgDict objectForKey:@"type"] isEqualToString:@"send"])
        {
            cell.leftHead.hidden=YES;
            cell.contentBack.frame= [self rectForImageSize:image.size isRight:YES];
        }
        else
        {
            cell.rightHead.hidden=YES;
            cell.contentBack.frame= [self rectForImageSize:image.size isRight:NO];

        }
        cell.contentBack.image=image;
        return cell;
    }
    
    
    
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
-(CGRect)rectForImageSize:(CGSize)imgSize isRight:(BOOL)isRight
{
    CGRect rect;
    CGSize needSize;
    if(imgSize.width>imgSize.height)
    {
        needSize=CGSizeMake(160, 160.0/imgSize.width*imgSize.height);
    }
    else
    {
        needSize=CGSizeMake(160/imgSize.height*imgSize.width, 160);
    }
    if(isRight)
        rect=CGRectMake(320-needSize.width-50, 4, needSize.width, needSize.height);
    else
        rect=CGRectMake(50, 4, needSize.width, needSize.height);
    return rect;
        
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
