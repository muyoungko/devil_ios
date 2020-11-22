//
//  BaseViewController.h
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <devilcore/devilcore.h>
#import "AppDelegate.h"


#define NETWORK_MSG @"일시적인 네트워크 오류가 발생하였습니다."

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define UIColorFromRGBA(argbValue) \
[UIColor colorWithRed:((float)((argbValue & 0x00FF0000) >> 16))/255.0 \
green:((float)((argbValue & 0x0000FF00) >>  8))/255.0 \
blue:((float)((argbValue & 0x000000FF) >>  0))/255.0 \
alpha:((float)((argbValue & 0xFF000000) >>  24))/255.0]

#define trim( str ) [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]
#define empty( str ) ( str == nil || [str length] == 0)

#define encode( str ) [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]



NS_ASSUME_NONNULL_BEGIN

@interface BaseController : UIViewController<UIScrollViewDelegate, UIAlertViewDelegate, UITextFieldDelegate,  UIScrollViewDelegate, UIGestureRecognizerDelegate, WildCardConstructorInstanceDelegate>
{
    int screenWidth, screenHeight;
    
    CGPoint editingPoint;
    UIView* editingView;
    
    void (^mcallback)(BOOL) ;
}

@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIView* viewMain;
@property (nonatomic, retain) NSMutableDictionary* leftData;
@property (nonatomic, retain) WildCardUIView* leftWc;

@property (nonatomic, retain) NSMutableDictionary* topData;
@property (nonatomic, retain) WildCardUIView* topWc;

-(void)openMenu;
-(void)closeMenu;
-(void)createMenuView;
-(void)createDrawerView;
-(void)openTopMenu;
-(void)closeTopMenu;

-(void)back:(id)sender;
- (void)showIndicator;
- (void)hideIndicator;
-(void)showAlert:(NSString*)msg;
-(void)showAlertWithFinish:(NSString*)msg;
-(BOOL)showAlertError:(id)res;
-(void)showConfirm:(NSString*)msg complete:(void (^)(BOOL))callback;
-(BOOL)empty:(NSString*)str;
-(NSString*)trim:(NSString*)str;


#define BUTTON_TYPE_ONE 0
#define BUTTON_TYPE_TWO 1
@property (nonatomic, retain) UIView* dialogView;
- (void)showCustomAlert:(NSString*)title withContentView:(UIView*)content withButtonType:(int)type height:(BOOL)variableHeight;
- (void)showCustomAlert:(NSString*)title withContentView:(UIView*)content withButtonType:(int)type height:(BOOL)variableHeight withTag:(int)tag;
- (void)dismissCustomAlertView:(UIButton *)sender;
- (void)dismissCustomAlertViewWithCancel:(UIButton *)sender;

-(BOOL) isPhoneX;

@end

NS_ASSUME_NONNULL_END
