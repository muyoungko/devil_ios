//
//  DevilWebView.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import <WebKit/WebKit.h>
#import <WebKit/WKUIDelegate.h>
#import <WebKit/WKNavigationDelegate.h>

NS_ASSUME_NONNULL_BEGIN

//웹과 뷰사이에 필요한 동작
typedef NS_ENUM(NSInteger, WKWebViewAction) {
    WKWebViewActionDidFinishNavigation = 0,
    WKWebViewActionDidStartProvisionalNavigation,
    WKWebViewActionDidFailNavigation
};

typedef void(^WKWebViewActionHandler)(WKWebViewAction action, id result);

@class WKWebViewConfiguration;

@interface DevilWebView : WKWebView< WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property BOOL scrollListenerCalledInThisPage;
@property BOOL (^shouldOverride)(NSString* url);
@property void (^scrollBottomCallback)(void);
- (void)setWKWebViewAction:(WKWebViewActionHandler)actionHandler;

@end

NS_ASSUME_NONNULL_END
