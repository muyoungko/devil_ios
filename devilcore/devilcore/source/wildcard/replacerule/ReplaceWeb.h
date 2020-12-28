//
//  ReplaceWe.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/28.
//
#import <UIKit/UIKit.h>
#import "ReplaceRule.h"

NS_ASSUME_NONNULL_BEGIN

#define ReplaceWeb(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceWeb alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

@interface ReplaceWeb : ReplaceRule

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;
             
@end


NS_ASSUME_NONNULL_END


