//
//  ScriptController.m
//  devil
//
//  Created by 고무영 on 10/8/25.
//  Copyright © 2025 Mu Young Ko. All rights reserved.
//

#import "ScriptController.h"
#import "JulyUtil.h"
#import "Devil.h"

@import WebKit;

@interface ScriptController() <WKNavigationDelegate, UITextFieldDelegate>
@property (nonatomic, strong) DevilLoadingManager* devilLoadingManager;
@property (nonatomic, strong) UIView *controlLayout;
@property (nonatomic, strong) UIView *findLayout;
@property (nonatomic, strong) UIView *replaceLayout;

@property (nonatomic, strong) UITextField *findTextField;
@property (nonatomic, strong) UITextField *replaceTextField;

@property (nonatomic, assign) BOOL caseSensitive;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@end

@implementation ScriptController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.devilLoadingManager = [[DevilLoadingManager alloc] init];
    // Configure WebView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptEnabled = YES;
    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    
    self.webview.translatesAutoresizingMaskIntoConstraints = YES;
    self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webview];
    
    self.webview.navigationDelegate = self;
    
    // Load Ace Editor
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"aceeditor"];
    if (htmlURL) {
        NSURL *readAccess = [htmlURL URLByDeletingLastPathComponent];
        [self.webview loadFileURL:htmlURL allowingReadAccessToURL:readAccess];
    }
    
    self.title = @"Source";
    
    // UI Setup
    [self setupUI];
    
    // Load Script
    [self loadScript];
    
    // Keyboard Observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)showIndicator {
    [self.devilLoadingManager startLoading];
}

- (void)hideIndicator {
    [self.devilLoadingManager stopLoading];
}

- (void)setupUI {
    self.caseSensitive = NO;
    
    // Main Toolbar Stack (Vertical)
    UIStackView *mainStack = [[UIStackView alloc] init];
    mainStack.axis = UILayoutConstraintAxisVertical;
    mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    mainStack.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    
    [self.view addSubview:mainStack];
    
    self.bottomConstraint = [mainStack.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [mainStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [mainStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        self.bottomConstraint
    ]];
    
    // 1. Find Layout
    self.findLayout = [self createFindLayout];
    self.findLayout.hidden = YES;
    [mainStack addArrangedSubview:self.findLayout];
    
    // 2. Replace Layout
    self.replaceLayout = [self createReplaceLayout];
    self.replaceLayout.hidden = YES;
    [mainStack addArrangedSubview:self.replaceLayout];
    
    // 3. Control Layout
    self.controlLayout = [self createControlLayout];
    [mainStack addArrangedSubview:self.controlLayout];
    
    // Adjust WebView insets
    self.webview.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0); 
    self.webview.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 60, 0);
}

- (UIView *)createControlLayout {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.distribution = UIStackViewDistributionFillProportionally;
    stack.spacing = 10;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    
    [stack addArrangedSubview:[self createTextButton:@"CTRL" selector:@selector(onCtrl)]];
    [stack addArrangedSubview:[self createIconButton:@"arrow.right.to.line" selector:@selector(onTab)]]; // Tab
    [stack addArrangedSubview:[self createTextButton:@"SHFT" selector:@selector(onShift)]];
    [stack addArrangedSubview:[self createIconButton:@"arrow.uturn.backward" selector:@selector(onUndo)]]; // Undo
    [stack addArrangedSubview:[self createIconButton:@"arrow.uturn.forward" selector:@selector(onRedo)]]; // Redo
    [stack addArrangedSubview:[self createIconButton:@"magnifyingglass" selector:@selector(onStartFind)]]; // Search
    [stack addArrangedSubview:[self createIconButton:@"square.and.arrow.down" selector:@selector(onSave)]]; // Save
    
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [container addSubview:stack];
    [self pinView:stack toView:container padding:5];
    return container;
}

