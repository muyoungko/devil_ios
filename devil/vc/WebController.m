//
//  WebController.m
//  bnbhost
//
//  Created by 1100023 on 12/02/2020.
//  Copyright © 2020 july. All rights reserved.
//
#import "WebController.h"
#import "AppDelegate.h"
#import "MainController.h"
#import "JulyUtil.h"
#import "Devil.h"

@interface WebController ()

@property (nonatomic, retain) WKWebView* webView;
@property (nonatomic, retain) NSURL* currentUrl;
@property (nonatomic, retain) id res;

@end

@implementation WebController

+(void)goUrlAbsolute:(NSString*)url title:(NSString*)title{
    WebController* vc = [[WebController alloc] init];
    vc.topTitle = title;
    vc.url = url;
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    [app.navigationController pushViewController:vc animated:YES];
}

+(void)goUrl:(NSString*)url title:(NSString*)title{
    WebController* vc = [[WebController alloc] init];
    vc.topTitle = title;
    vc.url = [NSString stringWithFormat:@"%@%@", HOST_WEB, url];
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    [app.navigationController pushViewController:vc animated:YES];
}

+(void)goUrl:(NSString*)url res:(id)res{
    WebController* vc = [[WebController alloc] init];
    vc.res = res;
    vc.url = [NSString stringWithFormat:@"%@%@", HOST_WEB, url];
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    [app.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _topTitle;
    
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    config.applicationNameForUserAgent = @"Version/8.0.2 Safari/600.2.5";
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.viewMain.frame.size.width, self.viewMain.frame.size.height) configuration:config];
    
    [super.viewMain addSubview:_webView];
    [_webView.scrollView setDelaysContentTouches:NO];
    [_webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    _webView.scrollView.bounces = NO;
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if(token != nil){
        if([NSURL URLWithString:_url].query == nil)
            _url = [_url stringByAppendingString:@"?token="];
        else
            _url = [_url stringByAppendingString:@"&token="];
        _url = [_url stringByAppendingString:token];
    }
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [self showIndicator];
}

- (void)careRes{
    if(self.res){
        if([self.res[@"type"] isEqualToString:@"혈당"]){
            NSString* s = [NSString stringWithFormat:@"javascript:put('%@', '%@')", self.res[@"key"], trim(self.res[@"val"])];
            [self.webView evaluateJavaScript:s completionHandler:^(id _Nullable a, NSError * _Nullable error) {

            }];
        } else if([self.res[@"type"] isEqualToString:@"혈압"]){
            NSString* s = [NSString stringWithFormat:@"javascript:put('%@', '%@', '%@')", self.res[@"key"], trim(self.res[@"val1"]), trim(self.res[@"val2"])];
            [self.webView evaluateJavaScript:s completionHandler:^(id _Nullable a, NSError * _Nullable error) {

            }];
        } else if([self.res[@"type"] isEqualToString:@"체온"]){
            NSString* s = [NSString stringWithFormat:@"javascript:put('%@', '%@')", self.res[@"key"], self.res[@"val"]];
            [self.webView evaluateJavaScript:s completionHandler:^(id _Nullable a, NSError * _Nullable error) {

            }];
        } else if([self.res[@"type"] isEqualToString:@"복약"]){
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.res options:nil error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = urlencode(jsonString); 
            NSString* s = [NSString stringWithFormat:@"javascript:put('%@', '%@')", self.res[@"key"], jsonString];
            [self.webView evaluateJavaScript:s completionHandler:^(id _Nullable a, NSError * _Nullable error) {

            }];
        }
        self.res = nil;
    }
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self hideIndicator];
    [self performSelector:@selector(careRes) withObject:nil afterDelay:1.0f];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (navigationAction.targetFrame == nil) {
        NSURL *tempURL = navigationAction.request.URL;
        NSURLComponents *URLComponents = [[NSURLComponents alloc] init];
        URLComponents.scheme = [tempURL scheme];
        URLComponents.host = [tempURL host];
        URLComponents.path = [tempURL path];
        if ([URLComponents.URL.absoluteString isEqualToString:@"https://example.com/Account/ExternalLogin"]) {
            WKWebView *webViewtemp = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
            webViewtemp.UIDelegate = self;
            webViewtemp.navigationDelegate = self;
            [self.view addSubview:webViewtemp];
            return webViewtemp;
        } else {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}


- (void)backClick:(id)sender{
//    if([self.webView canGoBack])
//        [self.webView goBack];
//    else   
        [super back:sender];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    NSString* url = navigationAction.request.URL.absoluteString;
    NSString* scheme = navigationAction.request.URL.scheme;
    decisionHandler(WKNavigationActionPolicyAllow+2);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    NSString *url = [navigationResponse.response.URL absoluteString];
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)loadPath:(NSString*)path{
    NSString* url = [NSString stringWithFormat:@"%@%@", HOST_WEB, path];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}

- (BOOL)isMatch:(NSString *)url pattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error) {
        return NO;
    }
    NSTextCheckingResult *res = [regex firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];
    return res != nil;
}



- (BOOL)isiTunesURL:(NSString *)url {
    return [self isMatch:url pattern:@"\\/\\/itunes\\.apple\\.com\\/"];
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
    [self presentViewController:alertController animated:YES completion:^{}];
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
    
    [self presentViewController:alertController animated:YES completion:^{}];
}




@end
