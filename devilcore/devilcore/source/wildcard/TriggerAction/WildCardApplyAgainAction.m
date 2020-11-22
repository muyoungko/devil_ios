//
//  WildCardApplyAgainAction.m
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardApplyAgainAction.h"
#import "WildCardConstructor.h"

@implementation WildCardApplyAgainAction

- (void)act:(WildCardTrigger *)trigger{
    [super act:trigger];
    UIView* nodeView = super.meta.generatedViews[_node];
    for(int i=0;i<[super.meta.replaceRules count];i++)
    {
        ReplaceRule* metaRule = super.meta.replaceRules[i];
        if(metaRule.replaceView == nodeView)
        {
            [WildCardConstructor applyRuleCore:super.meta rule:super.meta.replaceRules[i] withData:super.meta.correspondData];
            break;
        }
    }
}


@end
