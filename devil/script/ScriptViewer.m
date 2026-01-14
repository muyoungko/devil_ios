//
//  ScriptViewer.m
//  devil
//
//  Created by Mu Young Ko on 2026/01/14.
//  Copyright © 2026 Mu Young Ko. All rights reserved.
//

#import "ScriptViewer.h"
#import <WebKit/WebKit.h>

@interface ScriptViewer () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *editor;
@property (nonatomic, copy) NSString *currentScript;
@property (nonatomic, assign) BOOL isLoaded;

@end

@implementation ScriptViewer

+ (instancetype)createView {
    return [[ScriptViewer alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptEnabled = YES;
    
    self.editor = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    self.editor.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.editor.navigationDelegate = self;
    self.editor.userInteractionEnabled = NO;
    
    [self addSubview:self.editor];
    
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"aceeditor"];
    if (htmlURL) {
        NSURL *readAccess = [htmlURL URLByDeletingLastPathComponent];
        [self.editor loadFileURL:htmlURL allowingReadAccessToURL:readAccess];
    }
}

- (void)updateView:(NSString *)script {
    
    if (![script isEqualToString:self.currentScript]) {
        [self setScriptToEditor:script];
        self.currentScript = script;
    }
}

- (void)setScriptToEditor:(NSString *)script {
    if (!script) return;
    
    // JSON serialize to safely escape string for JS
    NSData *data = [NSJSONSerialization dataWithJSONObject:@[script] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // jsonString is ["script content"]
    // setValue second argument -1 moves cursor to start
    NSString *js = [NSString stringWithFormat:@"editor.setValue(%@[0], -1)", jsonString];
    [self.editor evaluateJavaScript:js completionHandler:nil];
}

- (void)runJS:(NSString *)js {
    [self.editor evaluateJavaScript:js completionHandler:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.isLoaded = YES;
    
    // Setup editor settings as per Android implementation
    [self runJS:@"editor.setTheme('ace/theme/terminal')"];
    [self runJS:@"editor.getSession().setMode('ace/mode/javascript')"];
    [self runJS:@"editor.getSession().setUseWrapMode(true)"];
    
    [self runJS:@"editor.setOption('dragEnabled', false)"];
    [self runJS:@"editor.renderer.setOption('vScrollBarAlwaysVisible', true)"];
    
    // Inject CSS for touch-action
    NSString *styleJS = @"var style = document.createElement('style'); style.innerHTML = '.ace_editor, .ace_editor * { touch-action: pan-y !important; }'; document.getElementsByTagName('head')[0].appendChild(style);";
    [self runJS:styleJS];
    
    [self runJS:@"editor.on('focus', function() { editor.setOption('dragEnabled', false); });"];
    [self runJS:@"editor.setReadOnly(true)"];
    
    // Load pending script if any
    if (self.currentScript) {
        [self setScriptToEditor:self.currentScript];
    }
}

@end
