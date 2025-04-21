//
//  WildCardLayoutPathUnit.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 12..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardLayoutPathUnit.h"

@implementation WildCardLayoutPathUnit
- (id) initWithType:(int)type depth:(int)depth viewKey:(NSString*)viewKey viewName:(NSString*)viewName
{
    self = [super init];
    if (self != nil) {
        self.type = type;
        self.depth = depth;
        self.viewKey = viewKey;
        self.optionalViewName = viewName;
    }
    return self;
}

- (NSString *)description
{
    NSString* s = [super description];
    NSString* typeString = @"";
    if(_type == WC_LAYOUT_TYPE_WRAP_CONTENT)
        typeString = @"WRAP_CONTENT";
    else if(_type == WC_LAYOUT_TYPE_NEXT_VIEW)
        typeString = @"NEXT_VIEW";
    else if(_type == WC_LAYOUT_TYPE_GRAVITY_CENTER)
        typeString = @"GRAVITY_CENTER";
    else if(_type == WC_LAYOUT_TYPE_GRAVITY_VERTICAL_NOT_CENTER)
        typeString = @"WC_LAYOUT_TYPE_GRAVITY_VERTICAL_NOT_CENTER";
    else if(_type == WC_LAYOUT_TYPE_GRAVITY_HORIZONTAL_NOT_CENTER)
        typeString = @"WC_LAYOUT_TYPE_GRAVITY_HORIZONTAL_NOT_CENTER";
    else if(_type == WC_LAYOUT_TYPE_MATCH_PARENT)
        typeString = @"MATCH_PARENT";
    else if(_type == WC_LAYOUT_TYPE_FOLLOW_PARENT_WIDTH)
        typeString = @"WC_LAYOUT_TYPE_FOLLOW_PARENT_WIDTH";
    else if(_type == WC_LAYOUT_TYPE_FOLLOW_PARENT_HEIGHT)
        typeString = @"WC_LAYOUT_TYPE_FOLLOW_PARENT_HEIGHT";
    return [NSString stringWithFormat:@"%@ type:%@ depth:%d %@", s, typeString, _depth, _optionalViewName];
}
@end
