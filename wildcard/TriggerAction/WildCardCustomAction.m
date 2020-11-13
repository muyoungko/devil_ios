//
//  WildCardCustomAction.m
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardCustomAction.h"
#import "WildCardConstructor.h"
#import "WildCardTrigger.h"

@implementation WildCardCustomAction

- (void)act:(WildCardTrigger *)trigger{
    
    [[WildCardConstructor sharedInstance].delegate onCustomAction:super.meta function:_function args:_args view:trigger.node];
}

@end


@implementation WildCardInstanceCustomAction

- (void)act:(WildCardTrigger *)trigger{
    
    if(super.meta.wildCardConstructorInstanceDelegate != nil)
    {
        BOOL consume = [super.meta.wildCardConstructorInstanceDelegate onInstanceCustomAction:super.meta function:_function args:_args view:trigger.node];
        
        if(!consume)
        {
            [[WildCardConstructor sharedInstance].delegate onCustomAction:super.meta function:_function args:_args view:trigger.node];
        }
    }
}

@end

