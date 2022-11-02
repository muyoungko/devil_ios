//
//  WildCardUITapGestureRecognizer.h
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WildCardMeta.h"
#import "ReplaceRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardUITapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) NSString* nodeName;
@property (nonatomic, retain) NSString* ga;
@property (nonatomic, retain) ReplaceRule* rule;
@property (nonatomic, retain) NSDictionary* extensionForCheckBox;
@property int tag;
@end

NS_ASSUME_NONNULL_END
