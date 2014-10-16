//
//  MessageVC.m
//  iActivity
//
//  Created by 伍 兵 on 14-7-23.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import "MessageVC.h"

@interface MessageVC ()
{
    NSMutableArray* hasMsgJID;
    NSMutableDictionary * msgDict;
}
@end

@implementation MessageVC
@synthesize loginVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dataInit
{
    [super dataInit];
    hasMsgJID=[[NSMutableArray alloc] init];
    msgDict=[[NSMutableDictionary alloc] init];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.tableView.layer.borderWidth=2;
    self.tableView.layer.borderColor=[UIColor blueColor].CGColor;
    
    
    //弹出登录vc
    self.loginVC= [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    
    [self presentViewController:self.loginVC animated:YES completion:^{
        
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewMsg:) name:@"newMessage" object:nil];
    //[self performSegueWithIdentifier:@"login" sender:self];
    // Do any additional setup after loading the view.
}
-(void)handleNewMsg:(NSNotification*)notificaton
{
    NSLog(@"dict:%@",[notificaton object]);
    NSDictionary* tmpDict=[[notificaton object] copy];
    NSString* fromJID=[[tmpDict objectForKey:@"fromJID"] componentsSeparatedByString:@"/"][0];
    NSString* msg=[tmpDict objectForKey:@"msg"];
    if([msg hasPrefix:@"Base64"])
        msg=@"[图片]";
     //if([[dataCenter friendsArray] containsObject:fromJID])
     {
         [msgDict setObject:msg forKey:fromJID];
         if([hasMsgJID containsObject:fromJID])
         {
             
         }
         else
         {
             [hasMsgJID addObject:fromJID];
         }
     }
    
    [self.tableView reloadData];
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return hasMsgJID.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell* cell=[tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    cell.label.text= msgDict[hasMsgJID[indexPath.row]];
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
