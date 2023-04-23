//
//  WildCardUITextField.h
//  library
//
//  Created by Mu Young Ko on 2018. 11. 10..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class WildCardMeta;

@interface WildCardUITextField : UITextField<UITextFieldDelegate>

+(WildCardUITextField*)create:(id)layer meta:(WildCardMeta*)meta;

@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) NSString* holder;
@property (nonatomic, retain) NSString* xbuttonImageName;
@property BOOL showXButton;
@property (nonatomic, retain) NSString* doneClickAction;
@property int maxLength;
@property (nonatomic, retain) NSString* keypadType;

-(void)doneClick;

@property void (^textChangedCallback)(NSString* text);
@property void (^textFocusChangedCallback)(BOOL focus);

@end

NS_ASSUME_NONNULL_END
