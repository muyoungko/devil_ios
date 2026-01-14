//
//  ScriptController.h
//  devil
//
//  Created by 고무영 on 10/8/25.
//  Copyright © 2025 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import devilcore;
NS_ASSUME_NONNULL_BEGIN

@interface ScriptController : DevilBaseController

@property (nonatomic, retain) NSString* screenId;
@property (nonatomic, retain) WKWebView *webview;

@end

NS_ASSUME_NONNULL_END
