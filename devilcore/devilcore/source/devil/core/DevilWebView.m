//
//  DevilWebView.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilWebView.h"

@implementation DevilWebView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollView.bounces = NO;
        self.UIDelegate = self;
        self.navigationDelegate = self;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //[self showIndicator];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //[self hideIndicator];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    NSString* url = navigationAction.request.URL.absoluteString;
    NSString* scheme = navigationAction.request.URL.scheme;
    
    if([navigationAction.request.URL.absoluteString hasPrefix:@"itms-apps"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url] options:@{} completionHandler:^(BOOL success) {
            
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if(self.shouldOverride != nil){
        BOOL r = self.shouldOverride(url);
        if(r)
            decisionHandler(WKNavigationActionPolicyCancel);
        else
            decisionHandler(WKNavigationActionPolicyAllow+2);
    } else
        decisionHandler(WKNavigationActionPolicyAllow+2);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    NSString *url = [navigationResponse.response.URL absoluteString];
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    //[self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"취소"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        completionHandler(false);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(true);
                                                      }]];
    
    //[self presentViewController:alertController animated:YES completion:^{}];
}


@end
