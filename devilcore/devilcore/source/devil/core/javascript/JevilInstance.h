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

NS_ASSUME_NONNULL_BEGIN

@interface JevilInstance : NSObject

+(JevilInstance*)globalInstance;
+(JevilInstance*)screenInstance;
+(JevilInstance*)currentInstance;

-(void)syncData;

@property (nonatomic, retain) JSContext* jscontext;
@property (nonatomic, retain) NSMutableDictionary* data;
@property (nonatomic, retain) NSMutableDictionary* callbackData;
@property (nonatomic, retain) JSValue* callbackFunction;
@property (nonatomic, retain) UIViewController* vc;
@property (nonatomic, retain) WildCardMeta* meta;
@end

NS_ASSUME_NONNULL_END
