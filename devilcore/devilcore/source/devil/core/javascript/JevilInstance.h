//
//  JevilInstance.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/14.
//

@import JavaScriptCore;
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WildCardMeta.h"
#import "MarketComponent.h"

NS_ASSUME_NONNULL_BEGIN

@class JevilCtx;
@class DevilBeacon;

@interface JevilInstance : NSObject

+(JevilInstance*)globalInstance;
+(JevilInstance*)screenInstance;
+(JevilInstance*)currentInstance;

-(void)syncData;
-(void)pushData;

@property (nonatomic, retain) JSContext* jscontext;
@property (nonatomic, retain) JSValue* data;
@property (nonatomic, retain) NSMutableDictionary* callbackData;
@property (nonatomic, retain) JSValue* callbackFunction;
@property (nonatomic, retain) UIViewController* vc;
@property (nonatomic, retain) JevilCtx* jevil;
@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) NSMutableDictionary* forRetain;
@property void (^timerCallback)(id res);
@property (nonatomic, retain) DevilBeacon* devilBeacon;
@property (nonatomic, retain) UIViewController* mark;

-(void)videoViewAutoPlay;
-(MarketComponent*)findMarketComponent:(NSString*)nodeName;

@end

NS_ASSUME_NONNULL_END
