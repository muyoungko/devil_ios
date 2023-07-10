//
//  WebController.h
//  capblapp
//
//  Created by Mu Young Ko on 2022/03/13.
//

#import <UIKit/UIKit.h>

@import WebKit;

NS_ASSUME_NONNULL_BEGIN

@interface CapblWebController : UIViewController<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIWebViewDelegate>
{
    float sw, sh;
}

+(void)goUrlAbsolute:(UIViewController*)vc url:(NSString*)url;


@end

NS_ASSUME_NONNULL_END
