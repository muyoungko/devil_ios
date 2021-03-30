//
//  WildCardUITextField.h
//  library
//
//  Created by Mu Young Ko on 2018. 11. 10..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WildCardMeta.h"
NS_ASSUME_NONNULL_BEGIN

@interface WildCardUITextView : UITextView<UITextViewDelegate>

+(WildCardUITextView*)create:(id)layer meta:(WildCardMeta*)meta;

@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) NSString* holder;
@property (nonatomic, retain) NSString* xbuttonImageName;
@property BOOL showXButton;
@property (nonatomic, retain) NSString* doneClickAction;
@property (nonatomic, retain) NSString* placeholderText;
@property (nonatomic, retain) UILabel* placeholderLabel;
@property BOOL emtpy;
@property UIColor* originalTextColor;

@end

NS_ASSUME_NONNULL_END
