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

NS_ASSUME_NONNULL_BEGIN

@interface Devil : NSObject

+(Devil*)sharedInstance;

@property (nonatomic, retain) NSMutableDictionary* member;
@property (nonatomic, retain) NSString* udid;
@property (nonatomic, retain) NSURL* reservedUrl;

-(void)consumeReservedUrl;

-(NSString*)getName;

-(BOOL)isLogin;
-(void)isLogin:(void (^)(id res))callback;

-(void)request:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback;
-(void)checkMemeber:(NSString*)type identifier:identifier callback:(void (^)(id res))callback;
-(void)login:(NSString*)type email:(NSString*)email passwordOrToken:(NSString*)passwordOrToken callback:(void (^)(id res))callback;

-(void)logout;

- (void)sendPush;

@end

NS_ASSUME_NONNULL_END
