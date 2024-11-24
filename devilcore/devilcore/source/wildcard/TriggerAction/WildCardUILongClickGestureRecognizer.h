//
//  WildCardUILongClickGestureRecognizer.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/11/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WildCardMeta.h"
#import "ReplaceRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardUILongClickGestureRecognizer : UILongPressGestureRecognizer
@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) NSString* nodeName;
@property (nonatomic, retain) NSString* script;
@property (nonatomic, retain) NSString* ga;
@property (nonatomic, retain) NSString* gaDataPath;
@property (nonatomic, retain) ReplaceRule* rule;
@property (nonatomic, retain) NSDictionary* extensionForCheckBox;
@property int tag;
@end

NS_ASSUME_NONNULL_END
