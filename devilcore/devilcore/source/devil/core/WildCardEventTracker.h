//
//  WildCardEventTracker.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/10/05.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WildCardEventTracker : NSObject

+(WildCardEventTracker*)sharedInstance;

-(void)onScreen:(NSString*)projectId screenId:(NSString*)screenId screenName:(NSString*)screenName;
-(void)onClickEvent:(NSString*)viewName data:(id)data;

@end

NS_ASSUME_NONNULL_END
