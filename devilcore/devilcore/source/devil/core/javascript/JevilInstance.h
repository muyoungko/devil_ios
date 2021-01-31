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
#import "DevilSelectDialog.h"
#import "DevilBlockDialog.h"

NS_ASSUME_NONNULL_BEGIN

@interface JevilInstance : NSObject

+(JevilInstance*)globalInstance;
+(JevilInstance*)screenInstance;
+(JevilInstance*)currentInstance;

@property (nonatomic, retain) JSContext* jscontext;
@property (nonatomic, retain) NSMutableDictionary* data;
@property (nonatomic, retain) NSMutableDictionary* callbackData;
@property (nonatomic, retain) JSValue* callbackFunction;
@property (nonatomic, retain) UIViewController* vc;
@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) DevilBlockDialog* devilBlockDialog;
@property (nonatomic, retain) DevilSelectDialog* devilSelectDialog;

@end

NS_ASSUME_NONNULL_END
