//
//  WebController.h
//  devil
//
//  Created by Mu Young Ko on 2020/11/20.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import "SubController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebController : SubController< WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, retain) NSString* topTitle;
@property (nonatomic, retain) NSString* url;
@property void (^mcallback)(id res) ;

+(void)goUrlAbsolute:(NSString*)url title:(NSString*)title;
+(void)goUrl:(NSString*)url title:(NSString*)title;
+(void)goUrl:(NSString*)url res:(id)res;

@end

NS_ASSUME_NONNULL_END
