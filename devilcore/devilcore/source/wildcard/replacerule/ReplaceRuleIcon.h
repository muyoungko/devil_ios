//
//  ReplaceRuleIcon.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/14.
//

#import <devilcore/devilcore.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReplaceRuleIcon : ReplaceRule

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

+(void)update:(ReplaceRuleIcon*)rule :(id)opt;
@end

NS_ASSUME_NONNULL_END
