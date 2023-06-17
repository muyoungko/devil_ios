//
//  Devil.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2020/11/13.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

#define HOST_API @"https://console-api.deavil.com"
#define HOST_WEB @"http://console.deavil.com"
#define LEARN_API @"https://learn-api.devil-app-builder.com"

//#define LEARN_API @"http://192.168.1.230:9111"
//#define HOST_API @"http://192.168.1.230:6111"

NS_ASSUME_NONNULL_BEGIN

@interface Devil : NSObject

+(Devil*)sharedInstance;

@property (nonatomic, retain) NSMutableDictionary* member;
@property (nonatomic, retain) NSString* udid;
@property (nonatomic, retain) NSURL* reservedUrl;

-(void)consumeReservedUrl;

-(NSString*)getName;

-(NSString*)getLoginToken;
-(BOOL)isLogin;
-(void)isLogin:(void (^)(id res))callback;

-(void)request:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback;
-(void)requestLearn:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback;
-(void)checkMemeber:(NSString*)type identifier:identifier callback:(void (^)(id res))callback;
-(void)login:(NSString*)type email:(NSString*)email passwordOrToken:(NSString*)passwordOrToken callback:(void (^)(id res))callback;

-(void)logout;
-(void)sendPush;
-(BOOL)openUrl:(NSURL*)url;

@end

NS_ASSUME_NONNULL_END
