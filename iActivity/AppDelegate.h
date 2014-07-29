//
//  AppDelegate.h
//  iActivity
//
//  Created by 伍 兵 on 14-7-23.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMPPFramework.h"

@protocol XMPPMsgDelegate <NSObject>
-(void)receivedMsgDict:(NSDictionary*)aDict;

@end
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSString *userJID;
    NSString *password;
    BOOL isXmppConnected;
    BOOL isRegister;
    
    XMPPJID * currentRequstJID;
    
   __weak id<XMPPMsgDelegate> msgDelegate;
    
    UITabBarController * rootTabBarVC;
}
@property(nonatomic,weak) id<XMPPMsgDelegate> msgDelegate;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property(nonatomic,assign) BOOL isRegister;
@property(nonatomic,retain) NSString* userJID,* password;
@property(nonatomic,retain) UITabBarController * rootTabBarVC;
- (BOOL)connect;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

//
- (void)XMPPAddFriendWithJID:(NSString *)aJID;
-(void)XMPPRemoveFriendWithJID:(NSString*)aJID;

-(void)sendMsg:(NSString*)message;
@end
