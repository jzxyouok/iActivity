//
//  InputToolBar.h
//  iActivity
//
//  Created by 伍 兵 on 14-7-28.
//  Copyright (c) 2014年 伍 兵. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InputToolBarDelegate<NSObject>
-(void)sendMsgDict:(NSDictionary*)aMsgDict;
@end
@interface InputToolBar : UIView
{
    IBOutlet UITextField * textField;
    IBOutlet UIButton* sendBtn;
    
   __weak IBOutlet id<InputToolBarDelegate>delegate;
}
@property(nonatomic,weak) IBOutlet id<InputToolBarDelegate>delegate;
-(void)myResignFirstResponse;
@end
