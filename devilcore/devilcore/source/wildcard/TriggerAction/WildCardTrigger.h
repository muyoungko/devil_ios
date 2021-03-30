//
//  WildCardTrigger.h
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WildCardUIView.h"
#import "WildCardAction.h"

#define WILDCARD_NODE_CLICKED @"nodeClicked"
#define WILDCARD_NODE_IMPRESSED @"nodeImpressed"
#define WILDCARD_VIEW_PAGER_CHANGED @"viewPagerChanged"
#define WILDCARD_APPLY_RULE_ALL @"applyRuleAll"


NS_ASSUME_NONNULL_BEGIN

@interface WildCardTrigger : NSObject

@property (nonatomic, retain) WildCardUIView* node;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* nodeName;
@property (nonatomic, retain) NSMutableArray* actions;

-(id)initWithType:(NSString*)type nodeName:(NSString*)nodeName node:(WildCardUIView*)node;

-(void)addAction:(id)action;
-(void)addActions:(NSMutableArray*)actions;

-(void)doAllAction;

@end

NS_ASSUME_NONNULL_END