- (UIView *)createFindLayout {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.alignment = UIStackViewAlignmentCenter;
    
    self.findTextField = [[UITextField alloc] init];
    self.findTextField.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.findTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.findTextField.delegate = self;
    [self.findTextField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [stack addArrangedSubview:self.findTextField];
    
    [stack addArrangedSubview:[self createIconButton:@"magnifyingglass" selector:@selector(onFind)]];
    [stack addArrangedSubview:[self createIconButton:@"chevron.up" selector:@selector(onPrev)]];
    [stack addArrangedSubview:[self createIconButton:@"chevron.down" selector:@selector(onNext)]];
    
    UIButton *caseBtn = [self createIconButton:@"textformat" selector:@selector(onCaseSensitive:)];
    caseBtn.tintColor = [UIColor whiteColor];
    [stack addArrangedSubview:caseBtn];
    
    [container addSubview:stack];
    [self pinView:stack toView:container padding:5];
    
    [self.findTextField.widthAnchor constraintGreaterThanOrEqualToConstant:100].active = YES;
    
    return container;
}

- (UIView *)createReplaceLayout {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.alignment = UIStackViewAlignmentCenter;
    
    self.replaceTextField = [[UITextField alloc] init];
    self.replaceTextField.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.replaceTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.replaceTextField.delegate = self;
    [self.replaceTextField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [stack addArrangedSubview:self.replaceTextField];
    
    [stack addArrangedSubview:[self createIconButton:@"arrow.triangle.2.circlepath" selector:@selector(onReplace)]];
    [stack addArrangedSubview:[self createIconButton:@"checkmark.circle" selector:@selector(onReplaceAll)]];
    [stack addArrangedSubview:[self createIconButton:@"xmark" selector:@selector(onCloseFind)]];
    
    [container addSubview:stack];
    [self pinView:stack toView:container padding:5];
    
    [self.replaceTextField.widthAnchor constraintGreaterThanOrEqualToConstant:100].active = YES;
    
    return container;
}

- (UIButton *)createIconButton:(NSString *)systemName selector:(SEL)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *img = [UIImage systemImageNamed:systemName];
    if (!img) {
        [btn setTitle:systemName forState:UIControlStateNormal];
    } else {
        [btn setImage:img forState:UIControlStateNormal];
    }
    btn.tintColor = [UIColor whiteColor];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn.widthAnchor constraintEqualToConstant:40].active = YES;
    return btn;
}

- (UIButton *)createTextButton:(NSString *)text selector:(SEL)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.tintColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)pinView:(UIView *)view toView:(UIView *)container {
    [self pinView:view toView:container padding:0];
}

- (void)pinView:(UIView *)view toView:(UIView *)container padding:(CGFloat)padding {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [view.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:padding],
        [view.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-padding],
        [view.topAnchor constraintEqualToAnchor:container.topAnchor constant:padding],
        [view.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-padding]
    ]];
}

#pragma mark - Actions

- (void)onCtrl {
    [self runJS:@"editor.setKeyboardHandler('ace/keyboard/vim')"];
}

- (void)onTab {
    [self runJS:@"editor.insert('\\t')"];
}

- (void)onShift {
    [self runJS:@"editor.setKeyboardHandler('ace/keyboard/emacs')"];
}

- (void)onUndo {
    [self runJS:@"editor.undo()"];
}

- (void)onRedo {
    [self runJS:@"editor.redo()"];
}

- (void)onStartFind {
    [UIView animateWithDuration:0.2 animations:^{
        self.controlLayout.hidden = YES;
        self.findLayout.hidden = NO;
        self.replaceLayout.hidden = NO;
    }];
}

- (void)onCloseFind {
    [UIView animateWithDuration:0.2 animations:^{
        self.controlLayout.hidden = NO;
        self.findLayout.hidden = YES;
        self.replaceLayout.hidden = YES;
    }];
    
    [self runJS:@"editor.focus()"];
    [self runJS:@"editor.find('', {backwards: false, wrap: false, caseSensitive: false, wholeWord: false, regExp: false})"];
    [self.view endEditing:YES];
}

