//
//  DevilWebView.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilWebView.h"
#import "JevilInstance.h"
#import "Jevil.h"
#import "DevilBlockDialog.h"
#import "DevilController.h"
#import "DevilLink.h"
#import "DevilLang.h"

@interface DevilWebView ()
@property (copy, nonatomic) WKWebViewActionHandler actionHandler;
@end


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

    NSLog(@"url - %@",navigationAction.request.URL.absoluteString);
    NSString* url = navigationAction.request.URL.absoluteString;
    NSString* scheme = navigationAction.request.URL.scheme;
    
    if([navigationAction.request.URL.absoluteString hasPrefix:@"itms-apps"] ||
       [navigationAction.request.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]
       //||[navigationAction.request.URL.absoluteString hasPrefix:@"https://www.sktpass.com/applink"]
       ){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url] options:@{} completionHandler:^(BOOL success) {
            
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if([url hasPrefix:@"tauthlink://"] || [url hasPrefix:@"ktauthexternalcall://"]
              || [url hasPrefix:@"upluscorporation://"]
              || [url hasPrefix:@"ispmobile://"]
              ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url] options:@{} completionHandler:^(BOOL success) {
            
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if([url hasPrefix:@"jevil://devil.com/back"]) {
        [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if([url isEqualToString:@"jevil://devil.com/popupAddress"]) {
        
        [JevilInstance currentInstance].data[@"address_step"] = @"1";
        [JevilInstance currentInstance].data[@"address_input1"] = @"";
        [JevilInstance currentInstance].data[@"address_input2"] = @"";
        [JevilInstance currentInstance].data[@"address_list"] = [@[] mutableCopy];
        [JevilInstance currentInstance].data[@"address_no_result"] = @"";
        [[JevilInstance currentInstance] pushData];
        
        DevilBlockDialog* d = [DevilBlockDialog popup:@"address-devil-template" data:[JevilInstance currentInstance].data title:nil yes:nil no:nil
                                                 show:@"bottom"
                                             onselect:^(BOOL yes, id res) {
            [[JevilInstance currentInstance] syncData];
            if(yes) {
                NSString* s = [NSString stringWithFormat:@"javascript:addressPopupCallback('%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               [JevilInstance currentInstance].data[@"address_name"],
                               [JevilInstance currentInstance].data[@"road_address_name"],
                               [JevilInstance currentInstance].data[@"address_place_name"],
                               [JevilInstance currentInstance].data[@"address_detail"],
                               [JevilInstance currentInstance].data[@"address_post"],
                               [JevilInstance currentInstance].data[@"address_x"],
                               [JevilInstance currentInstance].data[@"address_y"]
                               ];
                [self evaluateJavaScript:s completionHandler:^(id _Nullable a, NSError * _Nullable error) {
                    
                }];
            }
        }];
        [d show];
        
        ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog = d;
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if([url isEqualToString:@"jevil://devil.com/popupAddressSelect"]) {
        DevilBlockDialog* d = [DevilBlockDialog popup:@"address-select-devil-template" data:[JevilInstance currentInstance].data title:nil yes:nil no:nil
                                                 show:@"bottom"
                                             onselect:^(BOOL yes, id res) {
            [[JevilInstance currentInstance] syncData];
            if(yes) {
                NSString* s = [NSString stringWithFormat:@"javascript:addressSelectPopupCallback('%@')",
                               [JevilInstance currentInstance].data[@"selectedAddressId"]];
                [self evaluateJavaScript:s completionHandler:^(id _Nullable a, NSError * _Nullable error) {
                    
                }];
            }
        }];
        [d show];
        
        ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog = d;
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if([url hasPrefix:@"jevil://devil.com"]) {
        [[DevilLink sharedInstance] standardUrlProcess:url];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if(![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        /**    jevil://markt/auth?name=%ED%99%8D%EC%9D%80%ED%9D%AC&birth=19801015&gender=0&mobile=...
         와 같은 커스텀 url도 있는데 이걸 self.shouldOverride에 물어봐야한다
         */
        if(self.shouldOverride != nil && self.shouldOverride(url))
            decisionHandler(WKNavigationActionPolicyCancel);
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url] options:@{} completionHandler:^(BOOL success) {
            
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else if(self.shouldOverride != nil && self.shouldOverride(url)){
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
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
    [alertController addAction:[UIAlertAction actionWithTitle:trans(@"확인")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                
                                                      }]];
    [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{
        
    }];
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:trans(@"취소")
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        completionHandler(false);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:trans(@"확인")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(true);
                                                      }]];
    
    [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
}



//WKWebView 설정. 개발업체에 맞게 개발자가 설정
- (WKWebViewConfiguration *)getWKWebViewConfigration {
    WKWebViewConfiguration  *wkWebViewConfiguration =  [[WKWebViewConfiguration alloc] init];
    WKUserContentController *kuserContentController = [[WKUserContentController alloc] init];
    WKPreferences           *kwebviewPreference     = [[WKPreferences alloc] init];
    
    //Message 핸들러 설정
    //[kuserContentController addScriptMessageHandler:self.scriptMessageHandler name:@"bridge"];
    wkWebViewConfiguration.userContentController = kuserContentController;
    
    // 메모리에서 랜더링 후 보여줌 Defalt = false
    // true 일경우 랜더링 시간동안 Black 스크린이 나옴
    wkWebViewConfiguration.suppressesIncrementalRendering = false;
    
    // 기본값 : Dynamic (텍스트 선택시 정밀도 설정)
    wkWebViewConfiguration.selectionGranularity = WKSelectionGranularityDynamic;
    
    // 기본값 false : HTML5 Video 형태로 플레이
    // true  : native full-screen play
    wkWebViewConfiguration.allowsInlineMediaPlayback = false;
    
    if (@available(iOS 9.0, *)) {
        // whether AirPlay is allowed.
        wkWebViewConfiguration.allowsAirPlayForMediaPlayback = false;
        
        // 기본값 : true;
        // whether HTML5 videos can play picture-in-picture.
        wkWebViewConfiguration.allowsPictureInPictureMediaPlayback = true;
        
        //LocalStorage 사용하도록 설정
        wkWebViewConfiguration.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
        
        if (@available(iOS 10.0, *)) {
            // 기본값 : true
            // true : 사용자가 시작 , false : 자동시작
            wkWebViewConfiguration.mediaTypesRequiringUserActionForPlayback = true;
        }
        
    }
    
    // WKPreference 셋팅
    kwebviewPreference.minimumFontSize = 0;                                   // 기본값 = 0
    kwebviewPreference.javaScriptCanOpenWindowsAutomatically = true;         // 기본값 = false
    kwebviewPreference.javaScriptEnabled = true;                              // 기본값 = true
    
    wkWebViewConfiguration.preferences = kwebviewPreference;
    
    return wkWebViewConfiguration;
}

- (void)setWKWebViewAction:(WKWebViewActionHandler)actionHandler {
    if (actionHandler != nil)
        self.actionHandler = actionHandler;
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    //DLog(@"didFailNavigation error - %@", [error description]);
    if (self.actionHandler != nil)
        self.actionHandler(WKWebViewActionDidFailNavigation, error);

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    //DLog(@"didFailProvisionalNavigation error - %@", [error description]);
    if (self.actionHandler != nil)
        self.actionHandler(WKWebViewActionDidFailNavigation, error);
   
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //message.name
}
@end
