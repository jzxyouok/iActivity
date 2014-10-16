//
//  GlobalDataManager.m
//  iActivity
//
//  Created by 伍 兵 on 14-7-28.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import "GlobalDataManager.h"
static GlobalDataManager* m;
@implementation GlobalDataManager
@synthesize friendsArray;
@synthesize currentChatJID;
+(id)sharedDataManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m= [[GlobalDataManager alloc] init];
        
    });
    return m;
}
-(id)init
{
    self=[super init];
    if(self)
    {
        friendsArray=[[NSMutableArray alloc] init];
        [self getFriendsList];
    }
    return self;
}
-(void)getFriendsList
{
    NSManagedObjectContext *moc = [APP managedObjectContext_roster];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:10];
    
   NSFetchedResultsController* fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:moc
                                                                     sectionNameKeyPath:@"sectionNum"
                                                                              cacheName:nil];
    //[fetchedResultsController setDelegate:self];
    
    
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error])
    {
        NSLog(@"Error performing fetch: %@", error);
    }
    
    
    if([fetchedResultsController fetchedObjects])
    {
        NSArray * users=[fetchedResultsController fetchedObjects];
        for( XMPPUserCoreDataStorageObject* user in users)
        {
            [friendsArray addObject:user.displayName];
                //NSLog(@"name:%@",user.displayName);
        }
    }
    else
    {
        NSLog(@"读取好友失败");
    }
    
    NSLog(@"friends:%@",friendsArray);

}
@end
