//
//  CloudReview.h
//  Wiz
//
//  Created by wiz on 12-2-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>  
#import <UIKit/UIKit.h>  
@interface CloudReview : NSObject {  
    int m_appleID;  
}  
+(CloudReview*)sharedReview;  
-(void) reviewFor:(int)appleID;  
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void) doReviewFor:(int) appleID;
@end 