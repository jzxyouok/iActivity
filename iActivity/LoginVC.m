//
//  LoginVC.m
//  iActivity
//
//  Created by 伍 兵 on 14-7-23.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@end

@implementation LoginVC

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
    
    
//    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(32, 213, 280, 30)];
//    label.backgroundColor=[UIColor yellowColor];
//    [self.view addSubview:label];
//    self.alertLabel=label;
    
    // Do any additional setup after loading the view.
}
-(IBAction)btnClicked:(UIButton*)sender
{
    
    if(nameField.text.length<1)
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"info" message:@"用户名不能为空!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        //[alert release];
        return;
    }
    if(passwordField.text.length<1)
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"info" message:@"密码不能为空!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    [APP setUserJID:nameField.text];
    [APP  setPassword:passwordField.text];
    if(sender.tag==1)
    {
        [APP  setIsRegister:NO];
        [APP connect];
    }
    else
    {
        [APP  setIsRegister:YES];
        [APP connect];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)textAlert:(NSString*)msg
{
    //NSLog(@"msg:%@",msg);
    dispatch_async(dispatch_get_main_queue(), ^{
        alertLabel.text=msg;
    });
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
