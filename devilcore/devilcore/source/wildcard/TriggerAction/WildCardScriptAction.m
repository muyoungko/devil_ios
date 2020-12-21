//
//  WildCardScriptAction.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/21.
//

#import "WildCardScriptAction.h"
#import "WildCardConstructor.h"
#import "WildCardTrigger.h"

@implementation WildCardScriptAction

- (void)act:(WildCardTrigger *)trigger{
    [super act:trigger];
    
    if(self.meta.wildCardConstructorInstanceDelegate != nil)
    {
        BOOL consume = [self.meta.wildCardConstructorInstanceDelegate onInstanceCustomAction:super.meta function:@"script" args:@[self.script] view:trigger.node];
        
        if(!consume)
        {
            [[WildCardConstructor sharedInstance].delegate onCustomAction:super.meta function:@"script" args:@[self.script] view:trigger.node];
        }
    }
}


@end
