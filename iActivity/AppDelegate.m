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
- (void)setupStream
{
	// Setup xmpp stream
	xmppStream = [[XMPPStream alloc] init];
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
	if (!isXmppConnected)
	{
		NSLog(@"stream did disconnect with error:%@",error);
	}
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
    
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
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
        if(msg)
            NSLog(@"receive Msg:%@ from:%@",msg,fromJID);
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
    }
	
}
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    NSLog(@"receive buddy request:%@",presence);
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	NSLog(@"receive error:%@",error);
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
