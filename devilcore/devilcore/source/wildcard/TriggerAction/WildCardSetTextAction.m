//
//  WildCardSetTextAction.m
//  library
//
//  Created by Mu Young Ko on 2018. 11. 11..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardSetTextAction.h"
#import "WildCardMeta.h"
#import "WildCardUIView.h"
#import "WildCardUILabel.h"
#import "MappingSyntaxInterpreter.h"
@implementation WildCardSetTextAction

- (void)act:(WildCardTrigger *)trigger{
    [super act:trigger];
    WildCardUIView* v = super.meta.generatedViews[_targetNodeName];
    WildCardUILabel* l = [v subviews][0];
    l.text = [MappingSyntaxInterpreter interpret:_jsonPath:super.meta.correspondData];
}


@end



@implementation WildCardSetValueAction

- (void)act:(WildCardTrigger *)trigger{
    [super act:trigger];
    NSString* value = [MappingSyntaxInterpreter interpret:_targetjsonPath:super.meta.correspondData];
    super.meta.correspondData[_toJsonPath] = value;
}


@end