- (void)onFind {
    NSString *keyword = [self escapeString:self.findTextField.text];
    NSString *js = [NSString stringWithFormat:@"editor.find('%@', {backwards: false, wrap: false, caseSensitive: %@, wholeWord: false, regExp: false})", keyword, self.caseSensitive ? @"true" : @"false"];
    [self runJS:js];
}

- (void)onPrev {
    [self runJS:@"editor.findPrevious();"];
}

- (void)onNext {
    [self runJS:@"editor.findNext();"];
}

- (void)onCaseSensitive:(UIButton *)sender {
    self.caseSensitive = !self.caseSensitive;
    sender.selected = self.caseSensitive;
    sender.tintColor = self.caseSensitive ? [UIColor yellowColor] : [UIColor whiteColor];
    [self onFind];
}

- (void)onReplace {
    NSString *keyword = [self escapeString:self.findTextField.text];
    NSString *replace = [self escapeString:self.replaceTextField.text];
    NSString *js = [NSString stringWithFormat:@"editor.replace('%@', '%@', {backwards: false, wrap: false, caseSensitive: %@, wholeWord: false, regExp: false})", keyword, replace, self.caseSensitive ? @"true" : @"false"];
    [self runJS:js];
}

- (void)onReplaceAll {
    NSString *keyword = [self escapeString:self.findTextField.text];
    NSString *replace = [self escapeString:self.replaceTextField.text];
    NSString *js = [NSString stringWithFormat:@"editor.replaceAll('%@', '%@', {backwards: false, wrap: false, caseSensitive: %@, wholeWord: false, regExp: false})", keyword, replace, self.caseSensitive ? @"true" : @"false"];
    [self runJS:js];
}

- (void)onSave {
    [self.webview evaluateJavaScript:@"editor.getValue()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error getting script: %@", error);
            return;
        }
        if ([result isKindOfClass:[NSString class]]) {
            NSString *script = result;
            [self saveScript:script];
        }
    }];
}

#pragma mark - Logic

- (void)loadScript {
    NSString *url = [NSString stringWithFormat:@"/screen/%@", self.screenId];
    [self showIndicator];
    [[Devil sharedInstance] request:url postParam:nil complete:^(id  _Nonnull res) {
        [self hideIndicator];
        if (res && [res isKindOfClass:[NSDictionary class]]) {
            NSString *script = res[@"javascript_on_create"];
            if (script) {
                // Escape script for JS string
                NSData *data = [NSJSONSerialization dataWithJSONObject:@[script] options:0 error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                // jsonString is ["script content"] - a JSON array string
                // We use [0] in JS to extract the string from the array safely.
                // This handles all escaping issues automatically.
                NSString *js = [NSString stringWithFormat:@"editor.setValue(%@[0], -1)", jsonString];
                [self runJS:js];
            }
        }
    }];
}

- (void)saveScript:(NSString *)script {
    NSString *url = [NSString stringWithFormat:@"/api/screen/script/%@", self.screenId];
    [self showIndicator];
    [[Devil sharedInstance] request:url postParam:@{@"javascript_on_create": script} complete:^(id  _Nonnull res) {
        [self hideIndicator];
        if (res && [res isKindOfClass:[NSDictionary class]] && [res[@"r"] boolValue]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Saved" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }];
}

- (void)runJS:(NSString *)js {
    [self.webview evaluateJavaScript:js completionHandler:nil];
}

- (NSString *)escapeString:(NSString *)input {
    // Simple escape for single quoted strings in JS
    if (!input) return @"";
    NSString *escaped = [input stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    return escaped;
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = -kbSize.height + self.view.safeAreaInsets.bottom;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
    
    [self runJS:@"editor.blur()"];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self runJS:@"editor.setTheme('ace/theme/terminal')"];
    [self runJS:@"editor.getSession().setMode('ace/mode/javascript')"];
    [self runJS:@"editor.getSession().setUseWrapMode(true)"];
}

@end
