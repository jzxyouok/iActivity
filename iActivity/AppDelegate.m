//
//  AppDelegate.m
//  iActivity
//
//  Created by 伍 兵 on 14-7-23.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginVC.h"
#import "MessageVC.h"
@implementation AppDelegate
@synthesize msgDelegate;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize isRegister;
@synthesize userJID,password;
@synthesize rootTabBarVC;

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

- (void)setupStream
{

	// Setup xmpp stream
	xmppStream = [[XMPPStream alloc] init];
    //[xmppStream setHostName:@"10.0.0.131"];
    //[xmppStream setHostPort:5222];
#if !TARGET_IPHONE_SIMULATOR
	{
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	// Setup reconnect
	xmppReconnect = [[XMPPReconnect alloc] init];
	// Setup roster
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}
- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    NSString *domain = [xmppStream.myJID domain];
    //Google set their presence priority to 24, so we do the same to be compatible.
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
	[[self xmppStream] sendElement:presence];
}
- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	[[self xmppStream] sendElement:presence];
}
- (BOOL)connect
{
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    
	//NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:XMPP_LOG_NAME];
	//NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:XMPP_LOG_PASSWORD];

	[xmppStream setMyJID:[XMPPJID jidWithString:userJID]];
	//password = myPassword;
    
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        NSLog(@"connectError:%@",error);
		return NO;
	}
     NSLog(@"connectError:%@",error);
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}
#pragma mark XMPPStream Delegate
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	NSLog(@"socket did connect");
}
//连接状态
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	NSLog(@"stream did connect");
	
	isXmppConnected = YES;
	NSError *error = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:userJID forKey:XMPP_LOG_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:XMPP_LOG_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //登录验证
    if(!isRegister)
    {
        if (![[self xmppStream] authenticateWithPassword:password error:&error])
        {
            NSLog(@"authenticate error:%@", error);
        }
    }
    else
    {
        //注册
        if(![self.xmppStream registerWithPassword:password error:&error])
        {
            NSLog(@"register error:%@",error);
        }
    }

}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
        isXmppConnected=NO;
		NSLog(@"stream did disconnect with error:%@",error);
}
//登录结果回调
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"did authenticate");
    
	[self goOnline];
    //消除登陆页
    UINavigationController* nav=[[self.rootTabBarVC viewControllers] objectAtIndex:0];
    MessageVC* messageVC=(MessageVC*)[nav topViewController];
    [messageVC.loginVC  dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    isXmppConnected=NO;
	NSLog(@"did not authenticate with error:%@",error);
    //[self alert:@"登录失败!"];
    
    //NSLog(@"vcs:%@",[self.rootTabBarVC viewControllers]);
    
    UINavigationController* nav=[[self.rootTabBarVC viewControllers] objectAtIndex:0];
    MessageVC* messageVC=(MessageVC*)[nav topViewController];
    [messageVC.loginVC  textAlert:@"登录失败!"];
    
}
//注册结果回调
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"did register");
    isXmppConnected=NO;
    
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    isXmppConnected=NO;
    NSLog(@"did not register with error:%@",error);
    //[self alert:@"注册失败!"];
    UINavigationController* nav=[[self.rootTabBarVC viewControllers] objectAtIndex:0];
    MessageVC* messageVC=(MessageVC*)[nav topViewController];
    [messageVC.loginVC  textAlert:@"注册失败!"];
}
//**************接收到的消息*****************//
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //NSLog(@"receive IQ:%@",iq);
	return NO;
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *fromJID = [[message attributeForName:@"from"] stringValue];
    if(![fromJID isEqualToString:[[sender myJID] bare]])
    {
        NSString* currentChatJID=[[GlobalDataManager sharedDataManager] currentChatJID];
         NSLog(@"receive Msg:%@ from:%@",msg,fromJID);
        //NSLog(@"currentJID:%@",currentChatJID);
        if(currentChatJID&&msg&&[fromJID hasPrefix:currentChatJID])
        {
            [msgDelegate receivedMsgDict:@{@"msg": msg,@"fromJID":fromJID,@"type":@"receive"}];
            
        }
        
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSString *presenceType = [presence type];
    NSString *presenceUser = [[presence from] user];
    NSString * myJID=[[sender myJID] user];
    //NSLog(@"myJID:%@",myJID);
    if(![presenceUser isEqualToString:myJID])
    {
        NSLog(@"receive presence:%@ from:%@",presenceType,presenceUser);
        if([presenceType hasSuffix:@"subscribed"])
        {
            //处理好友申请
            NSString* msg;
            if([presenceType isEqualToString:@"subscribed"])
            {
                msg=[NSString stringWithFormat:@"%@同意你的请求",presenceUser];
            }
            else if([presenceType isEqualToString:@"unsubscribed"])
            {
                 msg=[NSString stringWithFormat:@"%@不同意你的请求",presenceUser];
            }
            
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"info" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
    }
	
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	NSLog(@"receive error:%@",error);
}
-(void)sendMsg:(NSString*)message
{
    if (message.length > 0)
    {
        GlobalDataManager* m=[GlobalDataManager sharedDataManager];
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:[m currentChatJID]];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:XMPP_LOG_NAME]];
        //组合
        [mes addChild:body];
        
        //发送消息
        [xmppStream sendElement:mes];
    }
}
-(void)XMPPRemoveFriendWithJID:(NSString*)aJID
{
    XMPPJID *jid = [XMPPJID jidWithString:aJID];
    [xmppRoster removeUser:jid];
}
- (void)XMPPAddFriendWithJID:(NSString *)aJID
{
    //XMPPHOST 就是服务器名，  主机名
    XMPPJID *jid = [XMPPJID jidWithString:aJID];
    //[presence addAttributeWithName:@"subscription" stringValue:@"好友"];
    [xmppRoster subscribePresenceToUser:jid];
    
}
#pragma mark - RosterDelegate
//收到好友添加请求代理
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    currentRequstJID=[presence from];
    NSString* msg=[NSString  stringWithFormat:@"来自%@的好友申请!",presenceFromUser];
    NSLog(@"subscribe:%@ from:%@",presenceType,presenceFromUser);
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"消息" message:msg delegate:self cancelButtonTitle:@"不同意" otherButtonTitles:@"同意", nil];
    [alert show];
   
}
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    NSLog(@"receive buddy request:%@",presence);
}


#pragma mark - UIAlertView

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        [xmppRoster rejectPresenceSubscriptionRequestFrom:currentRequstJID];
    }
    else
    {
        
        [xmppRoster acceptPresenceSubscriptionRequestFrom:currentRequstJID andAddToRoster:YES];
    }
}

-(void)alert:(NSString*)msg
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"info" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupStream];//初始化xml流
    // Override point for customization after application launch.
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
