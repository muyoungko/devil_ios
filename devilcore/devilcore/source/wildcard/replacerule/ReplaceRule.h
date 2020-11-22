//
//  ReplaceRule.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WildCardUIView.h"


#define RULE_TYPE_NETWORK_IMAGE 1
#define RULE_TYPE_TEXT 2
#define RULE_TYPE_CLICK 3
#define RULE_TYPE_REPEAT 4
#define RULE_TYPE_LOCAL_IMAGE 5
#define RULE_TYPE_IMAGE_RESOURCE 12
#define RULE_TYPE_IMPRESSION 6
#define RULE_TYPE_HIDDEN 7
#define RULE_TYPE_COLOR 8
#define RULE_TYPE_REPLACE_URL 9
#define RULE_TYPE_EXTENSION 10
#define RULE_TYPE_COLOR 11


@interface ReplaceRule : NSObject

-(id)initWith:(UIView*)replaceView
             :(int)replaceType
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@property(nonatomic, retain) UIView* replaceView;
@property int replaceType;
@property(nonatomic, retain) NSMutableDictionary* replaceJsonLayer;
@property(nonatomic, retain) NSString* replaceJsonKey;

@end
