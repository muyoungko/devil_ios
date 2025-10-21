//
//  ScriptController.m
//  devil
//
//  Created by 고무영 on 10/8/25.
//  Copyright © 2025 Mu Young Ko. All rights reserved.
//

#import "ScriptController.h"
#import "JulyUtil.h"

@import WebKit;

NS_ASSUME_NONNULL_BEGIN

@interface ScriptController()

@end

@implementation ScriptController 

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"ScriptController" owner:self options:nil];
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    
    // 1) WebView + JS 허용
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.javaScriptEnabled = YES;

    // 2) index.html 경로 찾기
    // (A) 메인 번들에 aceeditor 폴더가 있는 경우
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index"
                                             withExtension:@"html"
                                              subdirectory:@"aceeditor"];
    NSURL *readAccess = [htmlURL URLByDeletingLastPathComponent]; // aceeditor 폴더
    [self.webview loadFileURL:htmlURL allowingReadAccessToURL:readAccess];
    
    
    
    self.title = @"Source";
    //header
    UINavigationBarAppearance* a = [UINavigationBarAppearance new];
    [a configureWithOpaqueBackground];
    a.backgroundColor = [UIColor whiteColor];
    [a setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.scrollEdgeAppearance = self.navigationController.navigationBar.standardAppearance = a;
    
    [[WildCardConstructor sharedInstance] startLoading];
    [JulyUtil request:@"" complete:^(id  _Nonnull res) {
        [[WildCardConstructor sharedInstance] stopLoading];
    }];
    
    
}

@end

NS_ASSUME_NONNULL_END
