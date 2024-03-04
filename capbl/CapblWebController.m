//
//  WebController.m
//  capblapp
//
//  Created by Mu Young Ko on 2022/03/13.
//

#import "CapblWebController.h"
#import "SecureWKWebView.h"

@interface CapblWebController ()

@property (retain, nonatomic) NSString *url;
@property (retain, nonatomic) WKWebView *webView;

@end

@implementation CapblWebController

+(void)goUrlAbsolute:(UIViewController*)vc url:(NSString*)url {
    CapblWebController* w = [[CapblWebController alloc] init];
    w.url = url;
    [vc.navigationController pushViewController:w animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SecureWebView";
    
    if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft
       || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
        sh = [UIScreen mainScreen].bounds.size.width;
        sw = [UIScreen mainScreen].bounds.size.height;
    } else {
        sw = [UIScreen mainScreen].bounds.size.width;
        sh = [UIScreen mainScreen].bounds.size.height;
    }
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,sw,sh)];
    [self.view addSubview:self.webView];
    [self followSizeFromFather:self.view child:self.webView];
    
    [SecureWKWebView makeSecure:_webView];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    return nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
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

-(void) followSizeFromFather:(UIView*)vv child:(UIView*)tv
{
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(tv, vv);
    
    [vv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    [vv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tv]-0-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


@end
