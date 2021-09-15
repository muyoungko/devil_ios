//
//  WildCardLayoutPathUnit.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 12..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define WC_LAYOUT_TYPE_WRAP_CONTENT 0
#define WC_LAYOUT_TYPE_NEXT_VIEW 1
#define WC_LAYOUT_TYPE_GRAVITY 2
#define WC_LAYOUT_TYPE_MATCH_PARENT 3

@interface WildCardLayoutPathUnit : NSObject

@property int type;
@property int depth;
@property NSString* viewKey;
@property NSString* optionalViewName;

- (id) initWithType:(int)type depth:(int)depth viewKey:(NSString*)viewKey viewName:(NSString*)viewName;


@end


NS_ASSUME_NONNULL_END
