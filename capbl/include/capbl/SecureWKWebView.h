#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecureWKWebView : WKWebView

-(void)makeSecure;
+(void)makeSecure:(WKWebView*)view;

@end

NS_ASSUME_NONNULL_END
